// MyButton.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Universal

Button {
    id: control

    hoverEnabled: true
    padding: 6
    leftPadding: 16
    rightPadding: 16
    topPadding: 6
    bottomPadding: 6

    // 根据文字自动计算尺寸
    implicitWidth: Math.max(80,
                            contentText.implicitWidth + leftPadding + rightPadding)
    implicitHeight: contentText.implicitHeight + topPadding + bottomPadding

    // 文本内容
    contentItem: Text {
        id: contentText
        text: control.text
        font: control.font
        color: !control.enabled ? "#aaaaaa"
             : control.down ? "#ffffff"
             : control.hovered ? "#a61d4d"
             : "#333333"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight

        Behavior on color {
            ColorAnimation {
                duration: 500
                easing.type: Easing.OutQuad
            }
        }
    }

    // 背景：圆角 + 悬浮 / 按下 / 焦点效果
    background: Rectangle {
        implicitHeight: 32
        radius: height / 2

        border.width: control.hovered ? 2 : 1
        border.color: !control.enabled ? "#d0c6cf"
                     : control.hovered ? "#c48fb3"
                     : "#d0c6cf"

        color: !control.enabled ? "#f0f0f0"
             : control.down ? "#a61d4d"    // 按下：主色
             : control.hovered ? "#fbe2ef" // 悬浮：浅粉
             : "#f7f2f4"                   // 普通：淡淡底色


        Behavior on color {
            ColorAnimation {
                duration: 500
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

    // 鼠标悬浮时光标形状（不拦截点击事件）
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        cursorShape: Qt.PointingHandCursor
    }
}
