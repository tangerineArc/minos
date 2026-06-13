import QtQuick
import Quickshell
import Quickshell.Wayland

import "./components"

ShellRoot {
    PanelWindow {
        implicitHeight: 40
        implicitWidth: 1200
        color: "transparent"
        exclusiveZone: height

        anchors.top: true
        WlrLayershell.namespace: "minos"

        margins {
            bottom: 0
            top: 4
        }

        Rectangle {
            color: Utils.withAlpha(Theme.palette.primary5, 0.44)
            radius: height / 2

            anchors.fill: parent
        }

        Rectangle {
            color: "transparent"
            height: parent.height - 8
            radius: height / 2
            width: leftContent.width

            anchors {
                left: parent.left
                margins: 4
                verticalCenter: parent.verticalCenter
            }

            Row {
                id: leftContent
                anchors.centerIn: parent

                Workspaces {}
            }
        }

        Rectangle {
            color: Utils.withAlpha(Theme.palette.primary15, 0.67)
            height: parent.height - 8
            radius: height / 2
            width: centerContent.width + 32

            anchors.centerIn: parent

            border {
                color: Utils.withAlpha(Theme.palette.primary40, 0.33)
                width: 1
            }

            Row {
                id: centerContent
                anchors.centerIn: parent

                WindowTitle {}
            }
        }

        Rectangle {
            color: Utils.withAlpha(Theme.palette.primary5, 0.84)
            height: 40
            radius: height / 2
            width: rightContent.width + 24

            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }

            Row {
                id: rightContent
                anchors.centerIn: parent

                Text {
                    color: Theme.palette.neutral50
                    text: "gay"

                    font {
                        family: Theme.fontFamily
                        pixelSize: Theme.fontSize
                    }
                }
            }
        }
    }
}
