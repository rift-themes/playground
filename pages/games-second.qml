import QtQuick

/**
 * Games Second Screen - Game list browsing view
 * Shows game boxart with info overlay
 */
Rectangle {
    id: root
    color: "#031921"

    // Fonts
    FontLoader { id: headlineFont; source: "../fonts/Nulshock Bd.otf" }
    property string fontHeadline: headlineFont.status === FontLoader.Ready ? headlineFont.name : "sans-serif"

    // Game properties (set by native code)
    property int gameId: 0
    property string gameTitle: ""
    property string gamePlatform: ""
    property string gameDeveloper: ""
    property string gameReleaseDate: ""
    property string gameGenre: ""
    property string gameDescription: ""
    property string gameBoxart: ""
    property string gameVideo: ""
    property int achievementCount: 0
    property int achievementPoints: 0

    // Idle state - show Rift logo when no game selected
    Image {
        id: logoImage
        anchors.centerIn: parent
        width: parent.width
        height: width
        source: "qrc:/icons/rift-logo.png"
        fillMode: Image.PreserveAspectFit
        visible: root.gameBoxart === ""
        opacity: 0.8
    }

    // Game view - full screen boxart with overlay
    Item {
        id: gameView
        anchors.fill: parent
        visible: root.gameBoxart !== ""

        // Game boxart - full screen, aligned to top
        Image {
            id: boxartImage
            anchors.fill: parent
            source: root.gameBoxart
            fillMode: Image.PreserveAspectFit
            verticalAlignment: Image.AlignTop
        }

        // Text overlay at bottom
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: infoColumn.height + 16
            color: "#CC031921"

            Column {
                id: infoColumn
                anchors.centerIn: parent
                spacing: 4

                // Title
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.gameTitle
                    color: "#FFFFFF"
                    font.pixelSize: 22
                    font.family: root.fontHeadline
                    elide: Text.ElideRight
                    width: Math.min(implicitWidth, root.width - 32)
                }

                // Developer & Year
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 12

                    Text {
                        text: root.gameDeveloper
                        color: "#e94560"
                        font.pixelSize: 16
                        visible: root.gameDeveloper !== ""
                    }

                    Text {
                        text: root.gameReleaseDate
                        color: "#AAAAAA"
                        font.pixelSize: 16
                        visible: root.gameReleaseDate !== ""
                    }
                }

                // Genre & Achievements
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 16

                    Text {
                        text: root.gameGenre
                        color: "#888888"
                        font.pixelSize: 14
                        visible: root.gameGenre !== ""
                    }

                    Text {
                        text: root.achievementCount + " achievements"
                        color: "#FFD700"
                        font.pixelSize: 14
                        visible: root.achievementCount > 0
                    }
                }
            }
        }
    }
}
