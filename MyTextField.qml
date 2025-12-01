// MyTextField.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Universal

TextField {
    id: control

    // 尺寸与内边距
    implicitWidth: 160
    implicitHeight: 32

    hoverEnabled: true
    padding: 6
    leftPadding: 12
    rightPadding: 12
    topPadding: 6
    bottomPadding: 6

    // 文本颜色
    color: enabled ? "#333333" : "#aaaaaa"
    // 占位符颜色
    placeholderTextColor: "#b8aeb6"

    // 选中区域颜色（可选）
    selectionColor: "#f3c1da"
    selectedTextColor: "#333333"

    // 背景：圆角 + 悬浮 / 焦点效果
    background: Rectangle {
        radius: height / 2

        border.width: control.activeFocus ? 2
                    : control.hovered ? 2 :1
        border.color: !control.enabled ? "#d0c6cf"
                     : control.activeFocus ? "#a61d4d"
                     : control.hovered ? "#c48fb3"
                     : "#d0c6cf"

        color: !control.enabled ? "#f0f0f0"
             : control.activeFocus ? "#ffffff"   // 获取焦点时略微提亮
             : control.hovered ? "#fbe2ef"       // 悬浮淡粉
             : "#f7f2f4"                         // 普通浅底

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
}
