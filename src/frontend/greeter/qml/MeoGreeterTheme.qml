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

    // Self-contained mirror of MeoUI's Material 3 motion contract.  The
    // display manager cannot depend on a logged-in user's MeoUI plugin, so the
    // greeter embeds only the small presentation token subset it consumes.
    // Keep spatial transitions expressive and effects monotonic, matching the
    // Caelestia/end-4 rhythm without creating a second greeter-only language.
    readonly property int durationFast: 200
    readonly property int durationDefault: 250
    readonly property int durationSpatial: 500
    readonly property int durationExit: 350

    readonly property list<real> easingStandard: [0.2, 0, 0, 1]
    readonly property list<real> easingStandardAccelerate: [0.3, 0, 1, 1]
    readonly property list<real> easingStandardDecelerate: [0, 0, 0, 1]
    readonly property list<real> easingEmphasized: [
        0.05, 0, 0.133333, 0.06, 0.166666, 0.4,
        0.208333, 0.82, 0.25, 1, 1, 1
    ]
    readonly property list<real> easingEmphasizedDecelerate: [0.05, 0.7, 0.1, 1]
}
