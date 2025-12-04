// page1.qml
import QtQuick
import QtQuick.Controls.Universal
import QtQuick.Layouts

Page {
    id: page1
    font.family: "Microsoft YaHei"   // 统一字体族
    title: qsTr("串口连接 - 列布局示例")


    property bool timestampEnabled: false//时间戳属性


    background: Rectangle {
        color: "#fdf8fa"
    }

    // ========================
    // 左侧列：通信配置 / 连接控制 / 统计信息
    // ========================
    ColumnLayout {
        id: leftColumn
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 15
        width: 400
        spacing: 16

        // 1. 串口参数卡片
        MyGroupBox {
            Layout.fillWidth: true

            Label {
                text: qsTr("通信配置")
                font.pixelSize: 14
                Layout.alignment: Qt.AlignVCenter
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Label {
                    text: qsTr("串口号：")
                    font.pixelSize: 14
                    Layout.alignment: Qt.AlignVCenter
                }
                MyComboBox  {
                    id: portCombo
                    model: serial.portList.length > 0 ? serial.portList : [qsTr("无可用串口")]
                    enabled: !serial.connected
                    Component.onCompleted: {
                        serial.refreshPorts()   // 启动时刷新一次
                    }
                }
                Label {
                    id: portDescLabel
                    Layout.fillWidth: true
                    font.pixelSize: 10
                    elide: Text.ElideRight   // 太长就省略号

                    // 防越界：先判断索引是否在合法范围
                    text: (serial.portDescriptions.length > 0
                           && portCombo.currentIndex >= 0
                           && portCombo.currentIndex < serial.portDescriptions.length)
                          ? serial.portDescriptions[portCombo.currentIndex]
                          : qsTr("无")
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Label {
                    text: qsTr("波特率：")
                    font.pixelSize: 14
                }
                MyComboBox  {
                    id: baudCombo
                    enabled: !serial.connected
                    model: ["9600", "19200", "38400", "57600", "115200"]
                }
            }
        }

        // 2. 连接控制卡片
        MyGroupBox {
            id: ctrlBox
            Layout.fillWidth: true

            Label {
                text: qsTr("连接控制")
                font.pixelSize: 14
                Layout.alignment: Qt.AlignVCenter
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                MyButton  {
                    id: connectButton
                    text: qsTr("连接")
                    enabled: !serial.connected     // 串口已连接时禁用“连接”按钮

                    onClicked: {
                        var baud = parseInt(baudCombo.currentText)//读取当前的波特率
                        serial.open(portCombo.currentText, baud)
                    }
                }

                MyButton  {
                    id: disconnectButton
                    text: qsTr("断开")
                    enabled: serial.connected      // 只有在连接状态下才能点击
                    onClicked: {
                        serial.close()
                    }
                }

                Rectangle {
                   width: 20
                   height: 20
                   radius: 10
                   color: serial.connected ? "#4CAF50" : "#F44336"  // 绿：已连接；红：未连接
                   border.width: 0
                   Layout.alignment: Qt.AlignVCenter
                }

                Label {
                   font.pixelSize: 14
                   text: serial.connected ? qsTr("已连接") : qsTr("未连接")
                   //color: serial.connected ? "#4CAF50" : "#F44336"
                   Layout.alignment: Qt.AlignVCenter
               }
            }
        }

        // 3. 统计 / 其它信息卡片
        MyGroupBox {
            id: statBox
            Layout.fillWidth: true

            Label {
                text: qsTr("统计信息")
                font.pixelSize: 14
                Layout.alignment: Qt.AlignVCenter
            }
            RowLayout{
                Layout.fillWidth: true
                spacing: 20

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Label { text: qsTr("已接收字节：") + serial.rxBytes }
                    Label { text: qsTr("已发送字节：") + serial.txBytes }
                    Label { text: qsTr("错误计数：") + serial.errorCount }
                }

                // 中间“弹簧”：把右边按钮推到最右
                Item {
                    Layout.fillWidth: true
                }
                MyCheckBox{
                    id: stampCheck
                    text: qsTr("时间戳")

                    checked: page1.timestampEnabled
                    onToggled: page1.timestampEnabled = checked
                }
                MyButton{
                    id: cleanButton
                    text: qsTr("清除")
                    onClicked: {//清除接收区
                        if (recvArea.text.length === 0)
                            return
                        recvArea.clear()

                    }
                }

            }
        }

        // 4. 发送数据卡片
        MyGroupBox {
            id: intputBox
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Label {
                    text: qsTr("发送数据")
                    font.pixelSize: 14
                    Layout.alignment: Qt.AlignVCenter
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    MyTextField {
                        id: sendField
                        Layout.fillWidth: true
                        placeholderText: qsTr("请输入要发送的数据")
                        onAccepted: sendButton.clicked()
                    }

                    MyButton  {
                        id: sendButton
                        text: qsTr("发送")
                        onClicked: {
                            if (sendField.text.length === 0)
                                return

                            var rawText = sendField.text

                            // 先实际发送
                            serial.sendText(rawText, hexSendCheck.checked)

                            if (page1.timestampEnabled) {
                                var now = new Date()
                                var ts = Qt.formatDateTime(now, "hh:mm:ss.zzz")
                                var tsHtml = "<font color='#579fd2'>[" + ts + "]</font> "

                                // 这里可选再加一个前缀区分 TX/RX
                                var prefixHtml = "<b>TX:</b> "

                                recvArea.append(tsHtml +"<font color='#0000ff'> "+ prefixHtml + rawText +"</font>")
                            } else {
                                recvArea.append("<font color='#0000ff'><b>TX:</b>"  + rawText +"</font>")
                            }

                            sendField.clear()
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    MyCheckBox {
                        id: hexSendCheck
                        text: qsTr("hex发送")
                    }
                    MyCheckBox {
                        id: hexRecvCheck
                        text: qsTr("hex显示")
                    }
                    MyCheckBox {
                        id: autoScrollCheck
                        text: qsTr("自动滚动")
                        checked: true
                    }
                }
            }
        }
    }

    // ========================
    // 右侧列：收发数据窗口（封装在 MyGroupBox 中）
    // ========================
    MyGroupBox {
        id: recvBox

        anchors.left: leftColumn.right
        anchors.leftMargin: 30
        anchors.right: parent.right
        anchors.rightMargin: 30
        anchors.top: parent.top
        anchors.topMargin: 15
        height: leftColumn.height   // 或改为 anchors.bottom 方式

        ColumnLayout {
            id: recvLayout
            spacing: 8

            // 标题
            Label {
                text: qsTr("接收数据")
                font.pixelSize: 14
                Layout.alignment: Qt.AlignVCenter
            }

            // 可滚动文本区
            Flickable {
                id: recvFlick
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                // 内容区域大小，跟随 TextArea 内容高度
                contentWidth: width
                contentHeight: recvArea.contentHeight


                TextArea.flickable: TextArea {
                    id: recvArea
                    readOnly: true
                    placeholderText: qsTr("收到的数据显示在这里")
                    placeholderTextColor: "#999999"
                    textFormat: TextEdit.RichText
                    wrapMode: TextArea.Wrap


                    // 让 TextArea 占满 Flickable 的可视区域宽度
                    width: recvFlick.width

                    background: Rectangle {
                        color: "#f7f2f4"          // 背景色
                        radius: 15                // 圆角
                        border.color: "#e6e1e3"   // 边框颜色
                        border.width: 1           // 边框宽度
                    }
                }

                // 垂直滚动条：贴在 Flickable 内部右侧，从上到下占满
                ScrollBar.vertical: ScrollBar {
                    id: vbar
                    y: 0
                    policy: ScrollBar.AlwaysOn

                    width: 5
                    implicitWidth: 5

                    anchors.right: parent.right
                    anchors.rightMargin: 2

                    topPadding: 15
                    bottomPadding: 15


                    hoverEnabled: true

                    // 轨道（背景）
                    background: Rectangle {

                        anchors.fill: parent
                        anchors.margins: 15
                        color: "#f7f2f4"
                    }

                    // 滑块
                    contentItem: Rectangle {
                        implicitWidth: parent.width
                        width: parent.width
                        radius: width / 2
                        color: vbar.pressed ? "#999999"
                              : (vbar.hovered ? "#999999" : "#e5e5e5")
                        border.width: 0
                    }
                }
            }
        }
    }


    function appendReceivedText(payload) {//公共函数
        // 记录追加前的滚动位置
        var oldContentY = recvFlick.contentY

        var html
        // RX 前缀：绿色
        var prefixHtml = "<font color='#00aa00'><b>RX:</b>"
        if (page1.timestampEnabled) {
            var now = new Date()
            var ts = Qt.formatDateTime(now, "hh:mm:ss.zzz")

            // 时间戳：蓝色
            var tsHtml = "<font color='#579fd2'>[" + ts + "]</font> "

            // RX 前缀：绿色


            // payload 就是 line 或 hexLine
            html = tsHtml + prefixHtml + payload + "</font>"
        } else {
            // 不带时间戳：整行绿色
            html = "<font color='#00aa00'>" + prefixHtml + payload + "</font>"
        }

        recvArea.append(html)

        // 自动滚动控制
        if (!autoScrollCheck.checked) {
            recvFlick.contentY = oldContentY
        } else {
            recvFlick.contentY = recvFlick.contentHeight - recvFlick.height
        }
    }


//数据接收处理
    // 数据接收处理
    Connections {
        target: serial

        // 文本模式：当 hexRecvCheck 未勾选时使用
        function onLineReceived(line) {
            if (hexRecvCheck.checked)
                return;  // 当前是 HEX 显示模式，忽略文本信号

            // line 直接作为 payload 传入
            page1.appendReceivedText(line)
        }

        // HEX 模式：当 hexRecvCheck 勾选时使用
        function onHexLineReceived(hexLine) {
            if (!hexRecvCheck.checked)
                return;  // 当前是文本显示模式，忽略 HEX 信号

            // hexLine 是 C++ 里真正按字节生成的 "XX XX ..." 字符串
            page1.appendReceivedText(hexLine)
        }

        // C++ emit errorOccurred(const QString &message) 时会触发
        function onErrorOccurred(message) {
            var oldContentY = recvFlick.contentY

            recvArea.append("<font color='#DC143C'>[ERROR] " + message + "</font>")

            if (!autoScrollCheck.checked) {
                recvFlick.contentY = oldContentY
            } else {
                recvFlick.contentY = recvFlick.contentHeight - recvFlick.height
            }
        }
    }




}
