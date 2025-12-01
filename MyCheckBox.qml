// MyCheckBox.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Universal

CheckBox {
    id: control

    // 间距 & 内边距
    spacing: 8
    hoverEnabled: true
    padding: 4
    leftPadding: 10
    rightPadding: 10

    // 根据指示器宽度 + 文本宽度 自动计算控件大小
    implicitWidth: leftPadding
                  + indicatorRect.implicitWidth
                  + spacing
                  + textItem.implicitWidth
                  + rightPadding

    implicitHeight: Math.max(indicatorRect.implicitHeight, textItem.implicitHeight)
                    + topPadding
                    + bottomPadding

    // 文本内容
    contentItem: Text {
        id: textItem
        text: control.text
        font: control.font
        color: control.enabled ? "#333333" : "#aaaaaa"
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: indicatorRect.width + control.spacing + 4
        // 可选：控制右侧留白
        anchors.right: parent.right
        anchors.rightMargin: 6
    }

    // 左侧指示器：圆角小药丸 + 勾选线
    indicator: Rectangle {
        id: indicatorRect
        implicitWidth: 18
        implicitHeight: 18
        radius: height / 2

        // 只做垂直居中，水平位置交给 CheckBox 自身布局处理
        anchors.verticalCenter: parent.verticalCenter

        border.width: control.checked ? 2 : 1
        border.color: !control.enabled ? "#d0c6cf"
                     : control.checked ? "#c48fb3"
                     : "#d0c6cf"


        color: !control.enabled ? "#f0f0f0"
             : control.checked ? "#f7e5f0"
             : "#f7f2f4"


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



        Canvas {
            anchors.fill: parent
            visible: control.checked
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);

                var w = width;
                var h = height;

                ctx.beginPath();
                // 柔和的 “✔” 勾选
                ctx.moveTo(w * 0.25, h * 0.55);
                ctx.lineTo(w * 0.45, h * 0.75);
                ctx.lineTo(w * 0.75, h * 0.30);

                ctx.lineWidth = 2;
                ctx.lineCap = "round";
                ctx.lineJoin = "round";
                ctx.strokeStyle = "#a61d4d";
                ctx.stroke();
            }
        }
    }

    // 鼠标形状（不截获点击事件，事件仍由 CheckBox 自己处理）
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        cursorShape: Qt.PointingHandCursor
    }
}
