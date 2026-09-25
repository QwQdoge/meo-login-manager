/*
 * SPDX-FileCopyrightText: 2026 MeoArch contributors
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.plasma.login as PlasmaLogin

Item {
    id: root
    anchors.fill: parent

    property bool loginSucceeded: false

    // Presentation-only layer. Authentication, PAM conversation, users,
    // sessions and power actions remain owned by the existing Plasma Login
    // Manager objects instantiated by Main.qml.
    MeoGreeterTransition {
        id: transitionLayer
        anchors.fill: parent
        z: -1
        expanded: PlasmaLogin.GreeterState.activeWindow !== null
        succeeded: root.loginSucceeded
    }

    Main {
        id: greeter
        anchors.fill: parent
        z: 0
    }

    Connections {
        target: PlasmaLogin.Authenticator

        function onLoginFailed() {
            root.loginSucceeded = false;
        }

        function onLoginSucceeded() {
            root.loginSucceeded = true;
        }
    }
}
