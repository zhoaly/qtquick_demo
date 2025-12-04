import QtQuick
// import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Universal
import QtQuick.Window

ApplicationWindow  {

    id : root
    width: 860
    height: 500
    visible: true
    flags :Qt.Window
         | Qt.WindowTitleHint
         | Qt.WindowMinimizeButtonHint
         | Qt.WindowMaximizeButtonHint
         | Qt.WindowCloseButtonHint
         // | Qt.WindowStaysOnTopHint


    // 内容区：主界面
    MainForm {
        id: mainForm
        anchors.fill: parent    // 填满内容区域
    }
}
