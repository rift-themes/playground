import QtQuick
import QtQuick.Window
import Rift 1.0

/**
 * HomeGrid - Grid system demo home page
 * Demonstrates the responsive 12-column grid with aspect ratio breakpoints
 */
Item {
    id: root

    // Debug mode passed from parent theme
    property bool debugGrid: false

    // Background
    Rectangle {
        anchors.fill: parent
        color: "#1a1a2e"
    }

    // Main container using the grid system
    RiftContainer {
        id: container
        fluid: true
        paddingX: 24
        paddingY: 24

        // Header row
        RiftRow {
            id: headerRow

            gutter: 16
            debug: root.debugGrid

            RiftCol {
                span: 12
                fixedHeight: 60
                autoHeight: false
                debug: root.debugGrid

                Rectangle {
                    anchors.fill: parent
                    color: "#16213e"
                    radius: 8

                    Text {
                        anchors.centerIn: parent
                        text: "Playground Theme - Grid System Test"
                        color: "#e94560"
                        font.pixelSize: 24
                        font.bold: true
                    }
                }
            }
        }


    }

}
