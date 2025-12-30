import QtQuick
import QtQuick.Window
import QtQuick.Controls
import Rift 1.0

/**
 * Game - Detailed view of a single game
 * Full-screen immersive experience with all metadata
 */
FocusScope {
    id: root
    focus: true

    // Debug mode passed from parent theme
    property bool debugGrid: false

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

    // Signal to go back
    signal goBack()

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

    // Full-screen screenshot/fanart background
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: toFileUrl(game?.fanart ?? game?.screenshot ?? "")
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
    Item {
        anchors.fill: parent
        anchors.margins: 4


        // Left column - Boxart and quick info
        Column {
            id: leftColumn
            width: parent.width * 0.28
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 20
            spacing: 24

            // Boxart with glow effect
            Item {
                width: parent.width
                height: width * 1.4

                // Glow/shadow
                Rectangle {
                    anchors.fill: boxart
                    anchors.margins: -8
                    radius: 16
                    color: "#000"
                    opacity: 0.6

                    // Blur effect simulation
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -12
                        radius: 20
                        color: "#000"
                        opacity: 0.3
                    }
                }

                Image {
                    id: boxart
                    anchors.centerIn: parent
                    width: parent.width - 20
                    height: parent.height - 20
                    source: root.toFileUrl(game?.boxart ?? "")
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true

                    // Fade in
                    opacity: status === Image.Ready ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 300 } }
                }
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

            // Play button
            Rectangle {
                id: playButton
                width: parent.width
                height: 56
                radius: 28
                color: playButtonArea.containsMouse ? "#ff5a7a" : "#e94560"
                scale: playButtonArea.pressed ? 0.95 : 1.0

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

            // Favorite button
            Rectangle {
                id: favoriteButton
                width: parent.width
                height: 48
                radius: 24
                color: {
                    if (game?.favorite) {
                        return favoriteButtonArea.containsMouse ? "#ff5a7a" : "#e94560"
                    } else {
                        return favoriteButtonArea.containsMouse ? "#444" : "#333"
                    }
                }
                border.color: game?.favorite ? "#e94560" : (favoriteButtonArea.containsMouse ? "#777" : "#555")
                border.width: 1
                scale: favoriteButtonArea.pressed ? 0.95 : 1.0

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on scale { NumberAnimation { duration: 100 } }

                Row {
                    anchors.centerIn: parent
                    spacing: 8
                    Text {
                        text: "♥"
                        color: game?.favorite ? "#fff" : (favoriteButtonArea.containsMouse ? "#aaa" : "#888")
                        font.pixelSize: 18
                    }
                    Text {
                        text: game?.favorite ? "FAVORITE" : "ADD TO FAVORITES"
                        color: game?.favorite ? "#fff" : (favoriteButtonArea.containsMouse ? "#aaa" : "#888")
                        font.pixelSize: 14
                        font.bold: true
                    }
                }

                MouseArea {
                    id: favoriteButtonArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: {
                        if (game) {
                            Rift.setGameFavorite(game.id, !game.favorite)
                            // Re-fetch game data to update the UI
                            root.game = Rift.getGame(game.id)
                        }
                    }
                }
            }
        }

        // Right column - All metadata
        Column {
            anchors.left: leftColumn.right
            anchors.leftMargin: 48
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 20
            spacing: 20

            // Game title
            Text {
                width: parent.width
                text: game?.name ?? ""
                color: "#fff"
                font.pixelSize: 48
                font.bold: true
                wrapMode: Text.WordWrap
            }

            // Subtitle with platform
            Text {
                text: game?.platformName ?? ""
                color: "#888"
                font.pixelSize: 18
                font.italic: true
            }

            // Separator line
            Rectangle {
                width: parent.width * 0.3
                height: 3
                radius: 1.5
                color: "#e94560"
            }

            // Metadata grid
            Grid {
                columns: 2
                columnSpacing: 48
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
                    value: formatReleaseDate(game?.releaseDate)
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

            // Achievements section
            Column {
                width: parent.width
                spacing: 12
                visible: achievements && achievements.numAchievements > 0

                // Section header
                Text {
                    text: "ACHIEVEMENTS"
                    color: "#888"
                    font.pixelSize: 12
                    font.bold: true
                    font.letterSpacing: 2
                }

                // Progress bar (only if we have user progress)
                Column {
                    width: parent.width
                    spacing: 6
                    visible: achievementsSummary !== null

                    Row {
                        width: parent.width
                        Text {
                            text: (achievementsSummary?.numEarned ?? 0) + " / " + (achievementsSummary?.numAchievements ?? 0)
                            color: "#fff"
                            font.pixelSize: 14
                            font.bold: true
                        }
                        Item { width: 8; height: 1 }
                        Text {
                            text: "(" + (achievementsSummary?.percentComplete ?? 0) + "%)"
                            color: "#888"
                            font.pixelSize: 14
                        }
                        Item { width: 20; height: 1 }
                        Text {
                            text: (achievementsSummary?.earnedPoints ?? 0) + " / " + (achievementsSummary?.totalPoints ?? 0) + " pts"
                            color: "#FFD700"
                            font.pixelSize: 12
                        }
                    }

                    // Progress bar
                    Rectangle {
                        width: parent.width * 0.6
                        height: 8
                        radius: 4
                        color: "#333"

                        Rectangle {
                            width: parent.width * ((achievementsSummary?.percentComplete ?? 0) / 100)
                            height: parent.height
                            radius: 4
                            color: "#FFD700"

                            Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutQuad } }
                        }
                    }
                }

                // Achievements info row (when no user progress yet)
                Row {
                    spacing: 24
                    visible: achievementsSummary === null

                    // Achievement count
                    Row {
                        spacing: 8
                        Rectangle {
                            width: 36
                            height: 36
                            radius: 18
                            color: "#FFD700"
                            Text {
                                anchors.centerIn: parent
                                text: achievements?.numAchievements ?? 0
                                color: "#000"
                                font.pixelSize: 14
                                font.bold: true
                            }
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                text: "Achievements"
                                color: "#fff"
                                font.pixelSize: 14
                            }
                            Text {
                                text: (achievements?.points ?? 0) + " points"
                                color: "#888"
                                font.pixelSize: 11
                            }
                        }
                    }

                    // Leaderboards (if any)
                    Row {
                        spacing: 8
                        visible: (achievements?.numLeaderboards ?? 0) > 0
                        Rectangle {
                            width: 36
                            height: 36
                            radius: 18
                            color: "#4FC3F7"
                            Text {
                                anchors.centerIn: parent
                                text: achievements?.numLeaderboards ?? 0
                                color: "#000"
                                font.pixelSize: 14
                                font.bold: true
                            }
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Leaderboards"
                            color: "#fff"
                            font.pixelSize: 14
                        }
                    }
                }

                // View All button
                Rectangle {
                    id: viewAllButton
                    width: 140
                    height: 32
                    radius: 16
                    color: viewAllButtonArea.containsMouse ? "#444" : "#333"
                    border.color: viewAllButtonArea.containsMouse ? "#777" : "#555"
                    border.width: 1
                    scale: viewAllButtonArea.pressed ? 0.95 : 1.0

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on scale { NumberAnimation { duration: 100 } }

                    Text {
                        anchors.centerIn: parent
                        text: "View All"
                        color: viewAllButtonArea.containsMouse ? "#fff" : "#ccc"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    MouseArea {
                        id: viewAllButtonArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            console.log("View All clicked, achievements:", JSON.stringify(achievements))
                            if (achievements && achievements.id) {
                                console.log("Fetching detailed achievements for ID:", achievements.id)
                                root.openModalOnLoad = true  // Open modal when data is received
                                // If we already have data, just open the modal
                                if (detailedAchievements.length > 0) {
                                    root.achievementsModalVisible = true
                                    root.openModalOnLoad = false
                                } else {
                                    root.loadingAchievements = true
                                    root.achievementsError = ""
                                    Rift.fetchDetailedAchievements(achievements.id)
                                }
                            } else {
                                console.log("No achievements.id available")
                            }
                        }
                    }
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
                                    source: root.toFileUrl(modelData?.boxart ?? "")
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
                root.goBack()
            }
        }
        function onInputAccept() {
            if (!achievementsModalVisible && game) {
                Rift.launchGame(game.id)
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
            goBack()
        }
    }
    Keys.onBackPressed: {
        if (achievementsModalVisible) {
            achievementsModalVisible = false
        } else {
            goBack()
        }
    }
    Keys.onReturnPressed: {
        if (!achievementsModalVisible && game) Rift.launchGame(game.id)
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
