/*
 * SPDX-FileCopyrightText: 2026 MeoArch contributors
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: root

    property bool expanded: false
    property bool succeeded: false

    readonly property real collapsedSize: Math.max(112, Math.min(width, height) * 0.14)
    readonly property real expandedWidth: Math.min(width * 0.74, 980)
    readonly property real expandedHeight: Math.min(height * 0.72, 720)
    readonly property real collapsedRadius: collapsedSize / 4
    readonly property real expandedRadius: Math.max(36, Kirigami.Units.gridUnit * 2.4)

    state: succeeded ? "success" : (expanded ? "expanded" : "collapsed")

    MeoGreeterTheme {
        id: meoTheme
    }

    Rectangle {
        id: scrim
        anchors.fill: parent
        color: meoTheme.scrim
        opacity: 0.10
    }

    Rectangle {
        id: surface
        anchors.centerIn: parent
        width: root.collapsedSize
        height: root.collapsedSize
        radius: root.collapsedRadius
        rotation: 180
        scale: 0.94
        opacity: 0.94
        color: meoTheme.surfaceContainerHigh
        border.width: 1
        border.color: meoTheme.outlineVariant

        Kirigami.Icon {
            id: lockIcon
            anchors.centerIn: parent
            width: Math.min(parent.width, parent.height) * 0.42
            height: width
            source: "system-lock-screen"
            color: meoTheme.onSurface
            opacity: 1
            rotation: -surface.rotation
        }
    }

    states: [
        State {
            name: "collapsed"
            PropertyChanges {
                target: scrim
                opacity: 0.10
            }
            PropertyChanges {
                target: surface
                width: root.collapsedSize
                height: root.collapsedSize
                radius: root.collapsedRadius
                rotation: 180
                scale: 0.94
                opacity: 0.94
                color: meoTheme.surfaceContainerHigh
                border.color: meoTheme.outlineVariant
            }
            PropertyChanges {
                target: lockIcon
                source: "system-lock-screen"
                color: meoTheme.onSurface
                opacity: 1
            }
        },
        State {
            name: "expanded"
            PropertyChanges {
                target: scrim
                opacity: 0.22
            }
            PropertyChanges {
                target: surface
                width: root.expandedWidth
                height: root.expandedHeight
                radius: root.expandedRadius
                rotation: 360
                scale: 1
                opacity: 0.82
                color: meoTheme.surfaceContainer
                border.color: meoTheme.outlineVariant
            }
            PropertyChanges {
                target: lockIcon
                source: "system-lock-screen"
                color: meoTheme.primary
                opacity: 0
            }
        },
        State {
            name: "success"
            PropertyChanges {
                target: scrim
                opacity: 0
            }
            PropertyChanges {
                target: surface
                width: root.collapsedSize
                height: root.collapsedSize
                radius: root.collapsedRadius
                rotation: 540
                scale: 0.88
                opacity: 0
                color: meoTheme.successContainer
                border.color: meoTheme.success
            }
            PropertyChanges {
                target: lockIcon
                source: "object-unlocked"
                color: meoTheme.success
                opacity: 1
            }
        }
    ]

    transitions: [
        Transition {
            from: "collapsed"
            to: "expanded"

            ParallelAnimation {
                NumberAnimation {
                    properties: "width,height,radius,rotation,scale"
                    duration: meoTheme.durationSpatial
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    property: "opacity"
                    duration: meoTheme.durationDefault
                    easing.type: Easing.OutCubic
                }
                ColorAnimation {
                    properties: "color,border.color"
                    duration: meoTheme.durationDefault
                    easing.type: Easing.OutCubic
                }
            }
        },
        Transition {
            from: "expanded"
            to: "collapsed"

            ParallelAnimation {
                NumberAnimation {
                    properties: "width,height,radius,rotation,scale"
                    duration: meoTheme.durationExit
                    easing.type: Easing.InOutCubic
                }
                NumberAnimation {
                    property: "opacity"
                    duration: meoTheme.durationDefault
                    easing.type: Easing.InOutCubic
                }
                ColorAnimation {
                    properties: "color,border.color"
                    duration: meoTheme.durationDefault
                    easing.type: Easing.InOutCubic
                }
            }
        },
        Transition {
            to: "success"

            SequentialAnimation {
                ParallelAnimation {
                    NumberAnimation {
                        properties: "width,height,radius,rotation,scale"
                        duration: meoTheme.durationExit
                        easing.type: Easing.InOutCubic
                    }
                    ColorAnimation {
                        target: surface
                        properties: "color,border.color"
                        duration: meoTheme.durationFast
                        easing.type: Easing.OutCubic
                    }
                    ColorAnimation {
                        target: lockIcon
                        property: "color"
                        duration: meoTheme.durationFast
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: lockIcon
                        property: "opacity"
                        duration: meoTheme.durationFast
                        easing.type: Easing.OutCubic
                    }
                }
                ParallelAnimation {
                    NumberAnimation {
                        target: surface
                        property: "opacity"
                        duration: meoTheme.durationFast
                        easing.type: Easing.InCubic
                    }
                    NumberAnimation {
                        target: scrim
                        property: "opacity"
                        duration: meoTheme.durationFast
                        easing.type: Easing.InCubic
                    }
                }
            }
        }
    ]
}
