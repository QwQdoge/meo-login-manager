/*
 * SPDX-FileCopyrightText: 2026 MeoArch contributors
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls

QtObject {
    id: root

    // The login greeter must remain self-contained and must not depend on a
    // previous user's QML runtime. Mirror the canonical MeoUI fallback roles
    // here as a small presentation-only token table.
    readonly property bool darkMode: Application.styleHints.colorScheme === Qt.Dark

    readonly property string brandFont: "Comfortaa"
    readonly property string plainFont: "Roboto"
    readonly property string monoFont: "Roboto Mono"
    readonly property string iconFont: "Material Symbols Rounded"

    readonly property color primary: darkMode ? "#CFBDFE" : "#65558F"
    readonly property color onPrimary: darkMode ? "#36275D" : "#FFFFFF"
    readonly property color primaryContainer: darkMode ? "#4D3D75" : "#E9DDFF"
    readonly property color onPrimaryContainer: darkMode ? "#E9DDFF" : "#4D3D75"

    readonly property color secondary: darkMode ? "#CBC2DB" : "#625B71"
    readonly property color secondaryContainer: darkMode ? "#4A4458" : "#E8DEF8"
    readonly property color onSecondaryContainer: darkMode ? "#E8DEF8" : "#4A4458"

    readonly property color tertiary: darkMode ? "#EFB8C8" : "#7E5260"
    readonly property color tertiaryContainer: darkMode ? "#633B48" : "#FFD9E3"

    readonly property color surface: darkMode ? "#141218" : "#FDF7FF"
    readonly property color surfaceContainerLow: darkMode ? "#1D1B20" : "#F8F2FA"
    readonly property color surfaceContainer: darkMode ? "#211F24" : "#F2ECF4"
    readonly property color surfaceContainerHigh: darkMode ? "#2B292F" : "#ECE6EE"
    readonly property color surfaceContainerHighest: darkMode ? "#36343A" : "#E6E0E9"
    readonly property color onSurface: darkMode ? "#E6E0E9" : "#1D1B20"
    readonly property color onSurfaceVariant: darkMode ? "#CAC4CF" : "#49454E"
    readonly property color outline: darkMode ? "#948F99" : "#7A757F"
    readonly property color outlineVariant: darkMode ? "#49454E" : "#CAC4CF"
    readonly property color scrim: "#000000"
    readonly property color shadow: "#000000"

    readonly property color error: darkMode ? "#FFB4AB" : "#BA1A1A"
    readonly property color errorContainer: darkMode ? "#93000A" : "#FFDAD6"

    // Meo semantic success role (Material has no standard success role).
    readonly property color success: darkMode ? "#8ED6A0" : "#256D3A"
    readonly property color successContainer: darkMode ? "#164A27" : "#D8F3DC"
    readonly property color onSuccessContainer: darkMode ? "#C1F1CB" : "#123C20"

    // Shared motion values aligned with MeoUI's semantic timing scale. The
    // greeter uses only these presentation constants; auth/session timing is
    // never delayed by them.
    readonly property int durationFast: 220
    readonly property int durationDefault: 360
    readonly property int durationSpatial: 520
    readonly property int durationExit: 420
}
