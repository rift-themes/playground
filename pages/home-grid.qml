import QtQuick
import QtQuick.Window
import Rift 1.0

/**
 * HomeGrid - Grid system demo home page
 * Demonstrates the responsive 12-column grid with aspect ratio breakpoints
 */
Item {
    id: root

    // Debug mode passed from parent theme
    property bool debugGrid: false

    // Background
    Rectangle {
        anchors.fill: parent
        color: "#1a1a2e"
    }

    // Main container using the grid system
    RiftContainer {
        id: container
        fluid: true
        paddingX: 24
        paddingY: 24

        // Header row
        RiftRow {
            id: headerRow

            gutter: 16
            debug: root.debugGrid

            RiftCol {
                span: 12
                fixedHeight: 60
                autoHeight: false
                debug: root.debugGrid

                Rectangle {
                    anchors.fill: parent
                    color: "#16213e"
                    radius: 8

                    Text {
                        anchors.centerIn: parent
                        text: "Playground Theme - Grid System Test"
                        color: "#e94560"
                        font.pixelSize: 24
                        font.bold: true
                    }
                }
            }
        }

        // Spacer
        Item { width: 1; height: 24 }

        // Info row - shows current breakpoint and window size
        RiftRow {
            id: infoRow
            width: parent.width
            gutter: 16
            debug: root.debugGrid

            RiftCol {
                span: 12
                fixedHeight: 40
                autoHeight: false
                debug: root.debugGrid

                Rectangle {
                    anchors.fill: parent
                    color: "#0f3460"
                    radius: 4

                    Row {
                        anchors.centerIn: parent
                        spacing: 32

                        Text {
                            text: "Aspect: " + Rift.aspectInfo.label
                            color: "#fff"
                            font.pixelSize: 14
                        }
                        Text {
                            text: "Window: " + Window.width + " x " + Window.height
                            color: "#aaa"
                            font.pixelSize: 14
                        }
                        Text {
                            text: "Container: " + Math.round(container.width) + " px"
                            color: "#aaa"
                            font.pixelSize: 14
                        }
                    }
                }
            }
        }

        // Spacer
        Item { width: 1; height: 24 }

        // Main content row - responsive columns
        RiftRow {
            id: mainRow
            width: parent.width
            gutter: 16
            debug: root.debugGrid

            // Left column - Sidebar
            RiftCol {
                id: sidebarCol
                span: 3       // 1/4 on widescreen (16:9)
                span43: 4     // 1/3 on 4:3
                span11: 12    // Full width on 1:1
                fixedHeight: 400
                autoHeight: false
                debug: root.debugGrid

                Rectangle {
                    anchors.fill: parent
                    color: "#16213e"
                    radius: 8

                    Column {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 8

                        Text {
                            text: "Sidebar"
                            color: "#e94560"
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Text {
                            text: "span: 3 (16:9)"
                            color: "#888"
                            font.pixelSize: 12
                        }
                        Text {
                            text: "span43: 4 (4:3)"
                            color: "#888"
                            font.pixelSize: 12
                        }
                        Text {
                            text: "span11: 12 (1:1)"
                            color: "#888"
                            font.pixelSize: 12
                        }

                        Item { width: 1; height: 16 }

                        // Menu items
                        Repeater {
                            model: ["Home", "Games", "Collections", "Settings"]
                            delegate: Rectangle {
                                width: parent.width
                                height: 40
                                color: index === 0 ? "#e94560" : "transparent"
                                radius: 4

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: "#fff"
                                    font.pixelSize: 14
                                }
                            }
                        }
                    }
                }
            }

            // Right column - Main content
            RiftCol {
                id: mainCol
                span: 9       // 3/4 on widescreen (16:9)
                span43: 8     // 2/3 on 4:3
                span11: 12    // Full width on 1:1
                autoHeight: true
                debug: root.debugGrid

                Rectangle {
                    width: parent.width
                    height: contentColumn.height + 32
                    color: "#16213e"
                    radius: 8

                    Column {
                        id: contentColumn
                        width: parent.width - 32
                        x: 16
                        y: 16
                        spacing: 16

                        Text {
                            text: "Main Content Area"
                            color: "#e94560"
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Text {
                            text: "span: 9 | span43: 8 | span11: 12"
                            color: "#888"
                            font.pixelSize: 12
                        }

                        // Nested grid for game cards
                        RiftRow {
                            width: parent.width
                            gutter: 12
                            debug: root.debugGrid

                            Repeater {
                                model: 6
                                delegate: RiftCol {
                                    span: 4       // 3 per row on 16:9
                                    span43: 6     // 2 per row on 4:3
                                    span11: 6     // 2 per row on 1:1
                                    fixedHeight: 120
                                    autoHeight: false
                                    debug: root.debugGrid

                                    Rectangle {
                                        anchors.fill: parent
                                        color: "#0f3460"
                                        radius: 6

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 4

                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: "Game " + (index + 1)
                                                color: "#fff"
                                                font.pixelSize: 14
                                            }
                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: "4 / 43:6 / 11:6"
                                                color: "#666"
                                                font.pixelSize: 10
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

        // Spacer
        Item { width: 1; height: 24 }

        // Bottom row - Equal columns demo
        RiftRow {
            id: bottomRow
            width: parent.width
            gutter: 16
            debug: root.debugGrid

            Repeater {
                model: 4
                delegate: RiftCol {
                    span: 3       // 4 per row on 16:9
                    span43: 6     // 2 per row on 4:3
                    span11: 6     // 2 per row on 1:1
                    fixedHeight: 100
                    autoHeight: false
                    debug: root.debugGrid

                    Rectangle {
                        anchors.fill: parent
                        color: Qt.hsla(index * 0.25, 0.6, 0.4, 1)
                        radius: 8

                        Column {
                            anchors.centerIn: parent
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Box " + (index + 1)
                                color: "#fff"
                                font.pixelSize: 16
                                font.bold: true
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "3 / 43:6 / 11:6"
                                color: "#b3ffffff"
                                font.pixelSize: 10
                            }
                        }
                    }
                }
            }
        }
    }

}
