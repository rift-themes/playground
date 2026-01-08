import QtQuick
import QtMultimedia
import Rift 1.0

/**
 * Games Carousel - Carousel view of games for a platform
 * Top: Horizontal carousel of game covers
 * Bottom: Game information panel
 */
FocusScope {
    id: root
    focus: true

    // Fonts
    FontLoader { id: headlineFont; source: "../fonts/Nulshock Bd.otf" }
    property string fontHeadline: headlineFont.status === FontLoader.Ready ? headlineFont.name : "sans-serif"

    // Initial game index (restored from theme)
    property int initialGameIndex: 0
    onInitialGameIndexChanged: {
        selectedIndex = initialGameIndex
        gamesCarousel.goToIndex(initialGameIndex)
    }

    // Platform passed from parent (or default to first)
    property var platform: Rift.platforms.get(0)
    property int platformId: platform?.id ?? -1

    // Games for this platform - using reactive model for live updates
    property var gamesModel: Rift.getGamesModelForPlatform(platformId)

    // Currently selected game index
    property int selectedIndex: initialGameIndex
    property var selectedGame: gamesModel ? gamesModel.get(selectedIndex) : null

    // Theme settings
    property bool showCover: Rift.themeSetting("gameCardFormat") === "cover"

    // Background - blurred screenshot of selected game
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: selectedGame?.screenshot ?? ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        opacity: 0.3
    }

    // Dark overlay
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.5
    }

    // Main layout
    Column {
        anchors.fill: parent
        anchors.margins: 40
        spacing: 30

        // Platform title
        Text {
            text: platform?.displayName ?? "Games"
            color: "#fff"
            font.pixelSize: 32
            font.family: root.fontHeadline
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Games carousel (top section - 50% height)
        Item {
            width: parent.width
            height: parent.height * 0.45

            RiftCarousel {
                id: gamesCarousel
                anchors.fill: parent
                focus: true

                model: gamesModel
                currentIndex: root.selectedIndex

                // Carousel settings
                carouselType: "horizontal"
                itemSizeX: 0.12
                itemSizeY: 0.8
                itemScale: 1.3
                maxItemCount: 9
                unfocusedItemOpacity: 0.6

                onCurrentIndexChanged: root.selectedIndex = currentIndex
                onItemActivated: function(index) {
                    var game = gamesModel.get(index)
                    if (game) {
                        Rift.navigation.push("game", { game: game, gameIndex: index })
                    }
                }

                delegate: Component {
                    Item {
                        property var modelData
                        property int itemIndex
                        property bool isSelected

                        RiftGameCard {
                            anchors.fill: parent
                            game: modelData
                            showCover: root.showCover
                            showVideo: false
                            isSelected: parent.isSelected
                        }
                    }
                }
            }
        }

        // Game info panel (bottom section)
        Rectangle {
            width: parent.width
            height: parent.height * 0.4
            color: "#1a1a2e"
            radius: 16
            opacity: 0.95

            Row {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 24

                // Left: Artwork (opposite of carousel)
                Item {
                    id: artworkContainer
                    width: parent.height * 1.2
                    height: parent.height

                    property bool shouldPlayVideo: false

                    // Video delay timer
                    Timer {
                        id: videoDelayTimer
                        interval: 500
                        onTriggered: {
                            if (selectedGame?.video) {
                                artworkContainer.shouldPlayVideo = true
                            }
                        }
                    }

                    // Reset video when game changes
                    Connections {
                        target: root
                        function onSelectedGameChanged() {
                            artworkContainer.shouldPlayVideo = false
                            videoDelayTimer.restart()
                        }
                    }

                    // Screenshot + Logo (when carousel shows covers)
                    Image {
                        id: screenshotImage
                        anchors.fill: parent
                        source: Rift.imageSource(selectedGame?.screenshot ?? "")
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        visible: root.showCover
                        opacity: artworkContainer.shouldPlayVideo ? 0 : 1
                        Behavior on opacity { NumberAnimation { duration: 300 } }

                        // Logo overlay
                        Image {
                            anchors.centerIn: parent
                            width: parent.width * 0.8
                            height: parent.height * 0.4
                            source: Rift.imageSource(selectedGame?.marquee ?? "")
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            visible: source !== ""
                            opacity: artworkContainer.shouldPlayVideo ? 0 : 1
                            Behavior on opacity { NumberAnimation { duration: 300 } }
                        }
                    }

                    // Boxart (when carousel shows screenshots)
                    Image {
                        anchors.fill: parent
                        source: Rift.imageSource(selectedGame?.boxart ?? "")
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        visible: !root.showCover
                        opacity: artworkContainer.shouldPlayVideo ? 0 : 1
                        Behavior on opacity { NumberAnimation { duration: 300 } }
                    }

                    // Video player
                    Video {
                        id: gameVideo
                        anchors.fill: parent
                        fillMode: VideoOutput.PreserveAspectCrop
                        loops: MediaPlayer.Infinite
                        volume: 0
                        source: artworkContainer.shouldPlayVideo ? Rift.imageSource(selectedGame?.video ?? "") : ""
                        opacity: artworkContainer.shouldPlayVideo ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 300 } }

                        onSourceChanged: {
                            if (source != "") {
                                play()
                            }
                        }
                    }
                }

                // Right: Game details
                Column {
                    width: parent.width - artworkContainer.width - 24
                    height: parent.height
                    spacing: 12

                    // Game title
                    Text {
                        width: parent.width
                        text: selectedGame?.name ?? ""
                        color: "#fff"
                        font.pixelSize: 24
                        font.family: root.fontHeadline
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }

                    // Metadata row
                    Row {
                        spacing: 20

                        MetadataTag {
                            label: selectedGame?.genre ?? ""
                            visible: label !== ""
                        }

                        MetadataTag {
                            label: selectedGame?.releaseYear ?? ""
                            visible: label !== ""
                        }

                        MetadataTag {
                            label: selectedGame?.developer ?? ""
                            visible: label !== ""
                        }
                    }

                    // Separator
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "#333"
                    }

                    // Description
                    Text {
                        width: parent.width
                        height: parent.height - 120
                        text: selectedGame?.description ?? "No description available."
                        color: "#aaa"
                        font.pixelSize: 14
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        lineHeight: 1.4
                    }
                }
            }
        }
    }

    // Metadata tag component
    component MetadataTag: Rectangle {
        property string label: ""
        width: tagText.width + 16
        height: 28
        radius: 14
        color: "#333"
        visible: label !== ""

        Text {
            id: tagText
            anchors.centerIn: parent
            text: label
            color: "#ccc"
            font.pixelSize: 12
        }
    }
}
