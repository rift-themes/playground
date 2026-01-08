import QtQuick

/**
 * Home Second Screen - Platform carousel view
 * Full-screen image with text overlay
 */
Rectangle {
    id: root
    color: "#031921"

    // Fonts
    FontLoader { id: headlineFont; source: "../fonts/Nulshock Bd.otf" }
    property string fontHeadline: headlineFont.status === FontLoader.Ready ? headlineFont.name : "sans-serif"

    // Platform properties (set by native code)
    property int platformId: 0
    property string platformName: ""
    property string platformManufacturer: ""
    property string platformReleaseYear: ""
    property string platformType: ""
    property string platformDescription: ""
    property string platformLogo: ""

    // Idle state - show Rift logo when no platform selected
    Image {
        id: logoImage
        anchors.centerIn: parent
        width: parent.width
        height: width
        source: "qrc:/icons/rift-logo.png"
        fillMode: Image.PreserveAspectFit
        visible: root.platformLogo === ""
        opacity: 0.8
    }

    // Platform view - full screen image with overlay
    Item {
        id: platformView
        anchors.fill: parent
        visible: root.platformLogo !== ""

        // Platform logo - full screen, aligned to top
        Image {
            id: platformLogoImage
            width: parent.width
            height: width
            anchors.fill: parent
            source: root.platformLogo
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

                // Manufacturer & Year
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 12

                    Text {
                        text: root.platformManufacturer
                        color: "#e94560"
                        font.pixelSize: 24
                        font.family: root.fontHeadline
                        visible: root.platformManufacturer !== ""
                    }

                    Text {
                        text: root.platformReleaseYear
                        color: "#AAAAAA"
                        font.pixelSize: 24
                        visible: root.platformReleaseYear !== ""
                    }
                }

                // Description
                Text {
                    width: root.width - 32
                    horizontalAlignment: Text.AlignHCenter
                    text: root.platformDescription
                    color: "#CCCCCC"
                    font.pixelSize: 18
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }
            }
        }
    }
}
