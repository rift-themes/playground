import QtQuick
import QtMultimedia

Rectangle {
    id: root
    color: "#031921"

    // Game properties (set by native code)
    property string gameVideo: ""
    property string gameBoxart: ""
    property string gameTitle: ""

    // Video player - fullscreen
    Video {
        id: videoPlayer
        anchors.fill: parent
        source: root.gameVideo
        fillMode: VideoOutput.PreserveAspectFit
        loops: MediaPlayer.Infinite
        visible: root.gameVideo !== ""

        onSourceChanged: {
            if (source !== "") {
                play()
            }
        }
    }

    // Fallback: show boxart if no video
    Image {
        anchors.fill: parent
        source: root.gameBoxart
        fillMode: Image.PreserveAspectFit
        visible: root.gameVideo === "" && root.gameBoxart !== ""
    }

    // Fallback: show title if no video or boxart
    Text {
        anchors.centerIn: parent
        text: root.gameTitle
        color: "#ffffff"
        font.pixelSize: 32
        font.bold: true
        visible: root.gameVideo === "" && root.gameBoxart === ""
    }
}
