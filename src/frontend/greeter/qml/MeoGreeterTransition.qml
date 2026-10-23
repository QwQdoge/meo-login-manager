/*
 * SPDX-FileCopyrightText: 2026 MeoArch contributors
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 *
 * Presentation-only backdrop for the greeter. It mirrors the lock screen: the
 * wallpaper stays prominent while ambient, a soft scrim deepens when the
 * credential area is revealed, and a short unlock glyph plays once the
 * authenticator reports success. It never triggers or infers authentication.
 */

import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: root

    property bool expanded: false
    property bool succeeded: false

    state: succeeded ? "success" : (expanded ? "expanded" : "collapsed")

    MeoGreeterTheme {
        id: meoTheme
    }

    Rectangle {
        id: scrim
        anchors.fill: parent
        color: meoTheme.scrim
        opacity: 0.06
    }

    Kirigami.Icon {
        id: unlockIcon
        anchors.centerIn: parent
        width: Math.max(Kirigami.Units.iconSizes.enormous, Math.min(root.width, root.height) * 0.12)
        height: width
        source: "object-unlocked"
        color: meoTheme.success
        opacity: 0
        scale: 0.8
    }

    states: [
        State {
            name: "collapsed"
            PropertyChanges {
                target: scrim
                opacity: 0.06
            }
            PropertyChanges {
                target: unlockIcon
                opacity: 0
                scale: 0.8
            }
        },
        State {
            name: "expanded"
            PropertyChanges {
                target: scrim
                opacity: 0.38
            }
            PropertyChanges {
                target: unlockIcon
                opacity: 0
                scale: 0.8
            }
        },
        State {
            name: "success"
            PropertyChanges {
                target: scrim
                opacity: 0.38
            }
            PropertyChanges {
                target: unlockIcon
                opacity: 1
                scale: 1
            }
        }
    ]

    transitions: [
        Transition {
            from: "collapsed"
            to: "expanded"

            NumberAnimation {
                target: scrim
                property: "opacity"
                duration: meoTheme.durationSpatial
                easing.type: Easing.BezierSpline
                easing.bezierCurve: meoTheme.easingEmphasizedDecelerate
            }
        },
        Transition {
            from: "expanded"
            to: "collapsed"

            NumberAnimation {
                target: scrim
                property: "opacity"
                duration: meoTheme.durationExit
                easing.type: Easing.BezierSpline
                easing.bezierCurve: meoTheme.easingStandard
            }
        },
        Transition {
            to: "success"

            ParallelAnimation {
                NumberAnimation {
                    target: unlockIcon
                    property: "scale"
                    duration: meoTheme.durationExit
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: meoTheme.easingEmphasized
                }
                NumberAnimation {
                    target: unlockIcon
                    property: "opacity"
                    duration: meoTheme.durationFast
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: meoTheme.easingStandardDecelerate
                }
            }
        }
    ]
}
