import QtQuick
import Quickshell.Io

import "../"

Item {
    id: root

    property string wifiStatus: "disabled"
    property string wifiSsid: "off"
    property int wifiSignal: 0
    property bool wifiIsOn: root.wifiStatus !== "disabled"

    function getWifiIcon() {
        if (root.wifiStatus === "disabled" || root.wifiStatus === "disconnected")
            return "network-wireless-offline-symbolic";
        if (root.wifiSignal < 25)
            return "network-wireless-signal-none-symbolic";
        if (root.wifiSignal < 50)
            return "network-wireless-signal-weak-symbolic";
        if (root.wifiSignal < 75)
            return "network-wireless-signal-ok-symbolic";
        return "network-wireless-signal-good-symbolic";
    }

    Process {
        id: wifiWatcher
        command: ["bash", "-c", "scripts/wifi-stream.sh"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                try {
                    let state = JSON.parse(data);
                    root.wifiStatus = state.status || "disabled";
                    root.wifiSsid = state.ssid || "off";
                    root.wifiSignal = state.signal || 0;
                } catch (e) {
                    console.log("[WifiControl] Parse error:", e);
                }
            }
        }
    }
    Process {
        id: nmtuiProc
    }
    Process {
        id: wifiToggleProc
    }

    // Background
    Rectangle {
        color: Utils.withAlpha(Theme.palette.primary20, 0.67)
        radius: 10

        anchors.fill: parent
    }

    // Toggle button
    Rectangle {
        id: wifiToggleBtn
        color: Utils.withAlpha(root.wifiIsOn ? Theme.palette.primary60 : Theme.palette.primary10, 0.67)
        height: parent.height - 12
        radius: 8
        width: height

        anchors {
            left: parent.left
            leftMargin: 6
            verticalCenter: parent.verticalCenter
        }

        SymbolicIcon {
            iconColor: root.wifiIsOn ? Theme.palette.primary10 : Theme.palette.primary70
            name: root.getWifiIcon()
            size: Theme.fontSize + 4

            anchors.centerIn: parent
        }

        MouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent

            onClicked: {
                let action = root.wifiIsOn ? "off" : "on";
                wifiToggleProc.command = ["nmcli", "radio", "wifi", action];
                wifiToggleProc.running = true;
                root.wifiStatus = root.wifiIsOn ? "disabled" : "disconnected";
            }
        }
    }

    // Application trigger
    Item {
        height: parent.height

        anchors {
            left: wifiToggleBtn.right
            leftMargin: 10
            right: parent.right
            rightMargin: 10
        }

        Text {
            color: Theme.palette.secondary70
            elide: Text.ElideRight
            maximumLineCount: 1
            text: root.wifiIsOn ? root.wifiSsid : "wi-fi"

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
                nmtuiProc.command = ["ghostty", "-e", "nmtui"];
                nmtuiProc.running = true;
            }
        }
    }
}
