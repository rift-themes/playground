import QtQuick
import QtQuick.Window
import QtMultimedia
import Rift 1.0

/**
 * Games - Grid view of games for a platform
 * Left: 8-column grid of game cards (screenshot bg + wheel overlay)
 * Right: 4-column metadata panel for selected game
 */
FocusScope {
    id: root
    focus: true

    // Debug mode passed from parent theme
    property bool debugGrid: false

    // Initial game index (restored from theme)
    property int initialGameIndex: 0
    onInitialGameIndexChanged: {
        selectedIndex = initialGameIndex
        // Position without animation
        gamesGrid.positionViewAtIndex(initialGameIndex, GridView.Center)
    }

    // Platform passed from parent (or default to first)
    property var platform: Rift.platforms.get(0)
    property int platformId: platform?.id ?? -1

    // Games for this platform - using reactive model for live updates
    property var gamesModel: Rift.getGamesModelForPlatform(platformId)

    // Currently selected game index
    property int selectedIndex: initialGameIndex
    property var selectedGame: gamesModel ? gamesModel.get(selectedIndex) : null

    // Helper to ensure file:// prefix
    function toFileUrl(path) {
        if (!path) return ""
        if (path.startsWith("file://")) return path
        if (path.startsWith("/")) return "file://" + path
        return path
    }

    // Helper to format date from YYYYMMDDTHHMMSS format
    function formatReleaseDate(dateStr) {
        if (!dateStr || dateStr.length < 8) return "-"
        var year = dateStr.substring(0, 4)
        var month = parseInt(dateStr.substring(4, 6), 10)
        var day = parseInt(dateStr.substring(6, 8), 10)
        var months = ["January", "February", "March", "April", "May", "June",
                      "July", "August", "September", "October", "November", "December"]
        return months[month - 1] + " " + day + ", " + year
    }

    // Background - blurred screenshot of selected game
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: toFileUrl(selectedGame?.screenshot ?? "")
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

            // Left column - Games grid (8 cols)
            RiftCol {
                span: 8
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
                GridView {
                    id: gamesGrid
                    width: parent.width
                    height: root.height - 50
                    cellWidth: width / 3
                    cellHeight: cellWidth * 0.75
                    clip: true
                    focus: true

                    model: gamesModel

                    currentIndex: root.selectedIndex
                    onCurrentIndexChanged: root.selectedIndex = currentIndex

                    delegate: RiftGameCard {
                        required property var modelData
                        required property int index

                        width: gamesGrid.cellWidth - 8
                        height: gamesGrid.cellHeight - 8
                        game: modelData
                        isSelected: index === gamesGrid.currentIndex
                        showCover: true
                    }

                    // Keyboard navigation
                    Keys.onLeftPressed: moveCurrentIndexLeft()
                    Keys.onRightPressed: moveCurrentIndexRight()
                    Keys.onUpPressed: moveCurrentIndexUp()
                    Keys.onDownPressed: moveCurrentIndexDown()
                    Keys.onReturnPressed: {
                        if (selectedGame) {
                            Rift.navigation.push("game", { game: selectedGame, gameIndex: root.selectedIndex })
                        }
                    }

                    // Rift input handling
                    Connections {
                        target: Rift
                        enabled: gamesGrid.activeFocus
                        function onNavigationLeft() { gamesGrid.moveCurrentIndexLeft() }
                        function onNavigationRight() { gamesGrid.moveCurrentIndexRight() }
                        function onNavigationUp() { gamesGrid.moveCurrentIndexUp() }
                        function onNavigationDown() { gamesGrid.moveCurrentIndexDown() }
                        function onInputAccept() {
                            if (root.selectedGame) {
                                Rift.navigation.push("game", { game: root.selectedGame, gameIndex: root.selectedIndex })
                            }
                        }
                    }
                }
            }

            // Right column - Game metadata (4 cols)
            RiftCol {
                span: 4
                autoHeight: true

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
                            height: width * 1
                            source: root.toFileUrl(selectedGame?.boxart ?? "")
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
                                value: formatReleaseDate(selectedGame?.releaseDate)
                            }

                            // Players
                            MetadataRow {
                                label: "Players"
                                value: selectedGame?.players ?? "-"
                            }

                            // Rating
                            MetadataRow {
                                label: "Rating"
                                value: selectedGame?.rating ? (selectedGame.rating * 5).toFixed(1) + " / 5" : "-"
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

    // Force focus on grid when page loads (with small delay for model to be ready)
    Timer {
        id: focusTimer
        interval: 50
        onTriggered: gamesGrid.forceActiveFocus()
    }

    Component.onCompleted: {
        focusTimer.start()
    }
}
