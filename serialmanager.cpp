// serialmanager.cpp
//
// 对应头文件 serialmanager.h 的实现部分。
// 这里主要完成：构造函数 / 刷新串口列表 / 打开关闭串口 / 发送数据 / 接收数据 / 错误处理 等逻辑。

#include "serialmanager.h"

#include <QSerialPortInfo>  // 用于枚举系统可用串口
#include <QDebug>           // 调试输出用，可选

// ========================
// 构造函数实现
// ========================
SerialManager::SerialManager(QObject *parent)
    // 冒号后面的部分叫“成员初始化列表”
    // 语法：类名::构造函数(参数) : 基类构造(参数), 成员1(初值), 成员2(初值) { ... }
    : QObject(parent)
{
    // 将 QSerialPort 的 readyRead 信号，连接到本类的槽函数 handleReadyRead()
    // 语法：connect(发送者, 信号指针, 接收者, 槽函数指针);
    connect(&m_port, &QSerialPort::readyRead,
            this, &SerialManager::handleReadyRead);

    // 将 QSerialPort 的 errorOccurred 信号，连接到 handleError() 槽函数
    connect(&m_port, &QSerialPort::errorOccurred,
            this, &SerialManager::handleError);

    // 构造时自动刷新一次串口列表
    refreshPorts();
}

// ========================
// 刷新串口列表
// ========================
void SerialManager::refreshPorts()
{
    // 先清空两个列表
    m_portList.clear();
    m_portDescriptions.clear();

    const auto infos = QSerialPortInfo::availablePorts();

    for (const QSerialPortInfo &info : infos) {
        // 1) 端口名，例如 "COM3"
        m_portList << info.portName();

        // 2) 端口说明：由 description + manufacturer 组合
        QString desc = info.description();     // 如： "蓝牙链接上的标准串行"
        QString mfr  = info.manufacturer();    // 如： "Microsoft"

        QString display;
        if (!desc.isEmpty() && !mfr.isEmpty()) {
            display = QStringLiteral("%1 (%2)").arg(desc, mfr);
        } else if (!desc.isEmpty()) {
            display = desc;
        } else if (!mfr.isEmpty()) {
            display = mfr;
        } else {
            display = QStringLiteral("未知设备");
        }

        m_portDescriptions << display;
    }

    emit portListChanged();   // 通知 QML，portList 和 portDescriptions 都更新了
}




// ========================
// 打开串口
// ========================
void SerialManager::open(const QString &portName, int baudRate)
{
    // 如果之前已经打开，先关闭
    if (m_port.isOpen()) {
        m_port.close();
    }

    // 设置端口名和串口参数
    m_port.setPortName(portName);
    m_port.setBaudRate(baudRate);
    m_port.setDataBits(QSerialPort::Data8);
    m_port.setParity(QSerialPort::NoParity);
    m_port.setStopBits(QSerialPort::OneStop);
    m_port.setFlowControl(QSerialPort::NoFlowControl);

    // 调用 open() 真正打开串口，参数 QIODevice::ReadWrite 表示可读写
    if (!m_port.open(QIODevice::ReadWrite)) {
        // 打开失败，发出错误信号
        emit errorOccurred(tr("打开串口失败: %1").arg(m_port.errorString()));
        // 同时发出 connectedChanged()，保证 QML 端和属性状态一致
        emit connectedChanged();
        return;
    }

    // 打开成功后，清零统计数据
    m_rxBytes = 0;
    m_txBytes = 0;
    m_errorCount = 0;
    m_rxBuffer.clear();
    updateStats();         // 触发 statsChanged()

    emit connectedChanged();  // 通知 QML “connected 属性变化”
}

// ========================
// 关闭串口
// ========================
void SerialManager::close()
{
    if (m_port.isOpen()) {
        m_port.close();
    }

    emit connectedChanged();  // 告诉 QML：connected 状态已改变
}

// ========================
// 发送文本 / HEX 数据
// ========================
void SerialManager::sendText(const QString &text, bool hexMode)
{
    // 如果串口没打开，直接报错
    if (!m_port.isOpen()) {
        emit errorOccurred(tr("串口未打开，无法发送"));
        return;
    }

    QByteArray data;  // 要真正写入串口的原始字节数据

    if (hexMode) {
        // 1) hex 模式：将字符串视为十六进制字符串解析
        //    比如 "01 03 00 00 00 02" -> 0x01 0x03 0x00 0x00 0x00 0x02

        // 将 QString 转成 8-bit 字节数组（Latin1 编码即可，因为这里是 0~F 等 ASCII 字符）
        QByteArray hex = text.toLatin1();
        // 去掉所有空格，使得 fromHex 更容易解析
        hex = hex.replace(" ", "");

        if (hex.isEmpty()) {
            return; // 空字符串就不发
        }

        // QByteArray::fromHex 根据十六进制字符串生成真实字节
        QByteArray bytes = QByteArray::fromHex(hex);

        // 简单做法：如果结果为空，认为格式有问题
        if (bytes.isEmpty()) {
            emit errorOccurred(tr("Hex 格式错误"));
            return;
        }

        data = bytes;
    } else {
        // 2) 文本模式：按 UTF-8 编码发送
        data = text.toUtf8();
    }

    // QSerialPort::write() 实际写串口，返回写入字节数
    qint64 written = m_port.write(data);
    if (written < 0) {
        emit errorOccurred(tr("发送失败: %1").arg(m_port.errorString()));
        return;
    }

    // 累加已发送字节数
    m_txBytes += static_cast<qulonglong>(written);
    updateStats();
}

// ========================
// readyRead 槽函数：串口有新数据可读
// ========================
void SerialManager::handleReadyRead()
{
    // 读取所有可用数据（只要系统缓冲区有数据就读完）
    QByteArray bytes = m_port.readAll();

    // 更新已接收字节数
    m_rxBytes += static_cast<qulonglong>(bytes.size());
    updateStats();

    // 将新收到的数据拼接到内部缓冲区，
    // 等待按照换行符 '\n' 切分成“行”
    m_rxBuffer.append(bytes);

    int index = -1;
    // 循环查找 '\n'，每找到一处，就取出一行
    while ((index = m_rxBuffer.indexOf('\n')) != -1) {
        // 从头到 index（包括 '\n'）这一段就是一行
        QByteArray line = m_rxBuffer.left(index + 1);
        // 从缓冲区中移除这一行
        m_rxBuffer.remove(0, index + 1);

        // 将这一行按 UTF-8 解码成 QString
        QString text = QString::fromUtf8(line);
        // 发出“收到一行数据”的信号，交给 QML 去显示
        emit lineReceived(text);
    }
}

// ========================
// errorOccurred 槽函数：串口发生错误
// ========================
void SerialManager::handleError(QSerialPort::SerialPortError error)
{
    // NoError 表示没有错误，直接忽略
    if (error == QSerialPort::NoError) {
        return;
    }

    // 其它错误：错误计数 +1
    m_errorCount++;
    updateStats();

    // 把串口的错误字符串发给界面层
    emit errorOccurred(m_port.errorString());

    // 这里可以按需要决定是否自动关闭串口、尝试重连等
    // if (error == QSerialPort::ResourceError) { ... }
}

// ========================
// 更新统计属性
// ========================
void SerialManager::updateStats()
{
    // 目前三个统计量共用一个 statsChanged() 信号，
    // QML 中凡是绑定了 rxBytes/txBytes/errorCount 的地方都会刷新。
    emit statsChanged();
}
