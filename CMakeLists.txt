cmake_minimum_required(VERSION 3.16)

project(Qtquickdemo VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick SerialPort)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appQtquickdemo
    main.cpp
    serialmanager.cpp
)

qt_add_qml_module(appQtquickdemo
    URI Qtquickdemo
    VERSION 1.0
    QML_FILES
        Main.qml
        QML_FILES MainForm.ui.qml
        QML_FILES page1.qml
        QML_FILES MyGroupBox.qml
        QML_FILES MyComboBox.qml
        QML_FILES MyCheckBox.qml
        QML_FILES MyButton.qml
        QML_FILES MyTextField.qml
        SOURCES serialmanager.h
        SOURCES serialmanager.cpp
        QML_FILES
        QML_FILES page2.qml
        QML_FILES SideTabButton.qml
        RESOURCES png/png_connect.png
        RESOURCES png/logo.png
        RESOURCES png/文件夹.png
        RESOURCES png/用户.png
        RESOURCES png/管理.png
        RESOURCES png/流转.png
        RESOURCES png/应用场景.png
        RESOURCES png/icon.ico

)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appQtquickdemo PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appQtquickdemo
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appQtquickdemo
    PRIVATE
    Qt6::Quick
    Qt6::SerialPort
)

include(GNUInstallDirs)
install(TARGETS appQtquickdemo
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
