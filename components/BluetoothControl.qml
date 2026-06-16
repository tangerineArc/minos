import QtQuick
import Quickshell.Io

import "../"

Item {
    id: root

    property string btStatus: "disabled"
    property string btDevice: "off"
    property bool btIsOn: root.btStatus !== "disabled"

    function getBtIcon() {
        if (root.btStatus === "disabled")
            return "bluetooth-disabled-symbolic";
        if (root.btStatus === "disconnected")
            return "bluetooth-disconnected-symbolic";
        return "bluetooth-active-symbolic";
    }

    Process {
        id: btWatcher
        command: ["bash", "-c", "scripts/bluetooth-stream.sh"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                try {
                    let state = JSON.parse(data);
                    root.btStatus = state.status || "disabled";
                    root.btDevice = state.device || "off";
                } catch (e) {
                    console.log("[BluetoothControl] Parse error:", e);
                }
            }
        }
    }

    Process {
        id: btTuiProc
    }
    Process {
        id: btToggleProc
    }

    // Background
    Rectangle {
        color: Utils.withAlpha(Theme.palette.primary20, 0.67)
        radius: 10

        anchors.fill: parent
    }

    // Toggle button
    Rectangle {
        id: btToggleBtn
        color: Utils.withAlpha(root.btIsOn ? Theme.palette.primary60 : Theme.palette.primary10, 0.67)
        height: parent.height - 12
        radius: 8
        width: height

        anchors {
            left: parent.left
            leftMargin: 6
            verticalCenter: parent.verticalCenter
        }

        SymbolicIcon {
            iconColor: root.btIsOn ? Theme.palette.primary10 : Theme.palette.primary70
            name: root.getBtIcon()
            size: Theme.fontSize + 4

            anchors.centerIn: parent
        }

        MouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent

            onClicked: {
                let action = root.btIsOn ? "off" : "on";
                btToggleProc.command = ["bluetoothctl", "power", action];
                btToggleProc.running = true;
                root.btStatus = root.btIsOn ? "disabled" : "disconnected";
            }
        }
    }

    // Application trigger
    Item {
        height: parent.height

        anchors {
            left: btToggleBtn.right
            leftMargin: 10
            right: parent.right
            rightMargin: 10
        }

        Text {
            color: Theme.palette.secondary70
            elide: Text.ElideRight
            maximumLineCount: 1
            text: root.btIsOn ? root.btDevice : "bluetooth"

            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }

            font {
                bold: true
                family: Theme.fontFamily
                pixelSize: Theme.fontSize
            }
        }

        MouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent

            onClicked: {
                btTuiProc.command = ["ghostty", "-e", "bluetui"];
                btTuiProc.running = true;
            }
        }
    }
}
