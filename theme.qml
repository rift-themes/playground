import QtQuick
import Rift 1.0

/**
 * Playground Theme
 * A development theme for testing Rift components and the grid system
 */
FocusScope {
    id: root
    focus: true

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
