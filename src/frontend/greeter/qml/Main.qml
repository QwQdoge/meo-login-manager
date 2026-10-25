/*
 * SPDX-FileCopyrightText: Oliver Beard
 * SPDX-FileCopyrightText: David Edmundson
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import Qt5Compat.GraphicalEffects

import org.kde.kirigami as Kirigami
import org.kde.breeze.components as BreezeComponents
import org.kde.plasma.private.keyboardindicator as KeyboardIndicator
import org.kde.plasma.workspace.keyboardlayout as Keyboards
import org.kde.plasma.workspace.loginlockscreen as LoginLockScreen

import org.kde.plasma.login as PlasmaLogin

Item {
    id: root
    anchors.fill: parent

    // If we're using software rendering, draw outlines instead of shadows
    // See https://bugs.kde.org/show_bug.cgi?id=398317
    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software

    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    Kirigami.Theme.inherit: false

    property string notificationMessage
    property string pendingPowerAction: ""

    function confirmPower(action) {
        PlasmaLogin.GreeterState.clearPasswords()
        pendingPowerAction = action
        powerConfirmation.open()
    }

    QQC2.Dialog {
        id: powerConfirmation
        anchors.centerIn: parent
        modal: true
        title: root.pendingPowerAction === "sleep" ? i18nd("plasma_login", "Sleep")
             : root.pendingPowerAction === "hibernate" ? i18nd("plasma_login", "Hibernate")
             : root.pendingPowerAction === "reboot" ? i18nd("plasma_login", "Restart")
             : i18nd("plasma_login", "Shut Down")
        standardButtons: QQC2.Dialog.Ok | QQC2.Dialog.Cancel
        onAccepted: {
            const action = root.pendingPowerAction
            root.pendingPowerAction = ""
            if (action === "sleep") PlasmaLogin.SessionManagement.suspend()
            else if (action === "hibernate") PlasmaLogin.SessionManagement.hibernate()
            else if (action === "reboot") PlasmaLogin.SessionManagement.requestReboot(PlasmaLogin.SessionManagement.ConfirmationMode.Skip)
            else if (action === "shutdown") PlasmaLogin.SessionManagement.requestShutdown(PlasmaLogin.SessionManagement.ConfirmationMode.Skip)
        }
        onRejected: root.pendingPowerAction = ""
    }

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    KeyboardIndicator.KeyState {
        id: capsLockState
        key: Qt.Key_CapsLock
    }

    BreezeComponents.RejectPasswordAnimation {
        id: rejectPasswordAnimation
        target: mainStack
    }

    PlasmaLogin.GreeterEventFilter {
        window: root.Window.window

        onKeyPressed: {
            // callLater, as otherwise 'enter' key press would arrive after waking
            // and the uiVisible check would pass and a login attempt would be made
            Qt.callLater(() => PlasmaLogin.GreeterState.activateWindow(loginScreenRoot.Window.window));
        }

        onEscapeKeyPressed: {
            PlasmaLogin.GreeterState.timeoutWindow(loginScreenRoot.Window.window);
            if (Keyboards.KWinVirtualKeyboard.visible) {
                Keyboards.KWinVirtualKeyboard.active = false;
            }
            PlasmaLogin.GreeterState.clearPasswords();
        }
    }

    MouseArea {
        id: loginScreenRoot
        anchors.fill: parent

        hoverEnabled: true

        property bool uiVisible: PlasmaLogin.GreeterState.activeWindow === Window.window

        cursorShape: uiVisible ? Qt.ArrowCursor : Qt.BlankCursor

        onPressed: PlasmaLogin.GreeterState.activateWindow(Window.window);
        onPositionChanged: PlasmaLogin.GreeterState.activateWindow(Window.window);

        DropShadow {
            id: clockShadow
            anchors.fill: clock
            source: clock
            visible: !softwareRendering && clock.visible
            radius: 7
            verticalOffset: 0.8
            samples: 15
            spread: 0.2
            color: Qt.rgba(0, 0, 0, 0.7)
            opacity: 1
            Behavior on opacity {
                OpacityAnimator {
                    duration: Kirigami.Units.veryLongDuration * 2
                    easing.type: Easing.InOutQuad
                }
            }
        }

        MeoGreeterClock {
            id: clock
            shadow: clockShadow
            visible: Settings.showClock
            active: true
            anchors.horizontalCenter: parent.horizontalCenter
            // Ambient: clock sits in the upper-middle of the wallpaper.
            // Credentials revealed: it lifts slightly to make room for the
            // sign-in area at the bottom, as on the lock screen.
            y: parent.height * (loginScreenRoot.uiVisible ? 0.12 : 0.22)

            Behavior on y {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.OutCubic
                }
            }
        }

        // Ambient hint: lock glyph and a single line, hidden once the
        // credential area is revealed.
        Column {
            id: ambientHint
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Math.max(Kirigami.Units.gridUnit * 2, parent.height * 0.045)
            spacing: Kirigami.Units.largeSpacing
            opacity: loginScreenRoot.uiVisible ? 0 : 1
            visible: opacity > 0.001

            Behavior on opacity {
                OpacityAnimator {
                    duration: Kirigami.Units.longDuration
                }
            }

            Kirigami.Icon {
                anchors.horizontalCenter: parent.horizontalCenter
                width: Kirigami.Units.iconSizes.medium
                height: width
                source: "system-lock-screen"
                color: "white"
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: i18nd("plasma_login", "Press any key or click to sign in")
                color: "white"
                font.pointSize: Kirigami.Theme.defaultFont.pointSize
                font.weight: Font.Medium
                style: Text.Outline
                styleColor: Qt.rgba(0, 0, 0, 0.35)
            }
        }

        QQC2.StackView {
            id: mainStack
            anchors.left: parent.left
            anchors.right: parent.right

            // Sign-in area lives in the lower part of the screen; the
            // session screen centres its avatar and password row inside it.
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Kirigami.Units.gridUnit * 3
            height: Math.min(root.height * 0.46, Kirigami.Units.gridUnit * 26)

            hoverEnabled: true

            focus: true

            opacity: loginScreenRoot.uiVisible ? 1 : 0
            Behavior on opacity {
                OpacityAnimator {
                    duration: Kirigami.Units.longDuration
                }
            }

            Connections {
                target: PlasmaLogin.GreeterState

                function onLoginStateChanged() {
                    switch (PlasmaLogin.GreeterState.loginState) {
                        case PlasmaLogin.GreeterState.LoginState.UserList:
                            if (mainStack.depth !== 2) { return; /* already showing user list */ }
                            mainStack.pop();
                            return;
                        case PlasmaLogin.GreeterState.LoginState.UserPrompt:
                            if (mainStack.depth !== 1) { return; /* already showing user prompt */ }
                            mainStack.push(userPromptComponent);
                            return;
                        default:
                            console.warn("Cannot synchronize login state:", PlasmaLogin.GreeterState.loginState);
                    }
                }
            }

            initialItem: Login {
                id: userListComponent
                userListModel: PlasmaLogin.UserModel
                loginScreenUiVisible: loginScreenRoot.uiVisible
                userListCurrentIndex: {
                    // indexOfData will return -1 if passed an empty string, which these are by default
                    let preselectedUserIndex = PlasmaLogin.UserModel.indexOfData(PlasmaLogin.Settings.preselectedUser, PlasmaLogin.UserModel.NameRole);
                    let lastLoggedInUserIndex = PlasmaLogin.UserModel.indexOfData(PlasmaLogin.StateConfig.lastLoggedInUser, PlasmaLogin.UserModel.NameRole);

                    if (preselectedUserIndex != -1) {
                        return preselectedUserIndex;
                    } else if (lastLoggedInUserIndex != -1) {
                        return lastLoggedInUserIndex;
                    } else {
                        return 0;
                    }
                }

                showUserList: !PlasmaLogin.GreeterState.beyondUserLimit

                notificationMessage: {
                    const parts = [];
                    if (capsLockState.locked) {
                        parts.push(i18nd("plasma_login", "Caps Lock is on"));
                    }
                    if (root.notificationMessage) {
                        parts.push(root.notificationMessage);
                    }
                    return parts.join(" • ");
                }

                //actionItemsVisible: !inputPanel.keyboardActive
                actionItems: [
                    BreezeComponents.ActionButton {
                        icon.name: "system-hibernate"
                        text: i18ndc("plasma_login", "Suspend to disk", "Hibernate")
                        visible: PlasmaLogin.SessionManagement.canHibernate
                        onClicked: {
                            root.confirmPower("hibernate")
                        }
                    },
                    BreezeComponents.ActionButton {
                        icon.name: "system-suspend"
                        text: i18ndc("plasma_login", "Suspend to RAM", "Sleep")
                        visible: PlasmaLogin.SessionManagement.canSuspend
                        onClicked: {
                            root.confirmPower("sleep")
                        }
                    },
                    BreezeComponents.ActionButton {
                        icon.name: "system-reboot"
                        text: i18nd("plasma_login", "Restart")
                        visible: PlasmaLogin.SessionManagement.canReboot
                        onClicked: root.confirmPower("reboot")
                    },
                    BreezeComponents.ActionButton {
                        icon.name: "system-shutdown"
                        text: i18nd("plasma_login", "Shut Down")
                        visible: PlasmaLogin.SessionManagement.canShutdown
                        onClicked: root.confirmPower("shutdown")
                    },
                    BreezeComponents.ActionButton {
                        icon.name: "system-user-prompt"
                        text: i18ndc("plasma_login", "For switching to a username and password prompt", "Other…")
                        onClicked: PlasmaLogin.GreeterState.loginState = PlasmaLogin.GreeterState.LoginState.UserPrompt
                        visible: !userListComponent.showUsernamePrompt
                    }]

                onLoginRequest: (username, password) => root.handleLoginRequest(username, password)
            }

            readonly property real zoomFactor: 1.5

            popEnter: Transition {
                ScaleAnimator {
                    from: mainStack.zoomFactor
                    to: 1
                    duration: Kirigami.Units.veryLongDuration
                    easing.type: Easing.OutCubic
                }
                OpacityAnimator {
                    from: 0
                    to: 1
                    duration: Kirigami.Units.veryLongDuration
                    easing.type: Easing.OutCubic
                }
            }

            popExit: Transition {
                ScaleAnimator {
                    from: 1
                    to: 1 / mainStack.zoomFactor
                    duration: Kirigami.Units.veryLongDuration
                    easing.type: Easing.OutCubic
                }
                OpacityAnimator {
                    from: 1
                    to: 0
                    duration: Kirigami.Units.veryLongDuration
                    easing.type: Easing.OutCubic
                }
            }

            pushEnter: Transition {
                ScaleAnimator {
                    from: 1 / mainStack.zoomFactor
                    to: 1
                    duration: Kirigami.Units.veryLongDuration
                    easing.type: Easing.OutCubic
                }
                OpacityAnimator {
                    from: 0
                    to: 1
                    duration: Kirigami.Units.veryLongDuration
                    easing.type: Easing.OutCubic
                }
            }

            pushExit: Transition {
                ScaleAnimator {
                    from: 1
                    to: mainStack.zoomFactor
                    duration: Kirigami.Units.veryLongDuration
                    easing.type: Easing.OutCubic
                }
                OpacityAnimator {
                    from: 1
                    to: 0
                    duration: Kirigami.Units.veryLongDuration
                    easing.type: Easing.OutCubic
                }
            }
        }

        Component {
            id: userPromptComponent

            Login {
                showUsernamePrompt: true
                loginScreenUiVisible: loginScreenRoot.uiVisible
                fontSize: Kirigami.Theme.defaultFont.pointSize + 2

                notificationMessage: {
                    const parts = [];
                    if (capsLockState.locked) {
                        parts.push(i18nd("plasma_login", "Caps Lock is on"));
                    }
                    if (root.notificationMessage) {
                        parts.push(root.notificationMessage);
                    }
                    return parts.join(" • ");
                }

                // using a model rather than a QObject list to avoid QTBUG-75900
                userListModel: ListModel {
                    ListElement {
                        realName: ""
                        icon: ""
                    }
                    Component.onCompleted: {
                        // as we can't bind inside ListElement
                        setProperty(0, "realName", i18nd("plasma_login", "Type in Username and Password"));
                        setProperty(0, "icon", Qt.resolvedUrl(".face.icon").toString());
                    }
                }

                onLoginRequest: (username, password) => root.handleLoginRequest(username, password)

                //actionItemsVisible: !inputPanel.keyboardActive
                actionItems: [
                    BreezeComponents.ActionButton {
                        icon.name: "system-hibernate"
                        text: i18ndc("plasma_login", "Suspend to disk", "Hibernate")
                        visible: PlasmaLogin.SessionManagement.canHibernate
                        onClicked: {
                            root.confirmPower("hibernate")
                        }
                    },
                    BreezeComponents.ActionButton {
                        icon.name: "system-suspend"
                        text: i18ndc("plasma_login", "Suspend to RAM", "Sleep")
                        visible: PlasmaLogin.SessionManagement.canSuspend
                        onClicked: {
                            root.confirmPower("sleep")
                        }
                    },
                    BreezeComponents.ActionButton {
                        icon.name: "system-reboot"
                        text: i18nd("plasma_login", "Restart")
                        visible: PlasmaLogin.SessionManagement.canReboot
                        onClicked: root.confirmPower("reboot")
                    },
                    BreezeComponents.ActionButton {
                        icon.name: "system-shutdown"
                        text: i18nd("plasma_login", "Shut Down")
                        visible: PlasmaLogin.SessionManagement.canShutdown
                        onClicked: root.confirmPower("shutdown")
                    },
                    BreezeComponents.ActionButton {
                        icon.name: "system-user-list"
                        text: i18nd("plasma_login", "List Users")
                        onClicked: PlasmaLogin.GreeterState.loginState = PlasmaLogin.GreeterState.LoginState.UserList
                    }
                ]
            }
        }

        LoginLockScreen.Footer {
            id: footer

            opacity: loginScreenRoot.uiVisible ? 1 : 0
            visible: opacity > 0.001

            Behavior on opacity {
                OpacityAnimator {
                    duration: Kirigami.Units.longDuration
                }
            }

            onOskActivated: {
                userListComponent.mainPasswordBox.forceActiveFocus();
            }
        }
    }

    function handleLoginRequest(username, password) {
        root.notificationMessage = "";
        // GreeterState handles updating stateconfig with user/session of successful login
        PlasmaLogin.GreeterState.handleLoginRequest(username, password);
    }

    Connections {
        target: PlasmaLogin.Authenticator

        // e.g. pam_u2f's "cue" asking the user to touch their key. Not auto-cleared
        // like "Login Failed" is: handleLoginRequest() clears it on the next attempt.
        function onInformationMessage(message) {
            // A reset pending from an earlier failure would clear this one early.
            notificationResetTimer.stop();
            notificationMessage = message;
        }

        function onLoginFailed() {
            notificationMessage = i18nd("plasma_login", "Login Failed");
            // Only failures time out; started here rather than on every change.
            notificationResetTimer.start();

            footer.enabled = true;
            mainStack.enabled = true;
            userListComponent.userList.opacity = 1;

            rejectPasswordAnimation.start();
        }

        function onLoginSucceeded() {
            mainStack.opacity = 0;
            footer.opacity = 0;
        }
    }

    Timer {
        id: notificationResetTimer
        interval: 3000
        onTriggered: notificationMessage = ""
    }
}
