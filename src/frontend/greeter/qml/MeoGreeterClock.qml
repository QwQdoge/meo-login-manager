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

    implicitWidth: clockText.implicitWidth
    implicitHeight: clockText.implicitHeight + dateText.implicitHeight + Kirigami.Units.largeSpacing
    opacity: active ? 1 : 0
    Accessible.role: Accessible.StaticText
    Accessible.name: i18nd("plasma_login", "Current time: %1, %2", clockText.text, dateText.text)

    MeoGreeterTheme {
        id: meoTheme
    }

    Behavior on opacity {
        OpacityAnimator {
            duration: meoTheme.durationDefault
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: Kirigami.Units.smallSpacing

        Text {
            id: clockText
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(root.currentTime, Qt.locale(), Locale.ShortFormat)
            font.family: meoTheme.brandFont
            font.pixelSize: Kirigami.Units.gridUnit * 9
            font.weight: Font.Bold
            color: meoTheme.onSurface
        }

        Text {
            id: dateText
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(root.currentTime, Qt.locale(), Locale.LongFormat)
            font.family: meoTheme.plainFont
            font.pointSize: Kirigami.Theme.defaultFont.pointSize + 3
            font.weight: Font.Medium
            color: meoTheme.onSurfaceVariant
        }
    }

    Timer {
        interval: 1000
        running: root.visible
        repeat: true
        onTriggered: root.currentTime = new Date()
    }
}
