import QtQuick
import QtQuick.Window
import Qt.labs.settings 1.0

/**
 * Playground Theme
 * A development theme for testing Rift components and the grid system
 */
FocusScope {
    id: root

    focus: true

    // Theme receives the API from Rift
    property var api: null

    // Current view/page - start with "home", restore in Component.onCompleted
    property string currentPage: "home"

    // Settings for hot reload state persistence
    Settings {
        id: hotReloadSettings
        category: "PlaygroundHotReload"
        property string savedPage: "home"
        property int savedPlatformId: -1
        property int savedGameId: -1
    }

    // Selected platform (passed to games page)
    property var selectedPlatform: null

    // Selected game (passed to game detail page)
    property var selectedGame: null

    // Last selected platform index for carousel restoration
    property int lastPlatformIndex: 0

    // Last selected game index for grid restoration
    property int lastGameIndex: 0

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
                // Pass last platform index to home page
                if (item.hasOwnProperty("initialPlatformIndex")) {
                    item.initialPlatformIndex = root.lastPlatformIndex
                }
                // Connect navigation signal from home page
                if (item.hasOwnProperty("navigateToGames")) {
                    item.navigateToGames.connect(function(platform, index) {
                        // Reset game index if changing platform
                        if (root.selectedPlatform?.id !== platform.id) {
                            root.lastGameIndex = 0
                        }
                        root.selectedPlatform = platform
                        root.lastPlatformIndex = index
                        root.currentPage = "games"
                    })
                }
                // Pass last game index to games page
                if (item.hasOwnProperty("initialGameIndex")) {
                    item.initialGameIndex = root.lastGameIndex
                }
                // Connect navigation signal from games page
                if (item.hasOwnProperty("navigateToGame")) {
                    item.navigateToGame.connect(function(game, index) {
                        root.selectedGame = game
                        root.lastGameIndex = index
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
            // Save state before reload
            hotReloadSettings.savedPage = root.currentPage
            hotReloadSettings.savedPlatformId = root.selectedPlatform?.id ?? -1
            hotReloadSettings.savedGameId = root.selectedGame?.id ?? -1

            var src = pageLoader.source
            pageLoader.source = ""
            pageLoader.source = src
        }
    }

    // Restore state after hot reload
    Component.onCompleted: {
        var savedPage = hotReloadSettings.savedPage
        console.log("Hot reload restore - savedPage:", savedPage, "platformId:", hotReloadSettings.savedPlatformId, "gameId:", hotReloadSettings.savedGameId)
        if (savedPage && savedPage !== "home") {
            // Restore platform if needed
            var platformId = hotReloadSettings.savedPlatformId
            if (platformId > 0) {
                for (var i = 0; i < Rift.platforms.count; i++) {
                    var p = Rift.platforms.get(i)
                    if (p.id === platformId) {
                        root.selectedPlatform = p
                        break
                    }
                }
            }
            // Restore game if needed
            var gameId = hotReloadSettings.savedGameId
            if (gameId > 0) {
                var game = Rift.getGame(gameId)
                console.log("Restored game:", JSON.stringify(game))
                root.selectedGame = game
            }
            // Restore page
            root.currentPage = savedPage
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
