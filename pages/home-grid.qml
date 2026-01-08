import QtQuick
import Rift 1.0

/**
 * HomeGrid - Grid layout for platforms
 * Shows platforms in a responsive grid with background transitions
 */
FocusScope {
    id: root
    focus: true

    // Fonts
    FontLoader { id: headlineFont; source: "../fonts/Nulshock Bd.otf" }
    property string fontHeadline: headlineFont.status === FontLoader.Ready ? headlineFont.name : "sans-serif"

    // Initial platform index (restored from theme)
    property int initialPlatformIndex: 0
    onInitialPlatformIndexChanged: {
        platformGrid.currentIndex = initialPlatformIndex
    }

    // Current platform for background
    property var currentPlatform: Rift.platforms?.get(platformGrid.currentIndex)

    // Background image based on selected platform
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: {
            if (currentPlatform?.name) {
                return Rift.assetsPath + "/backgrounds/" + currentPlatform.name + ".jpg"
            }
            return ""
        }
        fillMode: Image.PreserveAspectCrop
        asynchronous: true

        // Fade transition
        Behavior on source {
            SequentialAnimation {
                PropertyAnimation { target: backgroundImage; property: "opacity"; to: 0; duration: 300 }
                PropertyAction { target: backgroundImage; property: "source" }
                PropertyAnimation { target: backgroundImage; property: "opacity"; to: 1; duration: 300 }
            }
        }
    }

    // Dark overlay for better visibility
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.6
    }

    // Main container
    RiftContainer {
        fluid: true
        paddingX: 48
        paddingY: 48

        RiftRow {
            gutter: 16

            RiftCol {
                span: 12
                autoHeight: true

                // Title
                Text {
                    text: "Platforms"
                    color: "#fff"
                    font.pixelSize: 32
                    font.family: root.fontHeadline
                    bottomPadding: 24
                }

                // Platforms grid
                GridView {
                    id: platformGrid
                    width: parent.width
                    height: root.height - 150
                    focus: true

                    cellWidth: width / 4
                    cellHeight: cellWidth * 0.6

                    model: Rift.platforms
                    currentIndex: root.initialPlatformIndex
                    clip: true

                    highlight: Item {}
                    highlightFollowsCurrentItem: false

                    delegate: Item {
                        id: delegateRoot
                        width: platformGrid.cellWidth
                        height: platformGrid.cellHeight

                        required property var modelData
                        required property int index

                        property bool isSelected: index === platformGrid.currentIndex

                        // Card
                        Rectangle {
                            id: card
                            anchors.fill: parent
                            anchors.margins: 8
                            radius: 12
                            color: "transparent"
                            border.color: delegateRoot.isSelected ? "#fff" : "transparent"
                            border.width: delegateRoot.isSelected ? 3 : 0

                            scale: delegateRoot.isSelected ? 1.02 : 1.0
                            Behavior on scale { NumberAnimation { duration: 150 } }
                            Behavior on color { ColorAnimation { duration: 150 } }

                            // Platform logo
                            Image {
                                id: logoImage
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: -15
                                width: parent.width * 0.6
                                height: parent.height * 0.5
                                source: {
                                    var name = delegateRoot.modelData?.name
                                    return name ? Rift.assetsPath + "/logos-white/" + name + ".svg" : ""
                                }
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                                opacity: delegateRoot.isSelected ? 1.0 : 0.5

                                Behavior on opacity { NumberAnimation { duration: 150 } }
                            }


                            // Game count
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 16
                                text: (delegateRoot.modelData?.gameCount ?? 0) + " games"
                                color: delegateRoot.isSelected ? "#fff" : "#888"
                                font.pixelSize: 14
                                font.bold: delegateRoot.isSelected

                                Behavior on color { ColorAnimation { duration: 150 } }
                            }

                            // Click handler
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (platformGrid.currentIndex !== delegateRoot.index) {
                                        platformGrid.currentIndex = delegateRoot.index
                                    } else {
                                        // Activate
                                        var platform = Rift.platforms.get(delegateRoot.index)
                                        Rift.navigation.push("games", { platform: platform, platformIndex: delegateRoot.index })
                                    }
                                }
                            }
                        }
                    }

                    // Keyboard navigation
                    Keys.onReturnPressed: {
                        var platform = Rift.platforms.get(currentIndex)
                        Rift.navigation.push("games", { platform: platform, platformIndex: currentIndex })
                    }
                    Keys.onEnterPressed: Keys.onReturnPressed(event)
                }
            }
        }
    }
}
