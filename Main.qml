import QtQuick
// import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Universal
ApplicationWindow  {

    id : root
    width: 860
    height: 610
    visible: true
    //flags: Qt.FramelessWindowHint // 无边框模式
    title: qsTr("ApplicationWindow 区域示例")

    //========================
    // 统一定义 Action（命令）
    //========================
    // 文件相关
    Action {
        id: openAction
        text: qsTr("&Open...")
        onTriggered: console.log("Open triggered")
    }

    Action {
        id: exitAction
        text: qsTr("E&xit")
        onTriggered: Qt.quit()
    }

    // 工具栏按钮相关（Home / Settings）
    Action {
        id: homeAction
        text: qsTr("Home")
        onTriggered: console.log("Home clicked")
    }

    Action {
        id: settingsAction
        text: qsTr("Settings")
        onTriggered: console.log("Settings clicked")
    }

    // 背景区域
    background: Rectangle {
        color: "#ffffff"
    }

    // 顶部菜单栏
    menuBar: MenuBar {
        id: menu
        background: Rectangle {
            color: "#ffffff"        // 菜单栏背景色
        }

        // 第一个菜单：&File
        Menu {
            title: qsTr("&File")

            MenuItem { action: openAction }

            MenuSeparator { }

            // 三个相同的 Exit 菜单项（都复用同一个 exitAction）
            MenuItem { action: exitAction }
            MenuSeparator { }
            MenuItem { action: exitAction }
            MenuSeparator { }
            MenuItem { action: exitAction }
        }

        // 第二个菜单：文件（同样复用 openAction / exitAction）
        Menu {
            title: qsTr("文件")

            MenuItem { action: openAction }

            MenuSeparator { }

            MenuItem { action: exitAction }
            MenuSeparator { }
            MenuItem { action: exitAction }
            MenuSeparator { }
            MenuItem { action: exitAction }
        }
    }

    // 页眉：工具栏
    header: ToolBar {
        background: Rectangle {
            color: "#ffffff"        // 工具栏背景色
        }

        RowLayout {
            anchors.fill: parent

            ToolButton {
                background: Rectangle { color: "#ffffff" }
                action: homeAction          // 使用 Home 命令
            }
            ToolSeparator { }

            ToolButton {
                background: Rectangle { color: "#ffffff" }
                action: settingsAction      // Settings 1
            }
            ToolSeparator { }

            ToolButton {
                background: Rectangle { color: "#ffffff" }
                action: settingsAction      // Settings 2（复用同一 Action）
            }
            ToolSeparator { }

            ToolButton {
                background: Rectangle { color: "#ffffff" }
                action: settingsAction      // Settings 3（复用同一 Action）
            }
            ToolSeparator { }

            Item { Layout.fillWidth: true } // 使各个项目左对齐
        }
    }

    // 页脚：状态栏
    footer: ToolBar {
        background: Rectangle {
            color: "#ffffff"        // 状态栏背景色
        }
        RowLayout {
            anchors.fill: parent

            Label {
                text: qsTr("Status: Ready")
            }

            Item { Layout.fillWidth: true }

            Label {
                text: qsTr("Footer Area")
            }
        }
    }

    // 内容区：主界面
    MainForm {
        id: mainForm
        anchors.fill: parent    // 填满内容区域
    }
}
