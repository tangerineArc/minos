import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

Row {
    id: root
    property int itemCount: trayRepeater.count

    spacing: 4

    Repeater {
        id: trayRepeater
        model: SystemTray.items

        Rectangle {
            id: trayItemWrapper
            color: "transparent"
            height: 32
            width: 32

            // Anchor for displaying the context menu
            QsMenuAnchor {
                id: menuAnchor
                menu: modelData.menu

                anchor {
                    window: trayWindow

                    rect {
                        height: trayItemWrapper.height
                        width: trayItemWrapper.width
                        x: trayItemWrapper.mapToItem(null, 0, 0).x
                        y: trayItemWrapper.mapToItem(null, 0, 0).y
                    }
                }
            }

            Image {
                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
                source: modelData.icon

                sourceSize {
                    width: 20
                    height: 20
                }
            }

            MouseArea {
                id: trayMouse
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                anchors.fill: parent

                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        if (modelData.hasMenu) {
                            menuAnchor.open();
                        }
                    } else if (mouse.button === Qt.LeftButton) {
                        modelData.activate();
                    } else if (mouse.button === Qt.MiddleButton) {
                        modelData.secondaryActivate();
                    }
                }
            }
        }
    }
}
