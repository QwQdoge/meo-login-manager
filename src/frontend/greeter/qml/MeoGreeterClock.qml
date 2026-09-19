/*
 * SPDX-FileCopyrightText: 2026 MeoArch contributors
 * SPDX-License-Identifier: LGPL-2.0-or-later
 *
 * Presentation-only clock for the Plasma Login greeter.  It deliberately has
 * no access to user session data, authentication state, or any provider.
 */

import QtQuick

import org.kde.kirigami as Kirigami

Item {
    id: root

    // Keep the local upstream clock/shadow hand-off so wallpaper integrations
    // can continue treating this as a normal greeter clock item.
    property Item shadow: null
    property bool active: true
    property date currentTime: new Date()

    implicitWidth: clockText.implicitWidth
    implicitHeight: clockText.implicitHeight + dateText.implicitHeight + Kirigami.Units.largeSpacing
    opacity: active ? 1 : 0
    Accessible.role: Accessible.StaticText
    // Keep the spoken label in the greeter translation domain. The visible
    // values below follow the system locale, including its date and clock
    // conventions, so assistive technology receives the same information.
    Accessible.name: i18nd("plasma_login", "Current time: %1, %2", clockText.text, dateText.text)

    Behavior on opacity {
        OpacityAnimator {
            duration: 250
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: Kirigami.Units.smallSpacing

        Text {
            id: clockText
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(root.currentTime, Qt.locale(), Locale.ShortFormat)
            font.family: Kirigami.Theme.defaultFont.family
            font.pixelSize: Kirigami.Units.gridUnit * 9
            font.weight: Font.DemiBold
            color: Kirigami.Theme.textColor
        }

        Text {
            id: dateText
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(root.currentTime, Qt.locale(), Locale.LongFormat)
            font.family: Kirigami.Theme.defaultFont.family
            font.pointSize: Kirigami.Theme.defaultFont.pointSize + 3
            font.weight: Font.DemiBold
            color: Kirigami.Theme.disabledTextColor
        }
    }

    Timer {
        interval: 1000
        running: root.visible
        repeat: true
        onTriggered: root.currentTime = new Date()
    }
}
