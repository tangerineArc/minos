import QtQuick
import Quickshell.Io
import Quickshell.Services.UPower

import "../"

Item {
    id: root

    signal clicked

    property var bat: UPower.displayDevice
    property bool isCharging: root.bat ? (root.bat.state === UPowerDeviceState.Charging || root.bat.state === UPowerDeviceState.FullyCharged) : false

    property string wifiStatus: "disabled"
    property int wifiSignal: 0
    property string btStatus: "disabled"

    function getBatteryIcon() {
        if (!bat)
            return "battery-missing-symbolic";

        const level = Math.floor(bat.percentage * 100);
        const limit = Math.floor(level / 10) * 10;

        if (root.isCharging) {
            return level >= 100 ? "battery-level-100-charged-symbolic" : `battery-level-${limit}-charging-symbolic`;
        }

        return `battery-level-${limit}-symbolic`;
    }

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

    function getBtIcon() {
        if (root.btStatus === "disabled")
            return "bluetooth-disabled-symbolic";
        if (root.btStatus === "disconnected")
            return "bluetooth-disconnected-symbolic";
        return "bluetooth-active-symbolic";
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
                    root.wifiSignal = state.signal || 0;
                } catch (e) {}
            }
        }
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
                } catch (e) {}
            }
        }
    }

    implicitHeight: trickWindow.height - 10
    implicitWidth: triggerRow.implicitWidth

    Row {
        id: triggerRow
        spacing: 10
        anchors.centerIn: parent

        SymbolicIcon {
            iconColor: Theme.palette.secondary80
            name: root.getWifiIcon()
            size: Theme.fontSize

            anchors.verticalCenter: parent.verticalCenter
        }

        SymbolicIcon {
            iconColor: Theme.palette.secondary80
            name: root.getBtIcon()
            size: Theme.fontSize

            anchors.verticalCenter: parent.verticalCenter
        }

        Row {
            spacing: 4

            SymbolicIcon {
                iconColor: root.isCharging ? Theme.palette.primary80 : Theme.palette.secondary80
                name: root.getBatteryIcon()
                size: Theme.fontSize

                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                color: Theme.palette.secondary80
                text: root.bat ? Math.round(root.bat.percentage * 100).toString() : "--"

                anchors.verticalCenter: parent.verticalCenter

                font {
                    bold: true
                    family: Theme.fontFamily
                    pixelSize: Theme.fontSize - 1
                }
            }
        }
    }

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent

        onClicked: {
            root.clicked();
        }
    }
}
