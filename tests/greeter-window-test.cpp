// SPDX-License-Identifier: BSD-2-Clause
#include "greetereventfilter.h"
#include <QKeyEvent>
#include <QSignalSpy>
#include <QtTest>

class GreeterWindowTest : public QObject
{
    Q_OBJECT
private Q_SLOTS:
    void isolatesWindows()
    {
        QQuickWindow first, second;
        GreeterEventFilter a, b;
        a.setWindow(&first);
        b.setWindow(&second);
        QSignalSpy firstKeys(&a, &GreeterEventFilter::keyPressed);
        QSignalSpy secondKeys(&b, &GreeterEventFilter::keyPressed);
        QKeyEvent key(QEvent::KeyPress, Qt::Key_A, Qt::NoModifier);
        QCoreApplication::sendEvent(&first, &key);
        QCOMPARE(firstKeys.count(), 1);
        QCOMPARE(secondKeys.count(), 0);
        a.setWindow(&second);
        QCoreApplication::sendEvent(&first, &key);
        QCOMPARE(firstKeys.count(), 1);
        QCoreApplication::sendEvent(&second, &key);
        QCOMPARE(firstKeys.count(), 2);
        QCOMPARE(secondKeys.count(), 1);
        a.setWindow(nullptr);
        QCoreApplication::sendEvent(&second, &key);
        QCOMPARE(firstKeys.count(), 2);
        QCOMPARE(secondKeys.count(), 2);
    }
    void clearsDestroyedWindow()
    {
        GreeterEventFilter filter;
        auto *window = new QQuickWindow;
        filter.setWindow(window);
        delete window;
        QCOMPARE(filter.window(), nullptr);
        QQuickWindow replacement;
        filter.setWindow(&replacement);
        QCOMPARE(filter.window(), &replacement);
    }
};
QTEST_MAIN(GreeterWindowTest)
#include "greeter-window-test.moc"
