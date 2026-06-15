import QtQuick
import QtQuick.Controls
import Quickshell.Services.Pipewire

import "../"

Item {
    id: root
    property PwNode sink: Pipewire.defaultAudioSink
    property real currentVolume: root.sink ? root.sink.audio.volume : 0

    function getDeviceIcon() {
        if (!root.sink)
            return "󰚌";

        let name = (root.sink.name || "").toLowerCase();
        let desc = (root.sink.description || "").toLowerCase();

        if (name.includes("bluez") || desc.includes("bluetooth"))
            return "󰝚";
        if (name.includes("alsa") || name.includes("pci"))
            return "";
        return "󰗅";
    }

    function getVolumeIconName() {
        if (!root.sink || root.currentVolume === 0 || root.sink.audio.muted)
            return "audio-volume-muted-symbolic";
        if (root.currentVolume < 0.33)
            return "audio-volume-low-symbolic";
        if (root.currentVolume < 0.67)
            return "audio-volume-medium-symbolic";
        return "audio-volume-high-symbolic";
    }

    implicitHeight: 44
    implicitWidth: parent.width

    PwObjectTracker {
        objects: [root.sink]
    }

    // Background
    Rectangle {
        id: volumePillBg
        color: Utils.withAlpha(Theme.palette.primary20, 0.67)
        radius: 10

        anchors.fill: parent
    }

    // Track
    Rectangle {
        color: "transparent"
        height: volumePillBg.height - 14
        radius: 6
        width: volumePillBg.width - 14

        anchors.centerIn: parent

        Rectangle {
            color: Utils.withAlpha(Theme.palette.primary60, 0.67)
            height: parent.height
            radius: parent.radius
            width: root.currentVolume * parent.width - 8

            // Separator
            Rectangle {
                color: Utils.withAlpha(Theme.palette.primary60, 0.67)
                height: parent.height - 2
                radius: 6
                width: 4

                anchors {
                    right: parent.right
                    rightMargin: -8
                    verticalCenter: parent.verticalCenter
                }
            }
        }

        // Device icon
        Text {
            color: root.currentVolume > 0.1 ? Theme.palette.primary10 : Theme.palette.primary70
            text: root.getDeviceIcon()

            anchors {
                left: parent.left
                leftMargin: 8
                verticalCenter: parent.verticalCenter
            }

            font {
                bold: true
                family: Theme.fontFamily
                pixelSize: Theme.fontSize + 2
            }
        }

        // Volume icon
        SymbolicIcon {
            iconColor: root.currentVolume > 0.99 ? Theme.palette.primary10 : Theme.palette.primary70
            name: root.getVolumeIconName()
            size: Theme.fontSize + 2

            anchors {
                right: parent.right
                rightMargin: 12
                verticalCenter: parent.verticalCenter
            }
        }
    }

    MouseArea {
        id: volMouse

        function updateVol(mouse) {
            if (!root.sink)
                return;
            let percent = mouse.x / root.width;
            root.sink.audio.volume = Math.max(0.0, Math.min(1.0, percent));
        }

        cursorShape: Qt.PointingHandCursor
        onPressed: mouse => updateVol(mouse)
        preventStealing: true

        anchors.fill: parent

        onPositionChanged: mouse => {
            if (pressed)
                updateVol(mouse);
        }

        // Volume Tooltip
        ToolTip {
            visible: volMouse.pressed
            x: Math.max(0, Math.min(parent.width - width, (root.currentVolume * parent.width) - (width / 2)))
            y: -9
            width: 40
            height: 20

            background: Rectangle {
                color: Theme.palette.neutral80
                radius: 8
            }

            contentItem: Text {
                color: Theme.palette.neutral10
                text: Math.round(root.currentVolume * 100)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                font {
                    bold: true
                    family: Theme.fontFamily
                    pixelSize: 12
                }
            }
        }
    }
}
