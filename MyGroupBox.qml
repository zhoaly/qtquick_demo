// MyGroupBox.qml
import QtQuick
import QtQuick.Controls.Universal
import QtQuick.Layouts



GroupBox {
    id: control

    topPadding  : 10
    bottomPadding  : 10

    hoverEnabled: true
    // 统一的边框 + 背景样式
    background: Rectangle {
        //color: "#f7f2f4"          // 背景色
        radius: 15                // 圆角

        border.width: control.hovered ? 4 : 1

        border.color:control.hovered ? "#c48fb3"
                                     : "#e6e1e3"
        color: control.hovered ? "#fbe2ef"   // 鼠标悬浮：浅粉
                               : "#f7f2f4"                     // 普通状态：淡底色



        // 颜色和边框的过渡动画，让悬浮不生硬
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

    // 给内容区套一层 ColumnLayout，自动留内边距
    contentItem: ColumnLayout {
        id: contentLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        spacing: 5
    }



    // 关键：让在 MyGroupBox { ... } 里写的子控件，直接塞到 contentLayout 里
    // 这样你在使用处不需要再管 contentItem 的细节
    default property alias content: contentLayout.data
}
