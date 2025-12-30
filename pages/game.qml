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

    // Achievements data
    property var achievements: null
    property var detailedAchievements: []
    property var achievementsSummary: null
    property bool achievementsModalVisible: false
    property bool loadingAchievements: false
    property string achievementsError: ""
    property bool openModalOnLoad: false  // Flag to control if modal should open after fetch

    // Similar games
    property var similarGames: []

    // Extract summary when detailed achievements are received
    onDetailedAchievementsChanged: {
        if (detailedAchievements.length > 0 && detailedAchievements[0].isSummary) {
            achievementsSummary = detailedAchievements[0]
        }
    }

    // Load achievements and similar games when game changes
    onGameChanged: {
        if (game && game.platformId) {
            achievements = Rift.getGameAchievementsByName(game.platformId, game.name ?? "", game.md5 ?? "")
            // Auto-fetch detailed achievements with user progress
            if (achievements && achievements.id) {
                detailedAchievements = []
                achievementsSummary = null
                Rift.fetchDetailedAchievements(achievements.id)
            }
            // Load similar games
            similarGames = Rift.getSimilarGames(game.id, 8)
        } else {
            achievements = null
            detailedAchievements = []
            achievementsSummary = null
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
            Column {
                width: parent.width
                spacing: 8

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
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 4
                    visible: game?.rating > 0

                    Repeater {
                        model: 5
                        Text {
                            text: index < Math.round((game?.rating ?? 0) * 5) ? "★" : "☆"
                            color: index < Math.round((game?.rating ?? 0) * 5) ? "#FFD700" : "#555"
                            font.pixelSize: 28
                        }
                    }
                }
            }

            // Buttons with focus navigation
            FocusScope {
                id: buttonsArea
                width: parent.width
                height: buttonsColumn.height
                focus: true

                property int focusedButton: 0
                property int buttonCount: achievements && achievements.numAchievements > 0 ? 3 : 2

                Column {
                    id: buttonsColumn
                    width: parent.width
                    spacing: 12

                    // Play button
                    Rectangle {
                        id: playButton
                        width: parent.width
                        height: 56
                        radius: 28
                        property bool isFocused: buttonsArea.focusedButton === 0 && buttonsArea.activeFocus
                        color: isFocused || playButtonArea.containsMouse ? "#ff5a7a" : "#e94560"
                        scale: playButtonArea.pressed ? 0.95 : 1.0
                        border.color: isFocused ? "#fff" : "transparent"
                        border.width: isFocused ? 3 : 0

                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on scale { NumberAnimation { duration: 100 } }

                        Text {
                            anchors.centerIn: parent
                            text: "PLAY"
                            color: "#fff"
                            font.pixelSize: 20
                            font.bold: true
                        }

                        MouseArea {
                            id: playButtonArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: {
                                if (game) Rift.launchGame(game.id)
                            }
                        }
                    }

                    // Secondary buttons pill (Favorite + Achievements)
                    Row {
                        width: parent.width
                        spacing: 8

                        // Favorite button
                        Rectangle {
                            id: favoriteButton
                            width: achievements && achievements.numAchievements > 0 ? (parent.width - 8) / 2 : parent.width
                            height: 48
                            radius: 24
                            property bool isFocused: buttonsArea.focusedButton === 1 && buttonsArea.activeFocus
                            color: {
                                if (game?.favorite) {
                                    return isFocused || favoriteButtonArea.containsMouse ? "#ff5a7a" : "#e94560"
                                } else {
                                    return isFocused || favoriteButtonArea.containsMouse ? "#444" : "#333"
                                }
                            }
                            border.color: isFocused ? "#fff" : (game?.favorite ? "#e94560" : (favoriteButtonArea.containsMouse ? "#777" : "#555"))
                            border.width: isFocused ? 3 : 1
                            scale: favoriteButtonArea.pressed ? 0.95 : 1.0

                            Behavior on color { ColorAnimation { duration: 150 } }
                            Behavior on scale { NumberAnimation { duration: 100 } }

                            Text {
                                anchors.centerIn: parent
                                text: "♥"
                                color: game?.favorite ? "#fff" : (favoriteButton.isFocused || favoriteButtonArea.containsMouse ? "#fff" : "#888")
                                font.pixelSize: 20
                            }

                            MouseArea {
                                id: favoriteButtonArea
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: {
                                    if (game) {
                                        Rift.setGameFavorite(game.id, !game.favorite)
                                        root.game = Rift.getGame(game.id)
                                    }
                                }
                            }
                        }

                        // Achievements button
                        Rectangle {
                            id: viewAchievementsButton
                            width: (parent.width - 8) / 2
                            height: 48
                            radius: 24
                            property bool isFocused: buttonsArea.focusedButton === 2 && buttonsArea.activeFocus
                            color: isFocused || viewAchievementsArea.containsMouse ? "#444" : "#333"
                            border.color: isFocused ? "#fff" : (viewAchievementsArea.containsMouse ? "#FFD700" : "#555")
                            border.width: isFocused ? 3 : 1
                            scale: viewAchievementsArea.pressed ? 0.95 : 1.0
                            visible: achievements && achievements.numAchievements > 0

                            Behavior on color { ColorAnimation { duration: 150 } }
                            Behavior on scale { NumberAnimation { duration: 100 } }

                            Text {
                                anchors.centerIn: parent
                                text: "★"
                                color: viewAchievementsButton.isFocused || viewAchievementsArea.containsMouse ? "#FFD700" : "#888"
                                font.pixelSize: 20
                            }

                            MouseArea {
                                id: viewAchievementsArea
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: {
                                    if (achievements && achievements.id) {
                                        root.openModalOnLoad = true
                                        if (detailedAchievements.length > 0) {
                                            root.achievementsModalVisible = true
                                            root.openModalOnLoad = false
                                        } else {
                                            root.loadingAchievements = true
                                            root.achievementsError = ""
                                            Rift.fetchDetailedAchievements(achievements.id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Keyboard/gamepad navigation
                Keys.onUpPressed: function(event) {
                    if (focusedButton > 0) focusedButton = 0
                    event.accepted = true
                }
                Keys.onDownPressed: function(event) {
                    if (focusedButton === 0) focusedButton = 1
                    event.accepted = true
                }
                Keys.onLeftPressed: function(event) {
                    if (focusedButton === 2) focusedButton = 1
                    event.accepted = true
                }
                Keys.onRightPressed: function(event) {
                    if (focusedButton === 1 && buttonCount > 2) {
                        focusedButton = 2
                    } else if (similarGames && similarGames.length > 0) {
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
                        if (achievements && achievements.id) {
                            root.openModalOnLoad = true
                            if (detailedAchievements.length > 0) {
                                root.achievementsModalVisible = true
                                root.openModalOnLoad = false
                            } else {
                                root.loadingAchievements = true
                                root.achievementsError = ""
                                Rift.fetchDetailedAchievements(achievements.id)
                            }
                        }
                    }
                }
            }
            }

            // Right column - All metadata (9 cols)
            RiftCol {
                span: 9
                spacing: 20

            // Game title (hidden if boxart is available)
            Text {
                width: parent.width
                text: game?.name ?? ""
                color: "#fff"
                font.pixelSize: 48
                font.bold: true
                wrapMode: Text.WordWrap
                visible: !game?.boxart
            }

            // Subtitle with platform (hidden if boxart is available)
            Text {
                text: game?.platformName ?? ""
                color: "#888"
                font.pixelSize: 18
                font.italic: true
                visible: !game?.boxart
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
                    value: achievements ? (achievementsSummary
                        ? (achievementsSummary.numEarned + " / " + achievementsSummary.numAchievements)
                        : (achievements.numAchievements + " available"))
                        : "-"
                    visible: achievements && achievements.numAchievements > 0
                }

                // Achievement points
                MetadataItem {
                    label: "POINTS"
                    value: achievementsSummary
                        ? (achievementsSummary.earnedPoints + " / " + achievementsSummary.totalPoints)
                        : (achievements?.points ?? 0).toString()
                    visible: achievements && achievements.numAchievements > 0
                }
            }

            // Achievements progress bar
            Rectangle {
                width: parent.width * 0.4
                height: 8
                radius: 4
                color: "#333"
                visible: achievementsSummary !== null

                Rectangle {
                    width: parent.width * ((achievementsSummary?.percentComplete ?? 0) / 100)
                    height: parent.height
                    radius: 4
                    color: "#FFD700"

                    Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutQuad } }
                }
            }

            // Description
            Column {
                width: parent.width
                spacing: 8
                visible: game?.description

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

            // Last played
            Text {
                text: game?.lastPlayed ? "Last played: " + Qt.formatDateTime(game.lastPlayed, "MMM d, yyyy") : ""
                color: "#666"
                font.pixelSize: 13
                visible: game?.lastPlayed
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

                    // Custom delegate for game cards
                    delegate: Component {
                        Item {
                            property var modelData
                            property int itemIndex
                            property bool isSelected

                            Rectangle {
                                anchors.fill: parent
                                radius: 6
                                color: isSelected ? "#333" : "#222"
                                border.color: isSelected ? "#e94560" : "transparent"
                                border.width: 2

                                Behavior on color { ColorAnimation { duration: 150 } }

                                // Boxart
                                Image {
                                    id: similarBoxart
                                    anchors.fill: parent
                                    anchors.margins: 3
                                    source: modelData?.boxart ?? ""
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true

                                    opacity: status === Image.Ready ? 1 : 0
                                    Behavior on opacity { NumberAnimation { duration: 200 } }
                                }

                                // Fallback text if no boxart
                                Text {
                                    anchors.centerIn: parent
                                    anchors.margins: 6
                                    width: parent.width - 12
                                    text: modelData?.name ?? ""
                                    color: "#888"
                                    font.pixelSize: 9
                                    wrapMode: Text.WordWrap
                                    horizontalAlignment: Text.AlignHCenter
                                    visible: similarBoxart.status !== Image.Ready
                                }
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
            }
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
        function onDetailedAchievementsReceived(achievementsList) {
            console.log("Received achievements:", achievementsList.length)
            root.detailedAchievements = achievementsList
            root.achievementsError = ""
            root.loadingAchievements = false
            if (root.openModalOnLoad) {
                root.achievementsModalVisible = true
                root.openModalOnLoad = false
            }
        }
        function onDetailedAchievementsError(error) {
            console.log("Failed to fetch achievements:", error)
            root.detailedAchievements = []
            root.achievementsError = error
            root.loadingAchievements = false
            if (root.openModalOnLoad) {
                root.achievementsModalVisible = true
                root.openModalOnLoad = false
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

    // Loading indicator
    Rectangle {
        anchors.fill: parent
        color: "#80000000"
        visible: loadingAchievements

        Text {
            anchors.centerIn: parent
            text: "Loading achievements..."
            color: "#fff"
            font.pixelSize: 18
        }
    }

    // Achievements modal overlay
    Rectangle {
        id: achievementsModal
        anchors.fill: parent
        color: "#E0000000"
        visible: achievementsModalVisible
        opacity: achievementsModalVisible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        MouseArea {
            anchors.fill: parent
            onClicked: achievementsModalVisible = false
        }

        // Modal content
        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.8
            height: parent.height * 0.85
            color: "#1a1a2e"
            radius: 16

            MouseArea {
                anchors.fill: parent
                onClicked: {} // Prevent clicks from closing modal
            }

            Column {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 16

                // Header
                Row {
                    width: parent.width
                    height: 40
                    spacing: 16

                    Text {
                        text: "ACHIEVEMENTS"
                        color: "#fff"
                        font.pixelSize: 24
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Progress info
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12
                        visible: achievementsSummary !== null

                        // Progress bar
                        Rectangle {
                            width: 200
                            height: 8
                            radius: 4
                            color: "#333"
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                width: parent.width * ((achievementsSummary?.percentComplete ?? 0) / 100)
                                height: parent.height
                                radius: 4
                                color: "#FFD700"
                            }
                        }

                        Text {
                            text: (achievementsSummary?.numEarned ?? 0) + "/" + (achievementsSummary?.numAchievements ?? 0) +
                                  " (" + (achievementsSummary?.percentComplete ?? 0) + "%)"
                            color: "#888"
                            font.pixelSize: 14
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                }

                // Separator
                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#333"
                }

                // Login form when no API key
                Rectangle {
                    width: parent.width
                    height: parent.height - 60
                    color: "transparent"
                    visible: achievementsError.indexOf("API key") !== -1

                    Column {
                        anchors.centerIn: parent
                        spacing: 20
                        width: 400

                        // Icon
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "RetroAchievements"
                            color: "#FFD700"
                            font.pixelSize: 24
                            font.bold: true
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Sign in to view achievements"
                            color: "#888"
                            font.pixelSize: 14
                        }

                        // Username field
                        Column {
                            width: parent.width
                            spacing: 6

                            Text {
                                text: "Username"
                                color: "#888"
                                font.pixelSize: 12
                            }

                            Rectangle {
                                width: parent.width
                                height: 44
                                radius: 8
                                color: "#2a2a4e"
                                border.color: raUsernameField.activeFocus ? "#e94560" : "#444"
                                border.width: 1

                                TextInput {
                                    id: raUsernameField
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    color: "#fff"
                                    font.pixelSize: 14
                                    verticalAlignment: TextInput.AlignVCenter
                                    clip: true

                                    Text {
                                        anchors.fill: parent
                                        verticalAlignment: Text.AlignVCenter
                                        text: "Enter your username"
                                        color: "#666"
                                        font.pixelSize: 14
                                        visible: !parent.text && !parent.activeFocus
                                    }
                                }
                            }
                        }

                        // API Key field
                        Column {
                            width: parent.width
                            spacing: 6

                            Text {
                                text: "API Key"
                                color: "#888"
                                font.pixelSize: 12
                            }

                            Rectangle {
                                width: parent.width
                                height: 44
                                radius: 8
                                color: "#2a2a4e"
                                border.color: raApiKeyField.activeFocus ? "#e94560" : "#444"
                                border.width: 1

                                TextInput {
                                    id: raApiKeyField
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    color: "#fff"
                                    font.pixelSize: 14
                                    verticalAlignment: TextInput.AlignVCenter
                                    echoMode: TextInput.Password
                                    clip: true

                                    Text {
                                        anchors.fill: parent
                                        verticalAlignment: Text.AlignVCenter
                                        text: "Enter your API key"
                                        color: "#666"
                                        font.pixelSize: 14
                                        visible: !parent.text && !parent.activeFocus
                                    }
                                }
                            }

                            Text {
                                text: "Find your API key at retroachievements.org/settings"
                                color: "#666"
                                font.pixelSize: 11
                            }
                        }

                        // Login button
                        Rectangle {
                            width: parent.width
                            height: 48
                            radius: 24
                            color: (raUsernameField.text && raApiKeyField.text) ?
                                   (loginButtonArea.containsMouse ? "#ff5a7a" : "#e94560") : "#444"
                            scale: loginButtonArea.pressed ? 0.95 : 1.0

                            Behavior on color { ColorAnimation { duration: 150 } }
                            Behavior on scale { NumberAnimation { duration: 100 } }

                            Text {
                                anchors.centerIn: parent
                                text: "Sign In"
                                color: (raUsernameField.text && raApiKeyField.text) ? "#fff" : "#888"
                                font.pixelSize: 16
                                font.bold: true
                            }

                            MouseArea {
                                id: loginButtonArea
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: {
                                    if (raUsernameField.text && raApiKeyField.text) {
                                        // Save credentials
                                        Rift.retroachievementsUsername = raUsernameField.text
                                        Rift.retroachievementsPassword = raApiKeyField.text

                                        // Retry fetching achievements
                                        root.achievementsError = ""
                                        root.loadingAchievements = true
                                        Rift.fetchDetailedAchievements(achievements.id)
                                    }
                                }
                            }
                        }
                    }
                }

                // Other error message (not API key related)
                Rectangle {
                    width: parent.width
                    height: parent.height - 60
                    color: "transparent"
                    visible: achievementsError !== "" && achievementsError.indexOf("API key") === -1

                    Column {
                        anchors.centerIn: parent
                        spacing: 16

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "!"
                            color: "#e94560"
                            font.pixelSize: 48
                            font.bold: true
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: achievementsError
                            color: "#888"
                            font.pixelSize: 16
                        }
                    }
                }

                // Achievements grid
                GridView {
                    id: achievementsGrid
                    width: parent.width
                    height: parent.height - 60
                    cellWidth: width / 3
                    cellHeight: 120
                    clip: true
                    // Filter out the summary item
                    model: detailedAchievements.filter(function(item) { return !item.isSummary })
                    visible: achievementsError === ""
                    boundsBehavior: Flickable.StopAtBounds

                    // Smooth scrolling
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }

                    delegate: Item {
                        id: achievementDelegate
                        width: achievementsGrid.cellWidth
                        height: achievementsGrid.cellHeight

                        property bool isEarned: modelData.earned ?? false

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 4
                            radius: 8
                            color: {
                                if (achievementArea.containsMouse) {
                                    return isEarned ? "#2a3a2e" : "#2a2a4e"
                                }
                                return isEarned ? "#1a2a1e" : "transparent"
                            }
                            border.color: isEarned ? "#4a8" : "transparent"
                            border.width: isEarned ? 1 : 0

                            Behavior on color { ColorAnimation { duration: 150 } }

                            MouseArea {
                                id: achievementArea
                                anchors.fill: parent
                                hoverEnabled: true
                            }

                            Row {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 12

                                // Badge image
                                Item {
                                    width: 64
                                    height: 64
                                    anchors.verticalCenter: parent.verticalCenter

                                    Image {
                                        id: badgeImage
                                        anchors.fill: parent
                                        source: modelData.badgeUrl ?? ""
                                        fillMode: Image.PreserveAspectFit
                                        asynchronous: true
                                        opacity: isEarned ? 1.0 : 0.5

                                        // Placeholder while loading
                                        Rectangle {
                                            anchors.fill: parent
                                            color: "#333"
                                            radius: 8
                                            visible: badgeImage.status !== Image.Ready
                                        }
                                    }

                                    // Earned checkmark
                                    Rectangle {
                                        visible: isEarned
                                        anchors.right: parent.right
                                        anchors.bottom: parent.bottom
                                        width: 20
                                        height: 20
                                        radius: 10
                                        color: "#4a8"

                                        Text {
                                            anchors.centerIn: parent
                                            text: "✓"
                                            color: "#fff"
                                            font.pixelSize: 12
                                            font.bold: true
                                        }
                                    }
                                }

                                // Achievement info
                                Column {
                                    width: parent.width - 76
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 4

                                    Text {
                                        width: parent.width
                                        text: modelData.title ?? ""
                                        color: isEarned ? "#fff" : (achievementArea.containsMouse ? "#ccc" : "#888")
                                        font.pixelSize: 13
                                        font.bold: true
                                        elide: Text.ElideRight
                                        wrapMode: Text.WordWrap
                                        maximumLineCount: 2
                                    }

                                    Text {
                                        width: parent.width
                                        text: modelData.description ?? ""
                                        color: isEarned ? "#aaa" : (achievementArea.containsMouse ? "#888" : "#666")
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                        wrapMode: Text.WordWrap
                                        maximumLineCount: 2
                                    }

                                    Row {
                                        spacing: 8
                                        Text {
                                            text: (modelData.points ?? 0) + " pts"
                                            color: isEarned ? "#FFD700" : "#886"
                                            font.pixelSize: 11
                                            font.bold: true
                                        }
                                        Text {
                                            visible: modelData.hardcore ?? false
                                            text: "HARDCORE"
                                            color: "#e94560"
                                            font.pixelSize: 9
                                            font.bold: true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
