import QtQuick
import Rift 1.0
import ".."

FocusScope {
    id: root

    Colors { id: colors }
    focus: true

    FontLoader { id: headlineFont; source: "../fonts/Nulshock Bd.otf" }
    property string fontHeadline: headlineFont.status === FontLoader.Ready ? headlineFont.name : "sans-serif"

    property int initialGameIndex: 0
    onInitialGameIndexChanged: Qt.callLater(restoreSelection)

    property var platform: Rift.platforms.get(0)
    property int platformId: platform?.id ?? -1

    property var gamesModel: Rift.getGamesModelForPlatform(platformId)

    property int selectedIndex: gamesListView.currentIndex
    property var selectedGame: gamesModel ? gamesModel.get(selectedIndex) : null

    function restoreSelection() {
        if (!gamesModel || gamesModel.count <= 0)
            return
        var idx = Math.max(0, Math.min(initialGameIndex, gamesModel.count - 1))
        gamesListView.currentIndex = idx
        gamesListView.positionViewAtIndex(idx, ListView.Contain)
    }

    Connections {
        target: gamesModel
        function onCountChanged() { Qt.callLater(restoreSelection) }
    }

    Component.onCompleted: Qt.callLater(restoreSelection)

    onSelectedGameChanged: {
        if (selectedGame?.id) {
            Rift.selectedGameId = selectedGame.id
            Rift.setContextGameById(selectedGame.id)
        }
    }

    Component.onDestruction: Rift.contextGame = {}

    Rectangle {
        anchors.fill: parent
        color: colors.background
    }

    RiftContainer {
        fluid: true
        paddingX: 0
        paddingY: 0

        RiftRow {
            gutter: 0

            
            RiftCol {
                span: 4
                autoHeight: true

                Rectangle {
                    width: parent.width
                    height: root.height
                    color: colors.surface

                    Text {
                        id: listTitle
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 24
                        text: (platform?.displayName ?? "Games").replace(/\b(Nintendo|Sega|Sony)\b\s*/gi, "").trim()
                        color: colors.textPrimary
                        font.pixelSize: 24
                        font.family: root.fontHeadline
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }

                    ListView {
                        id: gamesListView
                        anchors.top: listTitle.bottom
                        anchors.topMargin: 16
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: root.height * 0.11 + 16
                        clip: true
                        focus: true
                        model: gamesModel                       
                        preferredHighlightBegin: height * 0.35
                        preferredHighlightEnd: height * 0.65
                        highlightRangeMode: ListView.ApplyRange
                        highlightMoveDuration: 160

                        delegate: Item {
                            required property var modelData
                            required property int index

                            width: gamesListView.width
                            height: 64

                            Rectangle {
                                anchors.fill: parent
                                color: index === gamesListView.currentIndex ? colors.accent
                                     : (hover.hovered ? colors.hover : "transparent")
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: 24
                                anchors.rightMargin: 16
                                text: modelData?.name ?? ""
                                color: index === gamesListView.currentIndex ? colors.textPrimary : colors.textList
                                font.pixelSize: 15
                                elide: Text.ElideRight
                            }

                            HoverHandler { id: hover }

                            TapHandler {
                                onTapped: {
                                    gamesListView.currentIndex = index
                                    Rift.navigation.push("game", { game: modelData, gameIndex: index })
                                }
                            }
                        }

                        Keys.onReturnPressed: activateCurrent()
                        Keys.onEnterPressed: activateCurrent()

                        Connections {
                            target: Rift.input
                            enabled: gamesListView.activeFocus
                            function onAccept() { gamesListView.activateCurrent() }
                        }

                        function activateCurrent() {
                            var game = gamesModel ? gamesModel.get(currentIndex) : null
                            if (game) {
                                Rift.navigation.push("game", { game: game, gameIndex: currentIndex })
                            }
                        }
                    }
                }
            }

            
            RiftCol {
                span: 8
                autoHeight: true

                Item {
                    width: parent.width
                    height: root.height
                    clip: true

                    CrossfadeImage {
                        anchors.fill: parent
                        fill: Image.PreserveAspectCrop
                        source: root.selectedGame?.fanart
                             || root.selectedGame?.screenshot || ""
                    }

                    
                    Rectangle {
                        anchors.fill: parent
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: colors.scrim0 }
                            GradientStop { position: 1.0; color: colors.scrim80 }
                        }
                    }

                    
                    CrossfadeImage {
                        id: heroLogo
                        anchors.centerIn: parent
                        width: Math.min(parent.width * 0.5, 520)
                        height: parent.height * 0.35
                        fill: Image.PreserveAspectFit
                        duration: 200
                        source: root.selectedGame?.marquee ?? ""
                    }

                    
                    Text {
                        anchors.centerIn: parent
                        width: parent.width * 0.7
                        text: root.selectedGame?.name ?? ""
                        color: colors.textPrimary
                        font.pixelSize: 40
                        font.family: root.fontHeadline
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        opacity: heroLogo.hasImage ? 0 : 1
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }
                }
            }
        }
    }

    /**
     * Two stacked images swapping roles, so one picture dissolves into the next. The
     * incoming layer only fades up once it has decoded, otherwise the transition dips
     * through a blank frame while the file loads.
     */
    component CrossfadeImage: Item {
        id: cf

        property string source: ""
        property int fill: Image.PreserveAspectCrop
        property int duration: 260
        readonly property bool hasImage: front.status === Image.Ready

        property bool usingB: false
        readonly property Image front: usingB ? imgB : imgA

        onSourceChanged: {
            var incoming = usingB ? imgA : imgB
            if (!source) {
                imgA.opacity = 0
                imgB.opacity = 0
                return
            }
            incoming.source = source
        }

        Image {
            id: imgA
            anchors.fill: parent
            fillMode: cf.fill
            asynchronous: true
            opacity: 0
            Behavior on opacity { NumberAnimation { duration: cf.duration } }
            onStatusChanged: if (status === Image.Ready && cf.usingB) cf.reveal(imgA, imgB)
        }

        Image {
            id: imgB
            anchors.fill: parent
            fillMode: cf.fill
            asynchronous: true
            opacity: 0
            Behavior on opacity { NumberAnimation { duration: cf.duration } }
            onStatusChanged: if (status === Image.Ready && !cf.usingB) cf.reveal(imgB, imgA)
        }

        function reveal(incoming, outgoing) {
            incoming.opacity = 1
            outgoing.opacity = 0
            usingB = !usingB
        }
    }
}
