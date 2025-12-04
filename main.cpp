#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>          //用于设置上下文属性
#include <QIcon>
#include "serialmanager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // ① 设置应用窗口图标（标题栏 + 任务栏）
    app.setWindowIcon(QIcon(":/qt/qml/Qtquickdemo/png/icon.ico"));

    // 如果你把文件名叫别的，就改成对应路径
    QQmlApplicationEngine engine;

    SerialManager serial;

    // 将 C++ 对象暴露给 QML，上下文名为 "serial"
    // 之后在任意 QML 中都可以直接用 `serial.xxx` 访问
    engine.rootContext()->setContextProperty("serial", &serial);
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("Qtquickdemo", "Main");

    return app.exec();
}
