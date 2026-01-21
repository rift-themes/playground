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

    // Fonts
    FontLoader { id: headlineFont; source: "../fonts/Nulshock Bd.otf" }
    property string fontHeadline: headlineFont.status === FontLoader.Ready ? headlineFont.name : "sans-serif"

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

    // Gradient overlay for readability (bottom)
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00000000" }
            GradientStop { position: 0.3; color: "#80000000" }
            GradientStop { position: 0.6; color: "#CC000000" }
            GradientStop { position: 1.0; color: "#FF000000" }
        }
    }

    // Top gradient for title readability
    Rectangle {
        width: parent.width
        height: parent.height * 0.25
        anchors.top: parent.top
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#CC000000" }
            GradientStop { position: 1.0; color: "#00000000" }
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

                // Custom emulator indicator
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8
                    visible: game?.emulatorId && game.emulatorId !== ""

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 6
                        color: "#2a2a3a"
                        border.color: "#9b59b6"
                        border.width: 1

                        Image {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            source: game?.emulatorId ? Rift.getEmulatorIcon(game.emulatorId) : ""
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: game?.emulatorId ?? ""
                        color: "#9b59b6"
                        font.pixelSize: 12
                        font.bold: true
                    }
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
                    id: metadataFlickable
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
                            font.pixelSize: 36
                            font.family: root.fontHeadline
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

                // Description (hidden when secondary display shows it)
                Column {
                    width: parent.width
                    spacing: 8
                    visible: !!(game?.description) && !Rift.secondaryDisplayActive

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

                    // Auto-scroll to top when buttons get focus (to show title)
                    onActiveFocusChanged: {
                        if (activeFocus) {
                            metadataFlickable.contentY = 0
                        }
                    }

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
                            iconSource: "../icons/heart.svg"
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
                            iconSource: "../icons/backlog.svg"
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
                            iconSource: "../icons/trophy.svg"
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
                        } else if (focusedButton === 3 && achievements && achievements.numAchievements > 0) {
                            if (achievements && achievements.id) {
                                root.achievementsModalVisible = true
                            }
                        }
                    }
                }

                // Similar Games Section
                Column {
                    id: similarGamesSection
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
                        height: 180
                        clip: true

                        model: similarGamesModel
                        carouselType: "horizontal"
                        alignment: "start"
                        startOffset: 0
                        wrapAround: false

                        // Item sizing - larger items, only ~5 visible
                        itemSizeX: 0.18
                        itemSizeY: 0.85
                        itemScale: 1.1
                        maxItemCount: 5

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
                                    showBorder: false
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

                        // Auto-scroll to show carousel when it gets focus
                        onActiveFocusChanged: {
                            if (activeFocus) {
                                // Scroll flickable to show similar games section
                                var targetY = similarGamesSection.y - 20
                                metadataFlickable.contentY = Math.min(targetY, metadataFlickable.contentHeight - metadataFlickable.height)
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
        width: 180
        spacing: 3

        Text {
            text: label
            color: "#888"
            font.pixelSize: 9
            font.bold: true
            font.letterSpacing: 1.5
        }

        Text {
            text: value
            color: "#fff"
            font.pixelSize: 14
            font.bold: true
            elide: Text.ElideRight
            width: parent.width
        }
    }

    // Button component for game actions
    component GameButton: Rectangle {
        id: btn

        property string text: ""
        property string iconSource: ""
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

        // Text label (for PLAY button)
        Text {
            anchors.centerIn: parent
            text: btn.text
            visible: btn.text !== "" && btn.iconSource === ""
            color: {
                if (primary || active) return "#fff"
                if (focused || mouseArea.containsMouse) return btn.activeAccentColor
                return "#888"
            }
            font.pixelSize: primary ? 20 : 20
            font.bold: true
        }

        // SVG icon (for icon buttons)
        Image {
            anchors.centerIn: parent
            width: 24
            height: 24
            source: btn.iconSource
            visible: btn.iconSource !== ""
            sourceSize: Qt.size(24, 24)

            // Tint the SVG using ColorOverlay effect
            layer.enabled: true
            layer.effect: Item {
                property color overlayColor: {
                    if (btn.primary || btn.active) return "#fff"
                    if (btn.focused || mouseArea.containsMouse) return btn.activeAccentColor
                    return "#888"
                }
            }
        }

        // Color overlay for SVG tinting
        Rectangle {
            id: iconOverlay
            anchors.centerIn: parent
            width: 24
            height: 24
            color: "transparent"
            visible: btn.iconSource !== ""

            Image {
                id: iconImage
                anchors.fill: parent
                source: btn.iconSource
                sourceSize: Qt.size(24, 24)
                visible: false
            }

            // Simple color tint using ShaderEffectSource would be ideal,
            // but for compatibility, we'll use a colored rectangle with mask
            Canvas {
                id: tintedIcon
                anchors.fill: parent
                visible: btn.iconSource !== ""

                property color tintColor: {
                    if (btn.primary || btn.active) return "#fff"
                    if (btn.focused || mouseArea.containsMouse) return btn.activeAccentColor
                    return "#888"
                }

                onTintColorChanged: requestPaint()
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.fillStyle = tintColor
                    ctx.globalCompositeOperation = "source-over"

                    // Draw a simple shape based on icon type
                    if (btn.iconSource.indexOf("heart") >= 0) {
                        // Heart shape
                        ctx.beginPath()
                        ctx.moveTo(12, 20)
                        ctx.bezierCurveTo(12, 20, 4, 14, 4, 9)
                        ctx.bezierCurveTo(4, 6, 6.5, 4, 9, 4)
                        ctx.bezierCurveTo(10.5, 4, 11.5, 5, 12, 6)
                        ctx.bezierCurveTo(12.5, 5, 13.5, 4, 15, 4)
                        ctx.bezierCurveTo(17.5, 4, 20, 6, 20, 9)
                        ctx.bezierCurveTo(20, 14, 12, 20, 12, 20)
                        ctx.fill()
                    } else if (btn.iconSource.indexOf("backlog") >= 0) {
                        // Play triangle
                        ctx.beginPath()
                        ctx.moveTo(7, 4)
                        ctx.lineTo(7, 20)
                        ctx.lineTo(19, 12)
                        ctx.closePath()
                        ctx.fill()
                    } else if (btn.iconSource.indexOf("trophy") >= 0) {
                        // Trophy shape (simplified)
                        ctx.beginPath()
                        // Cup
                        ctx.moveTo(6, 4)
                        ctx.lineTo(18, 4)
                        ctx.lineTo(17, 10)
                        ctx.bezierCurveTo(17, 13, 14, 14, 12, 14)
                        ctx.bezierCurveTo(10, 14, 7, 13, 7, 10)
                        ctx.lineTo(6, 4)
                        ctx.fill()
                        // Stem
                        ctx.fillRect(10, 14, 4, 3)
                        // Base
                        ctx.fillRect(8, 17, 8, 3)
                    }
                }
            }
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
