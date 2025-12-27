import QtQuick
import QtQuick.Window
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
        anchors.margins: 48

        // Left column - Boxart and quick info
        Column {
            id: leftColumn
            width: parent.width * 0.28
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
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
                width: parent.width
                height: 56
                radius: 28
                color: "#e94560"

                Text {
                    anchors.centerIn: parent
                    text: "▶  PLAY"
                    color: "#fff"
                    font.pixelSize: 20
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (game) Rift.launchGame(game.id)
                    }
                }

                // Pulse animation when focused
                SequentialAnimation on scale {
                    running: root.activeFocus
                    loops: Animation.Infinite
                    NumberAnimation { to: 1.02; duration: 800; easing.type: Easing.InOutQuad }
                    NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
                }
            }
        }

        // Right column - All metadata
        Column {
            anchors.left: leftColumn.right
            anchors.leftMargin: 48
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 20

            // Wheel/Logo if available
            Image {
                width: Math.min(parent.width * 0.7, 500)
                height: 120
                source: root.toFileUrl(game?.marquee ?? "")
                fillMode: Image.PreserveAspectFit
                visible: game?.marquee
                asynchronous: true
            }

            // Game title (fallback if no wheel)
            Text {
                width: parent.width
                text: game?.name ?? ""
                color: "#fff"
                font.pixelSize: 48
                font.bold: true
                wrapMode: Text.WordWrap
                visible: !game?.marquee
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

            // Last played
            Text {
                text: game?.lastPlayed ? "Last played: " + Qt.formatDateTime(game.lastPlayed, "MMM d, yyyy") : ""
                color: "#666"
                font.pixelSize: 13
                visible: game?.lastPlayed
            }
        }
    }

    // Favorite badge
    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 24
        width: 48
        height: 48
        radius: 24
        color: game?.favorite ? "#e94560" : "#40000000"
        visible: true

        Text {
            anchors.centerIn: parent
            text: "♥"
            color: game?.favorite ? "#fff" : "#888"
            font.pixelSize: 24
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (game) {
                    Rift.setGameFavorite(game.id, !game.favorite)
                }
            }
        }
    }

    // Rift input handling
    Connections {
        target: Rift
        function onInputBack() { root.goBack() }
        function onInputAccept() {
            if (game) Rift.launchGame(game.id)
        }
    }

    // Keyboard handling
    Keys.onEscapePressed: goBack()
    Keys.onBackPressed: goBack()
    Keys.onReturnPressed: { if (game) Rift.launchGame(game.id) }

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
}
