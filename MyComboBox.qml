// MyComboBox.qml
import QtQuick
import QtQuick.Controls.Universal

ComboBox {
    id: control

    implicitWidth: 140
    implicitHeight: 32

    padding: 10
    hoverEnabled: true

    // ====================
    // 顶部显示区域文本
    // ====================
    contentItem: Text {
        text: control.displayText
        font: control.font
        color: control.enabled ? "#333333" : "#aaaaaa"
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    // ====================
    // 顶部背景：圆角 + 悬浮/按下
    // ====================
    background: Rectangle {
        implicitHeight: 32
        radius: height / 2          // 圆角外形
        border.width: control.hovered ? 2 : 1
        border.color: control.hovered ? "#c48fb3"
                                      : "#d0c6cf"

        color: !control.enabled ? "#f0f0f0"
             : control.down ? "#e4d3dd"      // 按下
             : control.hovered ? "#fbe2ef"   // 悬浮
             : "#f7f2f4"                     // 普通

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }

        Behavior on border.width {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    }

    // ====================
    // 下拉箭头（V 形圆角线）
    // ====================
    indicator: Item {
        implicitWidth: 14
        implicitHeight: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter

        Canvas {
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);

                var w = width;
                var h = height;

                ctx.beginPath();
                // 画一个“V”形箭头，用圆角连接
                ctx.moveTo(1, h * 0.35);
                ctx.lineTo(w / 2, h * 0.75);
                ctx.lineTo(w - 1, h * 0.35);

                ctx.lineWidth = 2;
                ctx.lineCap = "round";   // 线端圆角
                ctx.lineJoin = "round";  // 拐角圆角
                ctx.strokeStyle = control.enabled ? "#555555" : "#aaaaaa";
                ctx.stroke();
            }
        }
    }

    // ====================
    // 自定义下拉项 delegate
    // ====================
    // 说明：当前假定 model 是简单字符串列表（如 ["COM1","COM2"]）
    // 如未来改为 ListModel / 自定义 role，可再调整 text 绑定
    delegate: ItemDelegate {
        width: ListView.view ? ListView.view.width : control.width
        text: modelData
        font: control.font
        hoverEnabled: true
        padding: 8

        // 当前项是否高亮（与 ComboBox currentIndex 对应）
        highlighted: control.highlightedIndex === index

        background: Rectangle {
            anchors.fill: parent
            radius: 16
            // 颜色梯度设计：普通 -> 悬浮 -> 选中/按下
            color: parent.down ? "#efd5e4"                 // 按下稍深
                  : parent.highlighted ? "#f7e5f0"        // 当前选中项
                  : parent.hovered ? "#f9edf5"            // 悬浮更浅一点
                  : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }

            Behavior on border.color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }

            Behavior on border.width {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }
        }

        contentItem: Text {
            text: parent.text
            font: parent.font
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            color: parent.enabled
                   ? (parent.highlighted ? "#a61d4d" : "#333333")
                   : "#aaaaaa"
        }

        onClicked: {
            control.currentIndex = index
            popup.close()
        }



    }

    // ====================
    // 自定义 popup：圆角背景 + 列表
    // ====================
    popup: Popup {
        id: popup
        y: control.height - 1
        width: control.width
        implicitHeight: Math.min(contentItem.implicitHeight + 8, 240)
        padding: 4

        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        background: Rectangle {
            radius: 16
            color: "#ffffff"
            border.color: "#d0c6cf"
            border.width: 1


        }

        contentItem: ListView {
            id: listView
            clip: true
            implicitHeight: contentHeight
            model: control.delegateModel
            currentIndex: control.highlightedIndex
            delegate: control.delegate     // 使用上面自定义的 ItemDelegate

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }
        }
    }

    // ====================
    // 鼠标形状（不截获点击）
    // ====================
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        cursorShape: Qt.PointingHandCursor
    }
}
