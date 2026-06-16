import QtQuick
import Quickshell.Services.UPower

import "../"

Item {
    id: root

    signal clicked

    property var bat: UPower.displayDevice
    property bool isCharging: root.bat ? (root.bat.state === UPowerDeviceState.Charging || root.bat.state === UPowerDeviceState.FullyCharged) : false

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

    implicitHeight: trickWindow.height - 10
    implicitWidth: triggerRow.implicitWidth

    Row {
        id: triggerRow
        spacing: 10

        anchors.centerIn: parent

        SymbolicIcon {
            iconColor: Theme.palette.secondary70
            name: "network-wireless-symbolic"
            size: Theme.fontSize

            anchors.verticalCenter: parent.verticalCenter
        }

        SymbolicIcon {
            iconColor: Theme.palette.secondary70
            name: "bluetooth-active-symbolic"
            size: Theme.fontSize

            anchors.verticalCenter: parent.verticalCenter
        }

        Row {
            spacing: 4

            SymbolicIcon {
                iconColor: root.isCharging ? Theme.palette.primary80 : Theme.palette.secondary70
                name: root.getBatteryIcon()
                size: Theme.fontSize

                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                color: Theme.palette.secondary70
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
