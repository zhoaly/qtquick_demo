// serialmanager.h
//
// 串口后台管理类（后端逻辑）
// 作用：
//   - 封装 QSerialPort，统一管理串口的：
//       * 枚举可用串口列表
//       * 打开 / 关闭 串口
//       * 发送文本 / HEX 数据
//       * 接收数据并按行解析
//       * 统计已收 / 已发字节数、错误计数
//   - 通过 Q_PROPERTY / Q_INVOKABLE / 信号，把这些功能暴露给 QML 使用
//
// 使用方法（在 main.cpp 中典型用法）：
//   SerialManager serial;
//   engine.rootContext()->setContextProperty("serial", &serial);
//   然后在 QML 中即可通过对象名 "serial" 调用：
//      serial.open(...)
//      serial.sendText(...)
//      绑定 serial.rxBytes 等属性
//

#pragma once   // 防止头文件被重复包含的简洁写法（等价于传统的 #ifndef/#define 宏）

#include <QObject>
#include <QSerialPort>
#include <QStringList>

class SerialManager : public QObject //公有继承自QObject
{
    Q_OBJECT //注入一些隐藏的成员函数与静态元对象

    //Q_PROPERTY 本质是一个宏，语法上作用类似于“元数据声明”。
    /*本例：
            bool：属性类型
            connected：属性名，在 QML 中可通过 serial.connected 访问
            READ isConnected：声明读取函数名（getter）
            NOTIFY connectedChanged：当值改变时对应的通知信号名
    这一行不会直接生成 C++ 成员变量，只是提供给 moc（元对象编译器）分析，生成元信息，供 QML和反射使用*/

    // ---------------------- QML 可绑定属性 ----------------------
    // 1) 是否已经连接（串口是否处于打开状态）
    //    - QML 中可以直接用：serial.connected
    //    - 例如：Button.enabled: !serial.connected
    Q_PROPERTY(bool connected READ isConnected NOTIFY connectedChanged)

    // 2) 当前可用的串口列表,和对应串口说明
    Q_PROPERTY(QStringList portList READ portList NOTIFY portListChanged)
    Q_PROPERTY(QStringList portDescriptions READ portDescriptions NOTIFY portListChanged)


    // 3) 已接收字节数，用于统计显示
    //    - 每次收到数据（readyRead）后累加
    Q_PROPERTY(qulonglong rxBytes READ rxBytes NOTIFY statsChanged)

    // 4) 已发送字节数，用于统计显示
    //    - 每次成功 write() 后累加
    Q_PROPERTY(qulonglong txBytes READ txBytes NOTIFY statsChanged)

    // 5) 错误计数
    //    - 每次发生错误（errorOccurred 信号）时累加
    Q_PROPERTY(int errorCount READ errorCount NOTIFY statsChanged)

public:
    explicit SerialManager(QObject *parent = nullptr);//构造函数

    // ---------------------- QML 调用接口（Q_INVOKABLE） ----------------------
    // Q_INVOKABLE 的函数可以直接在 QML 中调用，如：
    //     serial.refreshPorts()
    //     serial.open("COM3", 115200)
    //     serial.sendText("Hello", false)

    // 1) 刷新可用串口列表
    //    - 内部会调用 QSerialPortInfo::availablePorts()
    //    - 调用后会发出 portListChanged() 信号，QML 端的 ComboBox 等会自动更新
    Q_INVOKABLE void refreshPorts();

    // 2) 打开串口
    //    - portName: 串口名（如 "COM3" / "/dev/ttyUSB0"）
    //    - baudRate: 波特率（如 9600 / 115200）
    //    - 打开成功：
    //        * 重置统计变量
    //        * 发出 connectedChanged()
    //    - 打开失败：
    //        * 发出 errorOccurred("错误信息")
    //        * 发出 connectedChanged()（保持与属性一致）
    Q_INVOKABLE void open(const QString &portName, int baudRate);

    // 3) 关闭串口
    //    - 如果当前已打开则关闭，并发出 connectedChanged()
    Q_INVOKABLE void close();

    // 4) 发送文本
    //    - text: 要发送的字符串
    //    - hexMode: 若为 true，则按十六进制字符串解析，例如：
    //         text="01 03 00 00 00 02" -> 发送 6 个字节 0x01 0x03 ...
    //       若为 false，则按普通 UTF-8 文本发送：
    //         text="hello" -> 发送 "hello" 对应的字节
    Q_INVOKABLE void sendText(const QString &text, bool hexMode);

    // ---------------------- 属性访问函数（给 Q_PROPERTY 使用） ----------------------

    // 串口是否打开
    bool isConnected() const { return m_port.isOpen(); }

    // 当前缓存的串口列表,以及对应的串口描述
    QStringList portList() const { return m_portList; }
    QStringList portDescriptions() const { return m_portDescriptions; }   // ★ 新增

    // 已接收字节数
    qulonglong rxBytes() const { return m_rxBytes; }

    // 已发送字节数
    qulonglong txBytes() const { return m_txBytes; }

    // 错误计数
    int errorCount() const { return m_errorCount; }

signals://signals: 是 Qt 定义的关键字（实际上是宏，展开为 protected: 一类访问控制
    // ---------------------- 属性变化通知信号 ----------------------
    // 当连接状态变化时发出（打开/关闭）
    void connectedChanged();

    // 当串口列表发生变化时发出（例如 refreshPorts() 后）
    void portListChanged();

    // 当统计信息（rx/tx/errorCount）任一发生变化时发出
    void statsChanged();

    // ---------------------- 业务相关信号（给 QML 使用） ----------------------
    // 收到一行文本时发出
    // - 这里约定“按行”是指以 '\n' 作为行结束，
    //   在 cpp 中会将 m_rxBuffer 中的数据按 '\n' 分割，再逐行发出该信号。
    // - 如果你的协议不是按行，可以后续改成其它形式（如按帧长度）。
    void lineReceived(const QString &line);

    // 串口出现错误时发出（参数为错误描述字符串）
    // - QML 中可以弹出弹窗或写到日志区
    void errorOccurred(const QString &message);

private slots:
    // ---------------------- 内部槽函数 ----------------------
    // 串口有数据可读时触发（连接自 QSerialPort::readyRead）
    void handleReadyRead();

    // 串口错误时触发（连接自 QSerialPort::errorOccurred）
    void handleError(QSerialPort::SerialPortError error);

private:
    // 更新统计信息时调用
    // - 统一发出 statsChanged() 信号，便于 QML 一次性更新所有相关显示
    void updateStats();

    // ---------------------- 成员变量 ----------------------
    QSerialPort m_port;      // 内部使用的串口对象
    QStringList m_portList;  // 缓存当前扫描到的串口名称
    QStringList m_portDescriptions; //对应说明列表

    qulonglong m_rxBytes = 0;   // 累计接收字节数
    qulonglong m_txBytes = 0;   // 累计发送字节数
    int m_errorCount = 0;       // 错误次数计数

    QByteArray m_rxBuffer;      // 接收缓冲区，用于按 '\n' 组包
};
