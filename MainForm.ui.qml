// MainForm.ui.qml
import QtQuick
import QtQuick.Controls

Item {
    StackView {
        id: stackView
        anchors.fill: parent
        //anchors.topMargin: header.height    // 避开 header，可视情况调整

        initialItem: "page1.qml"            // 初始页面
    }
}
