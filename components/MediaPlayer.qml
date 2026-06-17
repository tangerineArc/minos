import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

import "../"

Row {
    id: root
    property var player: (function () {
            let players = Mpris.players.values;
            let validFallback = null;

            for (let i = 0; i < players.length; i++) {
                let p = players[i];
                let title = p.metadata ? (p.metadata["xesam:title"] || "") : "";

                if (title === "")
                    continue;

                if (p.playbackState === MprisPlaybackState.Playing) {
                    return p;
                }

                if (!validFallback) {
                    validFallback = p;
                }
            }
            return validFallback;
        })()

    property bool isPlaying: player ? player.playbackState === MprisPlaybackState.Playing : false
    property bool hasMedia: player !== null && player !== undefined

    RowLayout {
        spacing: 12
        visible: root.hasMedia

        // Controls
        Row {
            spacing: 8
            Layout.alignment: Qt.AlignVCenter

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                height: backIcon.height
                onClicked: if (root.player)
                    root.player.previous()
                width: backIcon.width

                anchors.verticalCenter: parent.verticalCenter

                SymbolicIcon {
                    id: backIcon
                    name: "media-skip-backward-symbolic"
                    iconColor: Theme.palette.secondary70
                }
            }

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                height: playIcon.height
                onClicked: if (root.player)
                    root.player.togglePlaying()
                width: playIcon.width

                anchors.verticalCenter: parent.verticalCenter

                SymbolicIcon {
                    id: playIcon
                    iconColor: Theme.palette.secondary80
                    name: isPlaying ? "media-playback-pause-symbolic" : "media-playback-start-symbolic"
                    size: Theme.fontSize
                }
            }

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                height: nextIcon.height
                onClicked: if (root.player)
                    root.player.next()
                width: nextIcon.width

                anchors.verticalCenter: parent.verticalCenter

                SymbolicIcon {
                    id: nextIcon
                    iconColor: Theme.palette.secondary70
                    name: "media-skip-forward-symbolic"
                }
            }
        }

        // Dynamic progress
        Item {
            implicitWidth: progressBar.width
            implicitHeight: progressBar.height

            Rectangle {
                id: progressBar
                color: Utils.withAlpha(Theme.palette.primary60, 0.3)
                height: 4
                radius: 4
                width: 180

                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    // property real trackLengthSec: (player.metadata && player.metadata["mpris:length"]) ? (player.metadata["mpris:length"] / 1000000) : 0

                    color: Theme.palette.primary60
                    height: parent.height
                    radius: parent.radius
                    width: (root.player && root.player.length > 0) ? Math.min(parent.width, parent.width * (root.player.position / root.player.length)) : 0

                    Behavior on width {
                        NumberAnimation {
                            duration: 100
                        }
                    }
                }
            }
        }

        // Thumbnail
        Rectangle {
            color: Utils.withAlpha(Theme.palette.primary20, 0.5)

            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height

            Image {
                id: art
                source: root.player ? (root.player.trackArtUrl || "") : ""
                fillMode: Image.PreserveAspectCrop
                visible: source.toString() !== ""

                anchors.fill: parent
            }

            SymbolicIcon {
                iconColor: Theme.palette.primary60
                name: "audio-x-generic-symbolic"
                size: Theme.fontSize
                visible: !art.visible

                anchors.centerIn: parent
            }
        }
    }

    RowLayout {
        width: 240
        visible: !root.hasMedia
        spacing: 12

        Text {
            Layout.fillWidth: true
            color: Theme.palette.secondary70
            text: "no media playing"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            font {
                family: Theme.fontFamily
                pixelSize: Theme.fontSize
                bold: true
            }
        }

        SymbolicIcon {
            iconColor: Theme.palette.primary70
            name: "audio-x-generic-symbolic"
            size: Theme.fontSize + 1
        }
    }
}
