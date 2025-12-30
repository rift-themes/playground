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

    // Initial platform index (restored from theme)
    property int initialPlatformIndex: 0
    onInitialPlatformIndexChanged: {
        platformCarousel.currentIndex = initialPlatformIndex
    }

    // Background image based on selected platform
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: {
            var platform = platformCarousel.model?.get(platformCarousel.currentIndex)
            if (platform?.name) {
                return Rift.assetsPath + "/backgrounds/" + platform.name + ".jpg"
            }
            return ""
        }
        fillMode: Image.PreserveAspectCrop
        asynchronous: true

        // Fade transition
        Behavior on source {
            SequentialAnimation {
                PropertyAnimation { target: backgroundImage; property: "opacity"; to: 0; duration: 150 }
                PropertyAction { target: backgroundImage; property: "source" }
                PropertyAnimation { target: backgroundImage; property: "opacity"; to: 1; duration: 150 }
            }
        }
    }

    // Dark overlay for better logo visibility
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.5
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
                fixedHeight: 300
                autoHeight: false
                debug: root.debugGrid

                RiftCarousel {
                    id: platformCarousel
                    anchors.fill: parent
                    focus: true

                    // Model & data
                    model: Rift.platforms
                    currentIndex: root.initialPlatformIndex

                    // Type & layout
                    carouselType: "horizontal"
                    maxItemCount: 3
                    itemSizeX: 0.25
                    itemSizeY: 0.6

                    // Alignment: centered
                    alignment: "center"

                    // Transform
                    itemScale: 1.3
                    unfocusedItemOpacity: 0.4

                    // Animation
                    animationDuration: 200

                    // Display elements - white logos + game count
                    displayElements: [
                        { type: "logoWhite", height: 0.6 },
                        { type: "gameCount", fontSize: 14, color: "#fff", template: "{count} games" }
                    ]

                    // Delegate styling
                    delegateSpacing: 0
                    delegatePadding: 20
                    delegateBackground: "transparent"
                    delegateBackgroundSelected: "transparent"
                    delegateRadius: 0
                    delegateBorderWidth: 0

                    // Handle activation - navigate to games page
                    onItemActivated: function(index) {
                        var platform = model.get(index)
                        Rift.navigation.push("games", { platform: platform, platformIndex: index })
                    }
                }
            }
        }
    }

    // Send notification when home page loads
    Component.onCompleted: {
        Rift.sendNotification("Hello world from the home page")
    }
}
