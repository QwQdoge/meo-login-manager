/*
 * SPDX-FileCopyrightText: 2026 MeoArch contributors
 * SPDX-License-Identifier: LGPL-2.0-or-later
 *
 * Presentation-only clock for the Plasma Login greeter. It has no access to
 * user-session data, authentication state, or external providers.
 */

import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: root

    property Item shadow: null
    property bool active: true
    property date currentTime: new Date()

    implicitWidth: Math.max(clockText.implicitWidth, dateText.implicitWidth)
    implicitHeight: glyphSize * 1.84 + dateText.implicitHeight + Kirigami.Units.largeSpacing
    opacity: active ? 1 : 0
    Accessible.role: Accessible.StaticText
    Accessible.name: i18nd("plasma_login", "Current time: %1, %2", Qt.formatTime(root.currentTime, Qt.locale(), Locale.ShortFormat), dateText.text)

    MeoGreeterTheme {
        id: meoTheme
    }

    Behavior on opacity {
        OpacityAnimator {
            duration: meoTheme.durationDefault
        }
    }

    readonly property real glyphSize: Math.max(Kirigami.Units.gridUnit * 6,
                                               (root.parent ? root.parent.height : 900) * 0.2)

    Column {
        anchors.centerIn: parent
        spacing: Kirigami.Units.smallSpacing

        // Hours stacked above minutes, light and large, with a small date
        // line beneath (Googlebook-style lock/login clock).
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: -root.glyphSize * 0.16

            Text {
                id: clockText
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatTime(root.currentTime, Qt.locale().timeFormat(Locale.ShortFormat).indexOf("AP") >= 0
                                    || Qt.locale().timeFormat(Locale.ShortFormat).indexOf("ap") >= 0 ? "h" : "HH")
                font.family: meoTheme.plainFont
                font.pixelSize: root.glyphSize
                font.weight: Font.Light
                font.letterSpacing: -root.glyphSize * 0.02
                color: "white"
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatTime(root.currentTime, "mm")
                font.family: meoTheme.plainFont
                font.pixelSize: root.glyphSize
                font.weight: Font.Light
                font.letterSpacing: -root.glyphSize * 0.02
                color: "white"
            }
        }

        Text {
            id: dateText
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.locale().toString(root.currentTime, "ddd, MMM d")
            font.family: meoTheme.plainFont
            font.pointSize: Kirigami.Theme.defaultFont.pointSize + 2
            font.weight: Font.Medium
            color: "white"
        }
    }

    Timer {
        interval: 1000
        running: root.visible
        repeat: true
        onTriggered: root.currentTime = new Date()
    }
}
