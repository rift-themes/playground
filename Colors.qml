import QtQuick
import Rift 1.0

QtObject {
    readonly property bool dark: Rift.settings.darkMode !== false

    readonly property color background: dark ? "#000000" : "#000000"
    readonly property color surface: dark ? "#0c0c0e" : "#0c0c0e"
    readonly property color surfaceAlt: dark ? "#2a2a3a" : "#2a2a3a"
    readonly property color hover: dark ? "#17171b" : "#17171b"

    readonly property color textPrimary: dark ? "#fff" : "#fff"
    readonly property color textSecondary: dark ? "#aaa" : "#aaa"
    readonly property color textMuted: dark ? "#888" : "#888"
    readonly property color textDim: dark ? "#666" : "#666"
    readonly property color textFaint: dark ? "#ccc" : "#ccc"
    readonly property color textList: dark ? "#b5b5bb" : "#b5b5bb"

    readonly property color border: dark ? "#444" : "#444"
    readonly property color accent: dark ? "#1758c0" : "#1758c0"
    readonly property color accentAlt: dark ? "#e94560" : "#e94560"
    readonly property color accentPurple: dark ? "#9b59b6" : "#9b59b6"
    readonly property color accentBlue: dark ? "#3498db" : "#3498db"
    readonly property color accentGreen: dark ? "#2ecc71" : "#2ecc71"
    readonly property color accentGold: dark ? "#FFD700" : "#FFD700"

    readonly property color footerBackground: dark ? "#000" : "#000"
    readonly property color footerText: dark ? "#AAAAAA" : "#AAAAAA"
    readonly property color footerButton: dark ? "#FFFFFF" : "#FFFFFF"
    readonly property color footerButtonText: dark ? "#000000" : "#000000"

    readonly property color scrim0: "#00000000"
    readonly property color scrim50: dark ? "#80000000" : "#80000000"
    readonly property color scrim67: dark ? "#AA000000" : "#AA000000"
    readonly property color scrim80: dark ? "#CC000000" : "#CC000000"
    readonly property color scrim93: dark ? "#EE000000" : "#EE000000"
    readonly property color scrimFull: dark ? "#FF000000" : "#FF000000"

    readonly property color secondaryBackground: dark ? "#031921" : "#031921"
    readonly property color secondaryPanel: dark ? "#CC031921" : "#CC031921"
    readonly property color secondaryTextPrimary: dark ? "#FFFFFF" : "#FFFFFF"
    readonly property color secondaryTextSecondary: dark ? "#AAAAAA" : "#AAAAAA"
    readonly property color secondaryTextMuted: dark ? "#CCCCCC" : "#CCCCCC"
    readonly property color secondaryTextDim: dark ? "#666666" : "#666666"

    readonly property real backgroundImageOpacity: dark ? 0.3 : 0.3
    readonly property real backgroundOverlayOpacity: dark ? 0.6 : 0.6
}
