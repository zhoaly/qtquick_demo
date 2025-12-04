// MainForm.ui.qml
import QtQuick
import QtQuick.Controls
// 一定要有这句
import QtQuick.Controls.Universal
import QtQuick.Layouts

Item {
    anchors.fill: parent

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // 右侧竖直 TabBar
        TabBar {
            id: tabBar
            Layout.fillHeight: true // 一定要占满高度
            implicitWidth: 80 // 直接指定隐式宽度
            currentIndex: 1
            background: Rectangle {
                anchors.fill: parent
                color: "#f1edee" // 整个右侧条的底色

                radius: 0 // 不需要圆角可以设为 0
            }



            // 关键：只重写 contentItem，TabButton 仍然是 TabBar 的子项
            contentItem: ListView {
                spacing: 0
                anchors.fill: parent
                anchors.topMargin: 10
                model: tabBar.contentModel
                currentIndex: tabBar.currentIndex
                orientation: ListView.Vertical
                interactive: false
                clip: true
            }

            // ====== 下面是 Tab 按钮（注意：是 TabBar 的直接子项）======

            // logo
            SideTabButton {
                id: logo
                //label: qsTr("页面1")

                iconSource: "png/logo.png"

                blockHeight: 60
                iconSize : 60
                backgroundcolor:"#e6e1e3"
                backgroundopacity:1
            }



            // Tab1
            SideTabButton {
                id: tabPage1
                label: qsTr("连接")
                //checked: true

                iconSource: "png/png_connect.png"

                onClicked: stackView.replace("page1.qml")
            }

            // Tab2 示例
            SideTabButton {
                id: tabPage2
                label: qsTr("管理")

                iconSource: "png/管理.png"
                onClicked: stackView.replace("page2.qml")
            }
            SideTabButton {
                id: tabPage3
                label: qsTr("流转")

                iconSource: "png/流转.png"
                //onClicked: stackView.replace("page1.qml")
            }
            SideTabButton {
                id: tabPage4
                label: qsTr("应用")

                iconSource: "png/应用场景.png"
                //onClicked: stackView.replace("page1.qml")
            }
            SideTabButton {
                id: tabPage5
                label: qsTr("用户")

                iconSource: "png/用户.png"
                //onClicked: stackView.replace("page1.qml")
            }

        }

        // 左侧内容区
        StackView {
            id: stackView
            Layout.fillWidth: true
            Layout.fillHeight: true

            background: Rectangle{
                anchors.fill: parent
                color: "#fdf8fa"
            }

            initialItem: "page1.qml"
        }
    }



}
