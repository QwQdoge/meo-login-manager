/*
 * SPDX-FileCopyrightText: Oliver Beard
 * SPDX-FileCopyrightText: David Edmundson
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import org.kde.breeze.components

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2

import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.login as PlasmaLogin
import MeoUI 1.0

SessionManagementScreen {
    id: root
    property Item mainPasswordBox: passwordBox

    property bool showUsernamePrompt: !showUserList

    property bool loginScreenUiVisible: false
    property string statusMessage: ""
    property bool authenticationFailed: false
    property bool submitting: false

    // SessionManagementScreen's upstream status label stays empty; MeoUI
    // presents the same message inside the authentication surface instead.
    notificationMessage: ""

    //the y position that should be ensured visible when the on screen keyboard is visible
    property int visibleBoundary: mapFromItem(loginButton, 0, 0).y
    onHeightChanged: visibleBoundary = mapFromItem(loginButton, 0, 0).y + loginButton.height + Kirigami.Units.smallSpacing

    property real fontSize: Kirigami.Theme.defaultFont.pointSize

    signal loginRequest(string username, string password)

    onUserSelected: {
        // Don't startLogin() here, because the signal is connected to the
        // Escape key as well, for which it wouldn't make sense to trigger
        // login.
        passwordBox.clear();
        authenticationFailed = false;
        submitting = false;
        focusFirstVisibleFormControl();
    }

    QQC2.StackView.onActivating: {
        // Controls are not visible yet.
        Qt.callLater(focusFirstVisibleFormControl);
    }

    function focusFirstVisibleFormControl() {
        const nextControl = (userNameInput.visible && !userNameInput.text
            ? userNameInput
            : (passwordBox.visible
                ? passwordBox
                : loginButton));
        // Using TabFocusReason, so that the loginButton gets the visual highlight.
        nextControl.forceActiveFocus(Qt.TabFocusReason);
    }

    /*
     * Login has been requested with the following username and password
     * If username field is visible, it will be taken from that, otherwise from the "name" property of the currentIndex
     */
    function startLogin() {
        const username = showUsernamePrompt ? userNameInput.text : userList.selectedUser
        const password = passwordBox.text

        authenticationFailed = false
        submitting = true
        footer.enabled = false
        mainStack.enabled = false
        userListComponent.userList.opacity = 0.75

        // This is partly because it looks nicer, but more importantly it
        // works round a Qt bug that can trigger if the app is closed with a
        // TextField focused.
        //
        // See https://bugreports.qt.io/browse/QTBUG-55460
        loginButton.forceActiveFocus();
        loginRequest(username, password);
    }

    MeoAuthenticationSurface {
        id: authenticationSurface
        Layout.fillWidth: true
        Layout.minimumWidth: 320 * MeoTheme.globalScale
        Layout.maximumWidth: 440 * MeoTheme.globalScale
        active: root.loginScreenUiVisible
        title: i18nd("plasma_login", "Log In")
        supportingText: root.showUsernamePrompt
                        ? i18nd("plasma_login", "Type in Username and Password")
                        : ""
        status: root.submitting ? "submitting"
                               : root.authenticationFailed ? "failed"
                                                           : "password"
        statusText: root.authenticationFailed ? "" : root.statusMessage
        errorText: root.authenticationFailed ? root.statusMessage : ""

        MeoTextField {
            id: userNameInput
            Layout.fillWidth: true
            size: "m"
            text: ""
            visible: root.showUsernamePrompt
            focus: root.showUsernamePrompt
            label: i18nd("plasma_login", "Username")
            placeholder: label
            leadingIcon: "person"

            onAccepted: {
                if (root.loginScreenUiVisible)
                    passwordBox.forceActiveFocus()
            }
        }

        MeoTextField {
            id: passwordBox
            Layout.fillWidth: true
            size: "m"
            label: i18nd("plasma_login", "Password")
            placeholder: label
            leadingIcon: "lock"
            isPassword: true
            focus: !root.showUsernamePrompt
            enabled: !root.submitting

            onAccepted: {
                if (root.loginScreenUiVisible)
                    startLogin()
            }

            visible: root.showUsernamePrompt || userList.currentItem.needsPassword

            Keys.onEscapePressed: {
                mainStack.currentItem.forceActiveFocus()
            }

            // If empty, left/right still switches the selected Plasma user.
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Left && !text) {
                    userList.decrementCurrentIndex()
                    event.accepted = true
                }
                if (event.key === Qt.Key_Right && !text) {
                    userList.incrementCurrentIndex()
                    event.accepted = true
                }
            }
        }

        MeoButton {
            id: loginButton
            Layout.fillWidth: true
            size: "m"
            type: "filled"
            text: i18nd("plasma_login", "Log In")
            icon.name: "login"
            loading: root.submitting
            enabled: !root.submitting
            Accessible.name: text
            onClicked: startLogin()
            Keys.onEnterPressed: clicked()
            Keys.onReturnPressed: clicked()
        }
    }

    Connections {
        target: PlasmaLogin.Authenticator

        function onLoginFailed() {
            root.submitting = false
            root.authenticationFailed = true
            authenticationSurface.triggerFailure()
            passwordBox.selectAll()
            passwordBox.forceActiveFocus()
        }

        function onLoginSucceeded() {
            root.submitting = false
        }
    }

    // Synchronise state
    Item {
        id: sync

        readonly property bool isUserList: root.showUserList && !root.showUsernamePrompt

        // Login initial state
        Component.onCompleted: {
            if (sync.isUserList) {
                root.userList.currentIndex = PlasmaLogin.GreeterState.userListIndex;
                passwordBox.text = PlasmaLogin.GreeterState.userListPassword;
            } else {
                userNameInput.text = PlasmaLogin.StateConfig.lastLoggedInUser;
                passwordBox.text = PlasmaLogin.GreeterState.userPromptPassword;
                focusFirstVisibleFormControl();
            }

            passwordBox.passwordVisible = PlasmaLogin.GreeterState.showPassword;
        }

        // Login -> GreeterState
        Connections {
            target: root.userList

            function onCurrentIndexChanged() {
                if (!sync.isUserList) {
                    return;
                }

                if (PlasmaLogin.GreeterState.userListIndex != root.userList.currentIndex) {
                    PlasmaLogin.GreeterState.userListIndex = root.userList.currentIndex;
                }
            }
        }

        Connections {
            target: userNameInput

            function onTextChanged() {
                if (!sync.isUserList) {
                    if (PlasmaLogin.GreeterState.userPromptUsername != userNameInput.text) {
                        PlasmaLogin.GreeterState.userPromptUsername = userNameInput.text;
                    }
                }
            }
        }

        Connections {
            target: passwordBox

            function onTextChanged() {
                if (sync.isUserList) {
                    if (PlasmaLogin.GreeterState.userListPassword != passwordBox.text) {
                        PlasmaLogin.GreeterState.userListPassword = passwordBox.text;
                    }
                } else {
                    if (PlasmaLogin.GreeterState.userPromptPassword != passwordBox.text) {
                        PlasmaLogin.GreeterState.userPromptPassword = passwordBox.text;
                    }
                }
            }

            function onShowPasswordChanged() {
                if (PlasmaLogin.GreeterState.showPassword != passwordBox.passwordVisible) {
                    PlasmaLogin.GreeterState.showPassword = passwordBox.passwordVisible;
                }
            }
        }

        // GreeterState -> Login
        Connections {
            target: PlasmaLogin.GreeterState

            function onUserListIndexChanged() {
                if (!sync.isUserList) {
                    return;
                }

                if (root.userList.currentIndex != PlasmaLogin.GreeterState.userListIndex) {
                    root.userList.currentIndex = PlasmaLogin.GreeterState.userListIndex;
                }
            }

            function onUserListPasswordChanged() {
                if (!sync.isUserList) {
                    return;
                }

                if (passwordBox.text != PlasmaLogin.GreeterState.userListPassword) {
                    passwordBox.text = PlasmaLogin.GreeterState.userListPassword;
                }
            }

            function onUserPromptUsernameChanged() {
                if (sync.isUserList) {
                    return;
                }

                if (userNameInput.text != PlasmaLogin.GreeterState.userPromptUsername) {
                    userNameInput.text = PlasmaLogin.GreeterState.userPromptUsername;
                }
            }

            function onUserPromptPasswordChanged() {
                if (sync.isUserList) {
                    return;
                }

                if (passwordBox.text != PlasmaLogin.GreeterState.userPromptPassword) {
                    passwordBox.text = PlasmaLogin.GreeterState.userPromptPassword;
                }
            }

            function onShowPasswordChanged() {
                if (passwordBox.passwordVisible != PlasmaLogin.GreeterState.showPassword) {
                    passwordBox.passwordVisible = PlasmaLogin.GreeterState.showPassword;
                }
            }
        }
    }
}
