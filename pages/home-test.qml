import QtQuick
import QtQuick.Window
import Rift 1.0

/**
 * HomeGrid - Grid system demo home page
 * Demonstrates the responsive 12-column grid with aspect ratio breakpoints
 */
FocusScope {
    id: root
    focus: true

    // Debug mode passed from parent theme
    property bool debugGrid: false

    // Dynamic background color
    property color bgColor: "#1a1a2e"

    // Function to calculate color from platform name
    function getColorForPlatform(name) {
        if (!name) return "#1a1a2e"
        // Better hash with more variation
        var hash = 0
        for (var i = 0; i < name.length; i++) {
            hash = ((hash << 7) - hash + name.charCodeAt(i) * (i + 1)) | 0
        }
        var hue = Math.abs(hash % 360) / 360
        var color = Qt.hsla(hue, 0.7, 0.20, 1)  // More saturated
        return color
    }

    // Background
    Rectangle {
        id: background
        anchors.fill: parent
        color: root.bgColor
        Behavior on color { ColorAnimation { duration: 300 } }
    }


    // Main container using the grid system
    RiftContainer {
        id: container
        fluid: true
        paddingX: 24
        paddingY: 24

        // Carousel row
        RiftRow {
            id: carouselRow
            gutter: 16
            debug: root.debugGrid

            RiftCol {
                span: 12
                fixedHeight: 200
                autoHeight: false
                debug: root.debugGrid

                RiftCarousel {
                    id: platformCarousel
                    anchors.fill: parent
                    focus: true

                    // Model & data
                    model: Rift.platforms

                    // Type & layout
                    carouselType: "horizontal"
                    maxItemCount: 7
                    itemSizeX: 0.15
                    itemSizeY: 0.8

                    // Alignment: "start" = focused at left, "center" = focused in middle
                    alignment: "start"
                    // startOffset: 0  // Optional: add empty slots before focused item

                    // Transform
                    itemScale: 1.5
                    unfocusedItemOpacity: 0.5

                    // Animation
                    animationDuration: 200

                    // Display elements (instead of custom delegate)
                    // Images: logo, logoWhite, system, controller, carouselIcon, background
                    // Text: fullName, name, manufacturer, releaseYear, gameCount, description, platformType, generation
                    displayElements: [
                        { type: "background", height: 0.3 },
                        { type: "logo", height: 0.3 },
                        { type: "logoWhite", height: 0.3 },
                        { type: "system", height: 0.3 },
                        { type: "controller", height: 0.3 },
                        { type: "carouselIcon", height: 0.3 },
                        { type: "fullName", fontSize: 9, bold: true },
                        { type: "manufacturer", fontSize: 8, color: "#aaa" },
                        { type: "releaseYear", fontSize: 8, color: "#888", template: "{year}" },
                        { type: "gameCount", fontSize: 8, color: "#666", template: "{count} games" }
                    ]

                    // Delegate styling
                    delegateLayout: "vertical"
                    delegateSpacing: 6
                    delegatePadding: 10
                    delegateBackground: "#16213e"
                    delegateBackgroundSelected: "#e94560"
                    delegateRadius: 8

                    // Handle activation
                    onItemActivated: function(index) {
                        console.log("Platform selected:", index)
                    }

                    // Update background on index change
                    onCurrentIndexChanged: {
                        var platform = model?.get(currentIndex)
                        root.bgColor = root.getColorForPlatform(platform?.name)
                    }

                    // Initialize on load
                    Component.onCompleted: {
                        var platform = model?.get(currentIndex)
                        root.bgColor = root.getColorForPlatform(platform?.name)
                    }
                }
            }
        }

    }

}
