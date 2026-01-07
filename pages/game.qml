import QtQuick
import QtQuick.Controls
import Rift 1.0

/**
 * Game - Detailed view of a single game
 * Full-screen immersive experience with all metadata
 */
FocusScope {
    id: root
    focus: true

    // Game passed from parent
    property var game: null

    // Achievements data (basic lookup only - detailed fetching is handled by RiftAchievementsModal)
    property var achievements: null
    property bool achievementsModalVisible: false

    // Similar games
    property var similarGames: []

    // Load achievements and similar games when game changes
    onGameChanged: {
        if (game && game.platformId) {
            achievements = Rift.getGameAchievementsByName(game.platformId, game.name ?? "", game.md5 ?? "")
            similarGames = Rift.getSimilarGames(game.id, 8)
        } else {
            achievements = null
            similarGames = []
        }
    }

    // Full-screen screenshot/fanart background
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: game?.fanart ?? game?.screenshot ?? ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true

        // Smooth fade in
        opacity: status === Image.Ready ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 500 } }
    }

    // Gradient overlay for readability
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00000000" }
            GradientStop { position: 0.3; color: "#80000000" }
            GradientStop { position: 0.6; color: "#CC000000" }
            GradientStop { position: 1.0; color: "#FF000000" }
        }
    }

    // Left side gradient for boxart area
    Rectangle {
        width: parent.width * 0.4
        height: parent.height
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "#EE000000" }
            GradientStop { position: 0.7; color: "#AA000000" }
            GradientStop { position: 1.0; color: "#00000000" }
        }
    }

    // Main content
    RiftContainer {
        fluid: true
        paddingX: 24
        paddingY: 24

        RiftRow {
            gutter: 48

            // Left column - Boxart and quick info (3 cols)
            RiftCol {
                span: 3
                spacing: 24

                // Boxart + Rating stars (no spacing between them)
                Image {
                    id: boxart
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: status === Image.Ready && implicitWidth > 0
                        ? width * (implicitHeight / implicitWidth)
                        : width * 1.4
                    source: game?.boxart ?? ""
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true

                    // Fade in
                    opacity: status === Image.Ready ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 300 } }
                }

                // Rating stars
                RiftRatingStars {
                    anchors.horizontalCenter: parent.horizontalCenter
                    rating: game?.rating ?? 0
                    visible: game?.rating > 0
                }

                // Last played
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    property var lastPlayedDate: game?.lastPlayed ?? null
                    text: lastPlayedDate ? "Last played: " + Qt.formatDateTime(lastPlayedDate, "MMM d, yyyy") : ""
                    color: "#666"
                    font.pixelSize: 13
                    visible: lastPlayedDate !== null && text !== ""
                }
            }

            // Right column - All metadata (9 cols)
            RiftCol {
                span: 9

                Flickable {
                    width: parent.width
                    height: root.height - 48
                    contentWidth: width
                    contentHeight: metadataColumn.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    Column {
                        id: metadataColumn
                        width: parent.width
                        spacing: 20

                        // Game title (hidden if boxart is available)
                        Text {
                            width: parent.width
                            text: game?.name ?? ""
                            color: "#fff"
                            font.pixelSize: 48
                            font.bold: true
                            wrapMode: Text.WordWrap
                        }

                // Subtitle with platform (hidden if boxart is available)
                Text {
                    text: game?.platformName ?? ""
                    color: "#888"
                    font.pixelSize: 18
                    font.italic: true
                }

                // Separator line (hidden if boxart is available)
                Rectangle {
                    width: parent.width * 0.3
                    height: 3
                    radius: 1.5
                    color: "#e94560"
                    visible: !game?.boxart
                }

                // Metadata grid
                Grid {
                    columns: 3
                    columnSpacing: 32
                    rowSpacing: 16
                    width: parent.width

                    // Genre
                    MetadataItem {
                        label: "GENRE"
                        value: game?.genre ?? "-"
                    }

                    // Release Date
                    MetadataItem {
                        label: "RELEASED"
                        value: game?.releaseDateFormatted ?? "-"
                    }

                    // Developer
                    MetadataItem {
                        label: "DEVELOPER"
                        value: game?.developer ?? "-"
                    }

                    // Publisher
                    MetadataItem {
                        label: "PUBLISHER"
                        value: game?.publisher ?? "-"
                    }

                    // Players
                    MetadataItem {
                        label: "PLAYERS"
                        value: game?.players ?? "-"
                    }

                    // Play count
                    MetadataItem {
                        label: "TIMES PLAYED"
                        value: (game?.playCount ?? 0).toString()
                    }

                    // Achievements (if available)
                    MetadataItem {
                        label: "ACHIEVEMENTS"
                        value: achievements ? (achievementsModal.summary
                            ? (achievementsModal.summary.numEarned + " / " + achievementsModal.summary.numAchievements)
                            : (achievements.numAchievements + " available"))
                            : "-"
                        visible: achievements && achievements.numAchievements > 0
                    }

                    // Achievement points
                    MetadataItem {
                        label: "POINTS"
                        value: achievementsModal.summary
                            ? (achievementsModal.summary.earnedPoints + " / " + achievementsModal.summary.totalPoints)
                            : (achievements?.points ?? 0).toString()
                        visible: achievements && achievements.numAchievements > 0
                    }
                }

                // Achievements progress bar
                RiftProgressBar {
                    width: parent.width * 0.4
                    value: achievementsModal.summary?.percentComplete ?? 0
                    visible: achievementsModal.summary !== null
                }

                // Description
                Column {
                    width: parent.width
                    spacing: 8
                    visible: !!(game?.description)

                    Text {
                        text: "DESCRIPTION"
                        color: "#888"
                        font.pixelSize: 12
                        font.bold: true
                        font.letterSpacing: 2
                    }

                    Text {
                        width: parent.width
                        text: game?.description ?? ""
                        color: "#ccc"
                        font.pixelSize: 15
                        lineHeight: 1.4
                        wrapMode: Text.WordWrap
                        maximumLineCount: 6
                        elide: Text.ElideRight
                    }
                }

                // Buttons with focus navigation
                FocusScope {
                    id: buttonsArea
                    width: parent.width * 0.6
                    height: buttonsRow.height
                    focus: true

                    property int focusedButton: 0
                    property int buttonCount: achievements && achievements.numAchievements > 0 ? 4 : 3

                    Row {
                        id: buttonsRow
                        width: parent.width
                        spacing: 12

                        // Play button
                        GameButton {
                            width: 140
                            text: "PLAY"
                            primary: true
                            focused: buttonsArea.focusedButton === 0 && buttonsArea.activeFocus
                            onClicked: if (game) Rift.launchGame(game.id)
                        }

                        // Favorite button
                        GameButton {
                            width: 56
                            text: "♥"
                            active: game?.favorite ?? false
                            focused: buttonsArea.focusedButton === 1 && buttonsArea.activeFocus
                            onClicked: {
                                if (game) {
                                    Rift.setGameFavorite(game.id, !game.favorite)
                                    root.game = Rift.getGame(game.id)
                                }
                            }
                        }

                        // Backlog button
                        GameButton {
                            width: 56
                            text: "▶"
                            active: game?.backlog ?? false
                            focused: buttonsArea.focusedButton === 2 && buttonsArea.activeFocus
                            accentColor: "#3498db"
                            onClicked: {
                                if (game) {
                                    Rift.setGameBacklog(game.id, !game.backlog)
                                    root.game = Rift.getGame(game.id)
                                }
                            }
                        }

                        // Achievements button
                        GameButton {
                            width: 56
                            text: "★"
                            focused: buttonsArea.focusedButton === 3 && buttonsArea.activeFocus
                            activeAccentColor: "#FFD700"
                            visible: achievements && achievements.numAchievements > 0
                            onClicked: {
                                if (achievements && achievements.id) {
                                    root.achievementsModalVisible = true
                                }
                            }
                        }
                    }

                    // Keyboard/gamepad navigation
                    Keys.onLeftPressed: function(event) {
                        if (focusedButton > 0) focusedButton--
                        event.accepted = true
                    }
                    Keys.onRightPressed: function(event) {
                        if (focusedButton < buttonCount - 1) {
                            focusedButton++
                        } else if (similarGames && similarGames.length > 0) {
                            similarGamesCarousel.forceActiveFocus()
                        }
                        event.accepted = true
                    }
                    Keys.onDownPressed: function(event) {
                        if (similarGames && similarGames.length > 0) {
                            similarGamesCarousel.forceActiveFocus()
                        }
                        event.accepted = true
                    }
                    Keys.onReturnPressed: function(event) {
                        activateButton()
                        event.accepted = true
                    }

                    function activateButton() {
                        if (focusedButton === 0) {
                            if (game) Rift.launchGame(game.id)
                        } else if (focusedButton === 1) {
                            if (game) {
                                Rift.setGameFavorite(game.id, !game.favorite)
                                root.game = Rift.getGame(game.id)
                            }
                        } else if (focusedButton === 2) {
                            if (game) {
                                Rift.setGameBacklog(game.id, !game.backlog)
                                root.game = Rift.getGame(game.id)
                            }
                        } else if (focusedButton === 3) {
                            if (achievements && achievements.id) {
                                root.achievementsModalVisible = true
                            }
                        }
                    }
                }

                // Similar Games Section
                Column {
                    width: parent.width
                    spacing: 10
                    visible: similarGames && similarGames.length > 0

                    // Section title
                    Text {
                        text: "SIMILAR GAMES"
                        color: "#888"
                        font.pixelSize: 12
                        font.bold: true
                        font.letterSpacing: 2
                    }

                    // RiftCarousel for similar games
                    RiftCarousel {
                        id: similarGamesCarousel
                        width: parent.width
                        height: 120
                        clip: true

                        model: similarGamesModel
                        carouselType: "horizontal"
                        alignment: "start"
                        startOffset: 0
                        wrapAround: false

                        // Item sizing
                        itemSizeX: 0.12
                        itemSizeY: 0.9
                        itemScale: 1.1
                        maxItemCount: 7

                        // Visual settings
                        unfocusedItemOpacity: 0.6
                        itemStacking: "centered"

                        // Custom delegate using RiftGameCard
                        delegate: Component {
                            Item {
                                property var modelData
                                property int itemIndex
                                property bool isSelected

                                RiftGameCard {
                                    anchors.fill: parent
                                    game: modelData
                                    isSelected: parent.isSelected
                                    showCover: true
                                    showVideo: false
                                    showBorder: true
                                    borderColor: "#E88D97"
                                    selectedScale: 1.0
                                    cardRadius: 6
                                }

                                // Game name label below (visible when selected)
                                Rectangle {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.top: parent.bottom
                                    anchors.topMargin: 4
                                    width: Math.min(gameNameLabel.implicitWidth + 12, parent.width * 1.4)
                                    height: gameNameLabel.height + 6
                                    radius: 3
                                    color: "#CC000000"
                                    visible: isSelected

                                    Text {
                                        id: gameNameLabel
                                        anchors.centerIn: parent
                                        text: modelData?.name ?? ""
                                        color: "#fff"
                                        font.pixelSize: 10
                                        font.bold: true
                                        elide: Text.ElideRight
                                        width: parent.width - 6
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                            }
                        }

                        // Navigate to selected game on activation
                        onItemActivated: function(index) {
                            var selectedGame = similarGamesModel.get(index)
                            if (selectedGame) {
                                root.game = Rift.getGame(selectedGame.id)
                            }
                        }

                        // Handle boundary (when can't navigate further)
                        onBoundaryReached: function(direction) {
                            if (direction === "left" || direction === "up") {
                                buttonsArea.forceActiveFocus()
                            }
                        }
                    }
                    } // end Similar Games Column
                    } // end metadataColumn
                } // end Flickable
            }
        }
    }

    // Similar Games Model wrapper (RiftCarousel expects count/get interface)
    QtObject {
        id: similarGamesModel
        property int count: similarGames ? similarGames.length : 0
        function get(index) {
            return similarGames ? similarGames[index] : null
        }
    }

    // Rift input handling
    Connections {
        target: Rift
        function onInputBack() {
            if (achievementsModalVisible) {
                achievementsModalVisible = false
            } else {
                Rift.navigation.pop()
            }
        }
        function onInputAccept() {
            if (!achievementsModalVisible) {
                if (buttonsArea.activeFocus) {
                    buttonsArea.activateButton()
                } else if (similarGamesCarousel.activeFocus) {
                    similarGamesCarousel.itemActivated(similarGamesCarousel.currentIndex)
                }
            }
        }
    }

    // Keyboard handling
    Keys.onEscapePressed: {
        if (achievementsModalVisible) {
            achievementsModalVisible = false
        } else {
            Rift.navigation.pop()
        }
    }
    Keys.onBackPressed: {
        if (achievementsModalVisible) {
            achievementsModalVisible = false
        } else {
            Rift.navigation.pop()
        }
    }
    Keys.onReturnPressed: {
        if (!achievementsModalVisible) {
            if (similarGamesCarousel.activeFocus) {
                similarGamesCarousel.itemActivated(similarGamesCarousel.currentIndex)
            } else {
                buttonsArea.activateButton()
            }
        }
    }

    // Metadata item component
    component MetadataItem: Column {
        property string label: ""
        property string value: ""
        width: 200
        spacing: 4

        Text {
            text: label
            color: "#888"
            font.pixelSize: 11
            font.bold: true
            font.letterSpacing: 2
        }

        Text {
            text: value
            color: "#fff"
            font.pixelSize: 18
            font.bold: true
            elide: Text.ElideRight
            width: parent.width
        }
    }

    // Button component for game actions
    component GameButton: Rectangle {
        id: btn

        property string text: ""
        property bool primary: false
        property bool active: false
        property bool focused: false
        property color accentColor: "#e94560"
        property color activeAccentColor: accentColor

        signal clicked()

        height: primary ? 56 : 48
        radius: height / 2

        color: {
            if (primary || active) {
                return focused || mouseArea.containsMouse ? Qt.lighter(accentColor, 1.15) : accentColor
            }
            return focused || mouseArea.containsMouse ? "#444" : "#333"
        }

        border.color: {
            if (focused) return "#fff"
            if (active) return accentColor
            if (mouseArea.containsMouse) return activeAccentColor
            return "#555"
        }
        border.width: focused ? 3 : (primary ? 0 : 1)

        scale: mouseArea.pressed ? 0.95 : 1.0

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on scale { NumberAnimation { duration: 100 } }

        Text {
            anchors.centerIn: parent
            text: btn.text
            color: {
                if (primary || active) return "#fff"
                if (focused || mouseArea.containsMouse) return btn.activeAccentColor
                return "#888"
            }
            font.pixelSize: primary ? 20 : 20
            font.bold: true
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: btn.clicked()
        }
    }

    // Achievements modal overlay
    RiftAchievementsModal {
        id: achievementsModal
        raGameId: achievements?.id ?? 0
        visible: achievementsModalVisible
        onClosed: achievementsModalVisible = false
    }
}
