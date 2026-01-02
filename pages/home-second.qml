import QtQuick

/**
 * Home Second Screen - Platform carousel view
 * Shows platform info when browsing the home screen
 */
Rectangle {
    id: root
    color: "#031921"

    // State: 0=IDLE, 1=BROWSING, 2=DETAIL, 3=PLAYING, 4=PLATFORM
    property int state: 0

    // Platform properties (set by native code)
    property int platformId: 0
    property string platformName: ""
    property string platformManufacturer: ""
    property string platformReleaseYear: ""
    property string platformType: ""
    property string platformDescription: ""
    property string platformLogo: ""

    // Idle state - show Rift logo
    Image {
        id: logoImage
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.4, 200)
        height: width
        source: "qrc:/icons/rift-logo.png"
        fillMode: Image.PreserveAspectFit
        visible: root.state === 0
        opacity: 0.8
    }

    // Platform view - horizontal layout with logo and info
    Item {
        id: platformView
        anchors.fill: parent
        anchors.margins: 24
        visible: root.state === 4

        // Left side - Platform logo (larger)
        Image {
            id: platformLogoImage
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width * 0.45
            height: parent.height * 0.8
            source: root.platformLogo
            fillMode: Image.PreserveAspectFit
        }

        // Right side - Platform info
        Column {
            anchors.left: platformLogoImage.right
            anchors.leftMargin: 24
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            // Platform name
            Text {
                text: root.platformName
                color: "#ffffff"
                font.pixelSize: 28
                font.bold: true
                elide: Text.ElideRight
                width: parent.width
            }

            // Manufacturer & Year
            Row {
                spacing: 12

                Text {
                    text: root.platformManufacturer
                    color: "#e94560"
                    font.pixelSize: 16
                    visible: root.platformManufacturer !== ""
                }

                Text {
                    text: root.platformReleaseYear
                    color: "#888888"
                    font.pixelSize: 16
                    visible: root.platformReleaseYear !== ""
                }
            }

            // Separator
            Rectangle {
                width: parent.width * 0.8
                height: 1
                color: "#333333"
            }

            // Description
            Text {
                width: parent.width
                text: root.platformDescription
                color: "#d11919"
                font.pixelSize: 14
                wrapMode: Text.WordWrap
                lineHeight: 1.3
                maximumLineCount: 6
                elide: Text.ElideRight
            }
        }
    }
}
