// SideTabButton.qml
import QtQuick
import QtQuick.Controls

TabButton {
    id: control

    // 对外属性
    property string label: ""                     // 下方文字
    property url iconSource: ""                   // 图标路径（qrc 或本地）
    property int iconSize: 40                     // 图标尺寸

    property int blockHeight: 40                  // 上方色块高度

    property color backgroundcolor:  control.checked ?"#D8BFD8":"#e7e0eb"
    property double backgroundopacity:control.checked ?1:control.hovered ? 1 : 0

    text: ""             // 不用 TabButton 自带文字
    implicitHeight: 80   // 整体高度，可按需要调整
    anchors.left: parent.left
    anchors.leftMargin: 5
    anchors.right: parent.right
    anchors.rightMargin: 5


    contentItem: Item {
        anchors.fill: parent
        anchors.margins: 5


        // 仅背景做淡入淡出
        Rectangle {
            id: blockBg
            //anchors.fill: img
            anchors.top:img.top
            radius: 12
            width: parent.width
            height: blockHeight
            color: backgroundcolor

            opacity: backgroundopacity

            Behavior on opacity {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.OutQuad
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: 800
                    easing.type: Easing.OutQuad
                }
            }
        }

        // 图标单独一层，不受 blockBg.opacity 影响
        Image {
            id:img
            anchors.centerIn: parent
            source: control.iconSource
            visible: source !== ""
            width: control.iconSize
            height: control.iconSize
            fillMode: Image.PreserveAspectFit
        }

        // 下方文字
        Text {
            text: control.label
            font.pixelSize: 15
            color: "#5a5a5a"
            horizontalAlignment: Text.AlignHCenter
            anchors.top: img.bottom
            anchors.topMargin: 2
            anchors.horizontalCenter: parent.horizontalCenter
            elide: Text.ElideRight
        }
    }

}
