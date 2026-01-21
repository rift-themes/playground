import QtQuick
import QtMultimedia

/**
 * Unified Second Display
 * Single QML that handles all secondary display states: home, games, game
 */
Rectangle {
    id: root
    color: "#031921"

    // Current page/mode: "home", "games", "game"
    property string currentPage: "home"

    // Fonts
    FontLoader { id: headlineFont; source: "../fonts/Nulshock Bd.otf" }
    property string fontHeadline: headlineFont.status === FontLoader.Ready ? headlineFont.name : "sans-serif"

    // Platform properties (for home)
    property int platformId: 0
    property string platformName: ""
    property string platformManufacturer: ""
    property string platformReleaseYear: ""
    property string platformType: ""
    property string platformDescription: ""
    property string platformLogo: ""

    // Game properties (for games/game)
    property int gameId: 0
    property string gameTitle: ""
    property string gamePlatform: ""
    property string gameDeveloper: ""
    property string gamePublisher: ""
    property string gameReleaseDate: ""
    property string gameGenre: ""
    property string gamePlayers: ""
    property string gameRating: ""
    property string gameDescription: ""
    property string gameBoxart: ""
    property string gameScreenshot: ""
    property string gameVideo: ""  // Kept for API compatibility but not used
    property int achievementCount: 0
    property int achievementPoints: 0

    // Playing state
    property bool isPlaying: false

    // ============== HOME VIEW ==============
    Item {
        id: homeView
        anchors.fill: parent
        visible: root.currentPage === "home"

        // Platform logo - almost fullscreen
        Image {
            id: platformLogoImage
            anchors.fill: parent
            anchors.margins: 4
            anchors.bottomMargin: 60
            source: root.platformLogo
            fillMode: Image.PreserveAspectFit
            visible: root.platformLogo !== ""
            asynchronous: true
        }

        // Rift logo fallback when no platform logo
        Image {
            anchors.centerIn: parent
            width: parent.width * 0.5
            height: width
            source: "qrc:/icons/rift-logo.png"
            fillMode: Image.PreserveAspectFit
            visible: root.platformLogo === ""
            opacity: 0.8
        }

        // Platform info at bottom
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 16
            spacing: 4
            visible: root.platformName !== ""

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.platformReleaseYear
                color: "#e94560"
                font.pixelSize: 32
                font.family: root.fontHeadline
                visible: text !== ""
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.platformDescription
                color: "#AAAAAA"
                font.pixelSize: 24
                width: root.width - 40
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
                visible: text !== ""
            }
        }
    }

    // ============== GAMES LIST VIEW ==============
    Item {
        id: gamesView
        anchors.fill: parent
        visible: root.currentPage === "games"

        // Rift logo when no game selected
        Image {
            anchors.centerIn: parent
            width: parent.width * 0.5
            height: width
            source: "qrc:/icons/rift-logo.png"
            fillMode: Image.PreserveAspectFit
            visible: root.gameScreenshot === "" && root.gameVideo === ""
            opacity: 0.8
        }

        // Video player - loaded dynamically only when video available
        Loader {
            id: gamesVideoLoader
            anchors.fill: parent
            active: root.currentPage === "games" && root.gameVideo !== ""

            sourceComponent: Video {
                anchors.fill: parent
                source: root.gameVideo
                fillMode: VideoOutput.PreserveAspectFit
                loops: MediaPlayer.Infinite

                Component.onCompleted: play()
            }
        }

        // Screenshot fallback (when no video)
        Image {
            anchors.fill: parent
            source: root.gameScreenshot
            fillMode: Image.PreserveAspectFit
            visible: !gamesVideoLoader.active && root.gameScreenshot !== ""
            asynchronous: true
        }

        // Title overlay at bottom
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: gamesTitleText.height + 24
            color: "#CC031921"
            visible: root.gameTitle !== ""

            Text {
                id: gamesTitleText
                anchors.centerIn: parent
                width: parent.width - 32
                text: root.gameTitle
                color: "#FFFFFF"
                font.pixelSize: 20
                font.family: root.fontHeadline
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
        }
    }

    // ============== GAME DETAIL VIEW ==============
    Item {
        id: gameView
        anchors.fill: parent
        visible: root.currentPage === "game"

        // Only show description - centered on screen
        Text {
            anchors.fill: parent
            anchors.margins: 24
            text: root.gameDescription
            color: "#CCCCCC"
            font.pixelSize: 28
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            visible: root.gameDescription !== ""
        }

        // Fallback when no description
        Text {
            anchors.centerIn: parent
            text: root.gameTitle
            color: "#666666"
            font.pixelSize: 24
            font.family: root.fontHeadline
            visible: root.gameDescription === ""
        }
    }
}
