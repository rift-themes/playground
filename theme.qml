import QtQuick
import Rift 1.0

/**
 * Playground Theme
 * A development theme for testing Rift components and the grid system
 */
FocusScope {
    id: root
    focus: true

    // Fonts
    FontLoader { id: headlineFont; source: "fonts/Nulshock Bd.otf" }
    property string fontHeadline: headlineFont.status === FontLoader.Ready ? headlineFont.name : "sans-serif"

    // Theme settings for page layouts
    property string homeLayout: Rift.themeSetting("homeLayout") ?? "default"
    property string gamesLayout: Rift.themeSetting("gamesLayout") ?? "default"
    property string gameLayout: Rift.themeSetting("gameLayout") ?? "default"

    // Page transition setting
    property string pageTransition: Rift.themeSetting("pageTransition") ?? "fade"

    // Page overrides as a reactive binding
    // Using direct property references so QML tracks dependencies
    property var pageOverridesComputed: {
        var overrides = {}
        // Reference the properties directly so QML knows to re-evaluate
        var h = homeLayout
        var g = gamesLayout
        var gm = gameLayout

        if (h !== "default") overrides["home"] = "home-" + h
        if (g !== "default") overrides["games"] = "games-" + g
        if (gm !== "default") overrides["game"] = "game-" + gm

        return overrides
    }

    // Listen for setting changes
    Connections {
        target: Rift
        function onThemeSettingChanged(key, value) {
            if (key === "homeLayout") root.homeLayout = value
            else if (key === "gamesLayout") root.gamesLayout = value
            else if (key === "gameLayout") root.gameLayout = value
            else if (key === "pageTransition") root.pageTransition = value
        }
    }

    // Background
    Rectangle {
        anchors.fill: parent
        color: "#000"
    }

    // Router handles navigation, page loading, and hot reload
    RiftRouter {
        id: router
        anchors.fill: parent
        focus: true

        // Override pages based on layout settings (reactive binding)
        pageOverrides: root.pageOverridesComputed

        // Page transition animation
        transition: root.pageTransition
    }

    // Footer - currentScreen auto-detected from Rift.navigation
    RiftFooter {
        id: footer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 38
        backgroundOpacity: Rift.navigation?.currentPage === "home" ? 0.5 : 1.0
    }
}
