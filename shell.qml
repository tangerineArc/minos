import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {
    PanelWindow {
        implicitHeight: 40
        implicitWidth: 1000
        color: "transparent"
        exclusiveZone: height

        anchors.top: true
        WlrLayershell.namespace: "minos"

        margins {
            top: 4
            bottom: 0
            left: 10
            right: 10
        }

        Rectangle {
            color: Utils.withAlpha(Theme.palette.primary5, 0.84)
            radius: 20

            anchors.fill: parent

            Row {
                spacing: 8

                anchors {
                    left: parent.left
                    leftMargin: 16
                    verticalCenter: parent.verticalCenter
                }

                // Workspaces {}

                Text {
                    color: Theme.palette.primary80
                    text: "Minos"

                    font {
                        family: Theme.fontFamily
                        pixelSize: Theme.fontSize
                    }
                }
            }

            Row {
                spacing: 8
                anchors.centerIn: parent

                Text {
                    color: Theme.palette.neutral50
                    font: Theme.fontFamily
                    text: "#[ NixOS ]"
                }
            }

            Row {
                spacing: 8

                anchors {
                    right: parent.right
                    rightMargin: 16
                    verticalCenter: parent.verticalCenter
                }

                Text {
                    color: Theme.palette.neutral50
                    font: Theme.fontFamily
                    text: "gay"
                }
            }
        }
    }
}
