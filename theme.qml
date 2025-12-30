import QtQuick
import Rift 1.0

/**
 * Playground Theme
 * A development theme for testing Rift components and the grid system
 */
FocusScope {
    id: root
    focus: true

    // Theme receives the API from Rift (for Pegasus compatibility)
    property var api: null

    // Debug mode - shows grid outlines (red=cols, blue=rows)
    property bool debugGrid: Rift.settings.developerShowOutlines

    // Background
    Rectangle {
        anchors.fill: parent
        color: "#1a1a2e"
    }

    // Router handles navigation, page loading, and hot reload
    RiftRouter {
        id: router
        anchors.fill: parent
        anchors.bottomMargin: footer.height
        focus: true
        pagesPath: "pages/"
        baseUrl: Qt.resolvedUrl(".")
    }

    // Pass debugGrid to pages
    Connections {
        target: router
        function onCurrentItemChanged() {
            if (router.currentItem && router.currentItem.hasOwnProperty("debugGrid")) {
                router.currentItem.debugGrid = Qt.binding(function() { return root.debugGrid })
            }
        }
    }

    // Footer - currentScreen auto-detected from Rift.navigation
    RiftFooter {
        id: footer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 32
    }
}
