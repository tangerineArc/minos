import QtQuick
import Quickshell.Io

import "../"

Item {
    id: root

    property string currentProfile: "balanced"
    readonly property var profiles: ["power-saver", "balanced", "performance"]
    readonly property var icons: ["power-profile-power-saver-symbolic", "power-profile-balanced-symbolic", "power-profile-performance-symbolic"]

    implicitHeight: 48
    implicitWidth: parent.width

    Process {
        id: profileGet
        command: ["powerprofilesctl", "get"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                let p = data.trim();
                if (root.profiles.includes(p)) {
                    root.currentProfile = p;
                }
            }
        }
    }

    Process {
        id: profileSet
    }

    // Background
    Rectangle {
        id: containerBg
        color: Utils.withAlpha(Theme.palette.primary20, 0.67)
        radius: 10

        anchors.fill: parent

        // Sliding highlight indicator
        Rectangle {
            id: indicator
            color: Utils.withAlpha(Theme.palette.primary60, 0.67)
            height: parent.height - 8
            radius: 8
            width: (parent.width - 8) / 3
            x: 4 + (Math.max(0, root.profiles.indexOf(root.currentProfile)) * width)
            y: 4

            Behavior on x {
                NumberAnimation {
                    easing.type: Easing.OutQuint
                    duration: 150
                }
            }
        }

        Row {
            anchors {
                fill: parent
                margins: 4
            }

            Repeater {
                model: 3

                Item {
                    width: (parent.width) / 3
                    height: parent.height

                    SymbolicIcon {
                        name: root.icons[index]
                        iconColor: root.currentProfile === root.profiles[index] ? Theme.palette.primary10 : Theme.palette.primary70
                        size: Theme.fontSize + 2

                        anchors.centerIn: parent
                    }

                    MouseArea {
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent

                        onClicked: {
                            let p = root.profiles[index];
                            root.currentProfile = p;
                            profileSet.command = ["powerprofilesctl", "set", p];
                            profileSet.running = true;
                        }
                    }
                }
            }
        }
    }
}
