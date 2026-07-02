import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
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

    // Compact layout on short screens: the left column (boxart + quick info) only shows when
    // the screen is at least 500px tall; below that it's hidden and the right column goes full width.
    property bool isCompactScreen: height < 500

    // Load achievements and similar games when game changes
    onGameChanged: {
        if (game && game.platformId) {
            Rift.selectedGameId = game.id
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
        source: Rift.imageSource(game?.fanart ?? game?.screenshot ?? "")
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

            // Left column - Boxart and quick info (3 cols) - hidden on compact screens
            RiftCol {
                span: 3
                spacing: 24
                visible: !root.isCompactScreen

                // Boxart + Rating stars (no spacing between them)
                Image {
                    id: boxart
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: status === Image.Ready && implicitWidth > 0
                        ? width * (implicitHeight / implicitWidth)
                        : width * 1.4
                    source: Rift.imageSource(game?.boxart ?? "")
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
                    property bool hasValidDate: lastPlayedDate !== null && lastPlayedDate !== undefined
                        && !isNaN(new Date(lastPlayedDate).getTime())
                        && new Date(lastPlayedDate).getFullYear() > 1970
                    text: hasValidDate ? "Last played: " + Qt.formatDateTime(lastPlayedDate, "MMM d, yyyy") : ""
                    color: "#666"
                    font.pixelSize: 13
                    visible: hasValidDate
                }
            }

            // Right column - All metadata (9 cols, or 12 on compact screens)
            RiftCol {
                span: root.isCompactScreen ? 12 : 9

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
                        // Leave room at the bottom (~footer height) so the last section can scroll
                        // clear of the global RiftFooter instead of ending up hidden behind it.
                        bottomPadding: Math.round(root.height * 0.12) + 24

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
                        text: {
                            var desc = game?.description ?? ""
                            var dot = desc.indexOf(".")
                            return dot >= 0 ? desc.substring(0, dot + 1) : desc
                        }
                        color: "#ccc"
                        font.pixelSize: 15
                        lineHeight: 1.4
                        wrapMode: Text.WordWrap
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

                    // Animated auto-scroll back to the top when buttons regain focus (show title)
                    onActiveFocusChanged: {
                        if (activeFocus) {
                            revealScrollAnim.to = 0
                            revealScrollAnim.restart()
                        }
                    }

                    Row {
                        id: buttonsRow
                        width: parent.width
                        spacing: 12

                        // Play button
                        GameButton {
                            iconSource: "../icons/play.svg"
                            text: "PLAY"
                            primary: true
                            accentColor: "#2ecc71"
                            focused: buttonsArea.focusedButton === 0 && buttonsArea.activeFocus
                            onClicked: if (game) Rift.launchGame(game.id)
                        }

                        // Favorite button
                        GameButton {
                            iconSource: "../icons/heart.svg"
                            text: "FAVORITE"
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
                            iconSource: "../icons/backlog.svg"
                            text: "BACKLOG"
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
                            iconSource: "../icons/trophy.svg"
                            text: achievements ? (achievements.numAchievements + "") : ""
                            accentColor: "#FFD700"
                            focused: buttonsArea.focusedButton === 3 && buttonsArea.activeFocus
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


                    // Horizontal list for similar games. A ListView packs each cover by its OWN
                    // real width (box art aspects vary across systems), with a uniform gap and
                    // bottom-aligned — unlike a fixed-slot carousel, which left inconsistent gaps.
                    ListView {
                        id: similarGamesCarousel
                        width: parent.width
                        height: 180
                        clip: true
                        orientation: ListView.Horizontal
                        spacing: 14
                        model: similarGames
                        keyNavigationEnabled: false   // we drive currentIndex for boundary handling
                        boundsBehavior: Flickable.StopAtBounds

                        // Smoothly scroll to keep the current cover in view when selection changes
                        highlightRangeMode: ListView.ApplyRange
                        preferredHighlightBegin: 0
                        preferredHighlightEnd: width * 0.5
                        highlightMoveDuration: 220
                        highlightMoveVelocity: -1

                        signal itemActivated(int index)

                        // Open the selected similar game (updates in place). Return focus to the
                        // action buttons so the view scrolls back to the top and shows the new
                        // game's title/boxart instead of staying down on the similar-games list.
                        onItemActivated: function(index) {
                            var selectedGame = similarGamesModel.get(index)
                            if (selectedGame) {
                                root.game = Rift.getGame(selectedGame.id)
                                currentIndex = 0
                                buttonsArea.forceActiveFocus()
                            }
                        }

                        // Navigation (boundary -> back to the action buttons)
                        Keys.onLeftPressed: {
                            if (currentIndex > 0) currentIndex--
                            else buttonsArea.forceActiveFocus()
                        }
                        Keys.onRightPressed: {
                            if (currentIndex < count - 1) currentIndex++
                        }
                        Keys.onUpPressed: buttonsArea.forceActiveFocus()

                        // Animated auto-scroll to reveal the section when it gains focus.
                        NumberAnimation {
                            id: revealScrollAnim
                            target: metadataFlickable
                            property: "contentY"
                            duration: 250
                            easing.type: Easing.OutCubic
                        }

                        // Clamp to [0, maxScroll]: when the content fits the viewport, maxScroll is
                        // negative and an unclamped value would push contentY < 0, dropping the whole
                        // column down with a big empty top margin.
                        onActiveFocusChanged: {
                            if (activeFocus) {
                                var maxY = Math.max(0, metadataFlickable.contentHeight - metadataFlickable.height)
                                var targetY = similarGamesSection.y - 20
                                revealScrollAnim.to = Math.max(0, Math.min(targetY, maxY))
                                revealScrollAnim.restart()
                            }
                        }

                        delegate: Item {
                            id: del
                            required property var modelData
                            required property int index

                            height: ListView.view.height
                            width: cover.width   // real cover width drives the packing

                            Image {
                                id: cover
                                anchors.bottom: parent.bottom
                                height: parent.height
                                // Real width from the image's natural dimensions (no square veil)
                                width: implicitHeight > 0
                                       ? Math.round(height * implicitWidth / implicitHeight)
                                       : height
                                source: Rift.imageSource(del.modelData?.boxart ?? "")
                                fillMode: Image.PreserveAspectFit
                                sourceSize.height: Math.round(parent.height * 2)
                                asynchronous: true
                                smooth: true
                                // Only show the highlight when the carousel actually has focus, so
                                // moving focus from the buttons into the carousel is visible.
                                opacity: (del.ListView.isCurrentItem && similarGamesCarousel.activeFocus) ? 1.0 : 0.6
                                Behavior on opacity { NumberAnimation { duration: 150 } }
                            }

                            // Name caption over the bottom of the current cover
                            Rectangle {
                                anchors.bottom: cover.bottom
                                anchors.horizontalCenter: cover.horizontalCenter
                                width: cover.width
                                height: gameNameLabel.height + 8
                                color: "#CC000000"
                                visible: del.ListView.isCurrentItem && similarGamesCarousel.activeFocus

                                Text {
                                    id: gameNameLabel
                                    anchors.centerIn: parent
                                    text: del.modelData?.name ?? ""
                                    color: "#fff"
                                    font.pixelSize: 10
                                    font.bold: true
                                    elide: Text.ElideRight
                                    width: parent.width - 8
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    del.ListView.view.currentIndex = del.index
                                    del.ListView.view.itemActivated(del.index)
                                }
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
                Rift.navigateBack()
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
        // Refresh game data when artwork is updated
        function onGameUpdated(gameId) {
            if (game && game.id === gameId) {
                root.game = Rift.getGame(gameId)
            }
        }
    }

    // Keyboard handling
    Keys.onEscapePressed: {
        if (achievementsModalVisible) {
            achievementsModalVisible = false
        } else {
            Rift.navigateBack()
        }
    }
    Keys.onBackPressed: {
        if (achievementsModalVisible) {
            achievementsModalVisible = false
        } else {
            Rift.navigateBack()
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

    // Button component for game actions — labeled pill (glyph + text)
    component GameButton: Rectangle {
        id: btn

        property string text: ""
        property string iconSource: ""   // SVG icon (tinted to contentColor)
        property bool primary: false
        property bool active: false
        property bool focused: false
        property color accentColor: "#e94560"
        property color activeAccentColor: accentColor

        signal clicked()

        // Pill auto-sizes to its content
        height: 52
        radius: height / 2
        implicitWidth: contentRow.implicitWidth + (btn.text !== "" ? 40 : 30)
        width: implicitWidth

        // Per-button accent shown on the BACKGROUND when focused/hovered/active; black otherwise.
        readonly property color tone: active ? activeAccentColor : accentColor
        readonly property bool highlighted: focused || active || mouseArea.containsMouse

        // Black by default, accent fill on focus/hover/active (no border).
        color: highlighted ? (mouseArea.containsMouse ? Qt.lighter(tone, 1.12) : tone) : "#000000"

        scale: mouseArea.pressed ? 0.95 : 1.0

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on scale { NumberAnimation { duration: 100 } }

        // Text/glyph always white
        readonly property color contentColor: "#ffffff"

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: 8

            Image {
                anchors.verticalCenter: parent.verticalCenter
                visible: btn.iconSource !== ""
                source: btn.iconSource
                sourceSize: Qt.size(20, 20)
                width: 18
                height: 18
                fillMode: Image.PreserveAspectFit
                smooth: true
                // Tint to the button's content color (white) — cross-platform, so the icon
                // looks identical on PC and Android (no font-glyph fallback differences).
                layer.enabled: true
                layer.effect: ColorOverlay { color: btn.contentColor }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: btn.text !== ""
                text: btn.text
                color: btn.contentColor
                font.pixelSize: 15
                font.bold: true
                font.letterSpacing: 0.5
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
