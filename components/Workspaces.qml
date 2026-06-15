import QtQuick
import Quickshell.Io

import "../"

Item {
    id: root
    implicitWidth: mainRow.implicitWidth
    implicitHeight: mainRow.implicitHeight

    property var workspaceData: []

    Process {
        id: niriCommander
    }

    Process {
        id: niriWatcher
        command: ["bash", "-c", "scripts/niri-workspaces.sh"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                // console.log("[Niri-IPC] Raw state:", data);
                try {
                    root.workspaceData = JSON.parse(data);
                } catch (e) {
                    console.log("[Niri-IPC] Failed to parse JSON:", e);
                }
            }
        }
    }

    Row {
        id: mainRow
        spacing: 3

        Repeater {
            id: workspaceRepeater
            model: root.workspaceData

            Rectangle {
                id: workspacePill
                property bool isActive: modelData.active

                color: Utils.withAlpha(isActive ? Theme.palette.primary15 : Theme.palette.primary10, 0.67)
                height: trickWindow.height - 10
                radius: 10
                width: iconRow.width + 24

                Row {
                    id: iconRow
                    spacing: 12

                    anchors.centerIn: parent

                    Text {
                        color: workspacePill.isActive ? Theme.palette.primary60 : Theme.palette.neutral70
                        opacity: workspacePill.isActive ? 1.0 : 0.7
                        text: ""
                        visible: modelData.apps.length === 0

                        font {
                            bold: true
                            family: "JetBrainsMono Nerd Font"
                            pixelSize: 12
                        }

                        MouseArea {
                            cursorShape: Qt.PointingHandCursor
                            anchors.fill: parent

                            onClicked: {
                                niriCommander.command = ["niri", "msg", "action", "focus-workspace", modelData.id.toString()];
                                niriCommander.running = true;
                            }
                        }
                    }

                    Repeater {
                        model: modelData.apps

                        Text {
                            color: modelData.isFocused ? Theme.palette.primary70 : Theme.palette.neutral70
                            opacity: modelData.isFocused ? 1.0 : 0.7
                            text: Utils.getIcon(modelData.appId, modelData.title)

                            font {
                                bold: true
                                family: "JetBrainsMono Nerd Font"
                                pixelSize: 14
                            }

                            MouseArea {
                                cursorShape: Qt.PointingHandCursor
                                anchors.fill: parent

                                onClicked: {
                                    niriCommander.command = ["niri", "msg", "action", "focus-window", "--id", modelData.winId.toString()];
                                    niriCommander.running = true;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
