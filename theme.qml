import QtQuick
import QtQuick.Window

/**
 * Playground Theme
 * A development theme for testing Rift components and the grid system
 */
FocusScope {
    id: root

    focus: true

    // Theme receives the API from Rift
    property var api: null

    // Current view/page
    property string currentPage: "home"

    // Selected platform (passed to games page)
    property var selectedPlatform: null

    // Selected game (passed to game detail page)
    property var selectedGame: null

    // Debug mode - shows grid outlines (red=cols, blue=rows)
    // Controlled by Developer > Show Outlines setting
    property bool debugGrid: Rift.settings.developerShowOutlines

    // Background
    Rectangle {
        anchors.fill: parent
        color: "#1a1a2e"
    }

    // Page loader - dynamically loads pages from the pages/ folder
    Loader {
        id: pageLoader
        anchors.fill: parent
        focus: true
        // Add hotReloadVersion for cache busting
        source: Qt.resolvedUrl("pages/" + currentPage + ".qml") + "?v=" + Rift.themeManager.hotReloadVersion

        // Pass properties and focus to loaded page
        onLoaded: {
            if (item) {
                item.debugGrid = Qt.binding(function() { return root.debugGrid })
                // Pass selected platform to games page
                if (item.hasOwnProperty("platform") && root.selectedPlatform) {
                    item.platform = root.selectedPlatform
                }
                // Pass selected game to game detail page
                if (item.hasOwnProperty("game") && root.selectedGame) {
                    item.game = root.selectedGame
                }
                // Connect navigation signal from home page
                if (item.hasOwnProperty("navigateToGames")) {
                    item.navigateToGames.connect(function(platform) {
                        root.selectedPlatform = platform
                        root.currentPage = "games"
                    })
                }
                // Connect navigation signal from games page
                if (item.hasOwnProperty("navigateToGame")) {
                    item.navigateToGame.connect(function(game) {
                        root.selectedGame = game
                        root.currentPage = "game"
                    })
                }
                // Connect goBack signal from game detail page
                if (item.hasOwnProperty("goBack")) {
                    item.goBack.connect(function() {
                        root.currentPage = "games"
                    })
                }
                item.focus = true
            }
        }
    }

    // Hot reload: force reload when any file changes
    Connections {
        target: Rift.themeManager
        function onHotReloadTriggered() {
            var src = pageLoader.source
            pageLoader.source = ""
            pageLoader.source = src
        }
    }

    // Rift input handling
    Connections {
        target: Rift
        function onInputBack() {
            if (currentPage === "game") {
                currentPage = "games"
            } else if (currentPage === "games") {
                currentPage = "home"
            }
        }
    }

    // Keyboard navigation
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape || event.key === Qt.Key_Backspace) {
            if (currentPage === "game") {
                // Go back to games from game detail
                currentPage = "games"
                event.accepted = true
            } else if (currentPage === "games") {
                // Go back to home from games
                currentPage = "home"
                event.accepted = true
            }
        }
    }
}
