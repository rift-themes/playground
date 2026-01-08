import QtQuick
import Rift 1.0

/**
 * Games - Grid view of games for a platform
 * Left: 8-column grid of game cards (screenshot bg + wheel overlay)
 * Right: 4-column metadata panel for selected game
 */
FocusScope {
    id: root
    focus: true

    // Initial game index (restored from theme)
    property int initialGameIndex: 0
    onInitialGameIndexChanged: {
        selectedIndex = initialGameIndex
        gamesList.positionAtIndex(initialGameIndex)
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
    property bool showGameInfo: Rift.themeSetting("showGameInfo") !== false

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
        opacity: 0.6
    }

    // Main container
    RiftContainer {
        id: container
        fluid: true
        paddingX: 24
        paddingY: 24

        RiftRow {
            gutter: 24

            // Left column - Games grid (8 cols when info shown, 12 when hidden)
            RiftCol {
                span: root.showGameInfo ? 8 : 12
                autoHeight: true

                // Section title
                Text {
                    text: platform?.displayName ?? "Games"
                    color: "#fff"
                    font.pixelSize: 28
                    font.bold: true
                    bottomPadding: 16
                }

                // Games grid
                RiftGamesList {
                    id: gamesList
                    width: parent.width
                    height: root.height - 100
                    focus: true

                    model: gamesModel
                    platform: root.platform
                    currentIndex: root.selectedIndex
                    showCover: root.showCover

                    onCurrentIndexChanged: root.selectedIndex = currentIndex
                    onGameActivated: function(game, index) {
                        Rift.navigation.push("game", { game: game, gameIndex: index })
                    }

                    // Custom delegate (optional - uses RiftGameCard by default)
                    delegate: Component {
                        RiftGameCard {
                            required property var modelData
                            required property int index

                            width: gamesList.cellWidth - 8
                            height: gamesList.cellHeight - 8
                            game: modelData
                            isSelected: index === gamesList.currentIndex
                            showCover: gamesList.showCover
                        }
                    }
                }
            }

            // Right column - Game metadata (4 cols) - hidden when showGameInfo is false
            RiftCol {
                span: 4
                autoHeight: true
                visible: root.showGameInfo

                // Metadata panel
                Rectangle {
                    width: parent.width
                    height: root.height - 80
                    color: "#1a1a2e"
                    radius: 12
                    opacity: 0.9

                    Column {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 16

                        // Boxart
                        Image {
                            width: parent.width
                            height: Math.min(
                                implicitHeight > 0 ? (width / implicitWidth * implicitHeight) : width,
                                root.height * 0.4
                            )
                            source: selectedGame?.boxart ?? ""
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            horizontalAlignment: Image.AlignHCenter
                        }

                        // Game title
                        Text {
                            width: parent.width
                            text: selectedGame?.name ?? ""
                            color: "#fff"
                            font.pixelSize: 20
                            font.bold: true
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }

                        // Separator
                        Rectangle {
                            width: parent.width
                            height: 1
                            color: "#444"
                        }

                        // Metadata grid
                        Column {
                            width: parent.width
                            spacing: 8

                            // Genre
                            MetadataRow {
                                label: "Genre"
                                value: selectedGame?.genre ?? "-"
                            }

                            // Developer
                            MetadataRow {
                                label: "Developer"
                                value: selectedGame?.developer ?? "-"
                            }

                            // Publisher
                            MetadataRow {
                                label: "Publisher"
                                value: selectedGame?.publisher ?? "-"
                            }

                            // Release date
                            MetadataRow {
                                label: "Released"
                                value: selectedGame?.releaseDateFormatted ?? "-"
                            }

                            // Players
                            MetadataRow {
                                label: "Players"
                                value: selectedGame?.players ?? "-"
                            }

                            // Rating
                            MetadataRow {
                                label: "Rating"
                                value: selectedGame?.ratingFormatted ?? "-"
                            }
                        }

                        // Description
                        Text {
                            width: parent.width
                            text: selectedGame?.description ?? ""
                            color: "#aaa"
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                            maximumLineCount: 6
                            elide: Text.ElideRight
                            visible: text.length > 0
                        }
                    }
                }
            }
        }
    }

    // Metadata row component
    component MetadataRow: Row {
        property string label: ""
        property string value: ""
        width: parent.width
        spacing: 8

        Text {
            text: label + ":"
            color: "#888"
            font.pixelSize: 12
            width: 80
        }
        Text {
            text: value
            color: "#fff"
            font.pixelSize: 12
            width: parent.width - 88
            elide: Text.ElideRight
        }
    }

}
