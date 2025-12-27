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

    // Keyboard navigation
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) {
            // Could switch views or exit
            event.accepted = true
        }
    }
}
