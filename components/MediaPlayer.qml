import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
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
                width: backIcon.width

                anchors.verticalCenter: parent.verticalCenter

                onClicked: if (root.player)
                    root.player.previous()

                SymbolicIcon {
                    id: backIcon
                    iconColor: Theme.palette.secondary70
                    name: "media-skip-backward-symbolic"
                }
            }

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                height: playIcon.height
                width: playIcon.width

                anchors.verticalCenter: parent.verticalCenter

                onClicked: if (root.player)
                    root.player.togglePlaying()

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
                width: nextIcon.width

                anchors.verticalCenter: parent.verticalCenter

                onClicked: if (root.player)
                    root.player.next()

                SymbolicIcon {
                    id: nextIcon
                    iconColor: Theme.palette.secondary70
                    name: "media-skip-forward-symbolic"
                }
            }
        }

        // Dynamic progress
        Item {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: 180
            implicitHeight: 24

            property real currentProgress: (root.player && root.player.length > 0) ? (root.player.position / root.player.length) : 0
            property real phase: 0

            onCurrentProgressChanged: {
                waveCanvas.requestPaint();
            }

            Timer {
                interval: 32 // ~30 FPS
                repeat: true
                running: root.isPlaying

                onTriggered: {
                    parent.phase -= 0.15; // Speed of the wave scrolling left
                    waveCanvas.requestPaint();
                }
            }

            Canvas {
                id: waveCanvas
                antialiasing: true

                anchors.fill: parent

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);

                    var centerY = height / 2;
                    var headX = Math.max(0, Math.min(width, width * parent.currentProgress));

                    var amplitude = 5; // How tall the wave is
                    var frequency = 0.18; // How tight the squiggles are

                    ctx.lineWidth = 4;
                    ctx.lineCap = "round";
                    ctx.lineJoin = "round";

                    // Draw inactive straight track (right side)
                    ctx.beginPath();
                    ctx.moveTo(headX, centerY);
                    ctx.lineTo(width, centerY);
                    ctx.strokeStyle = Utils.withAlpha(Theme.palette.primary60, 0.3);
                    ctx.stroke();

                    // Draw active wavy track (left side)
                    ctx.beginPath();
                    ctx.moveTo(0, centerY);

                    for (var x = 0; x <= headX; x += 2) {
                        var dampLeft = Math.min(1.0, x / 10.0);
                        var dampRight = x > headX - 15 ? Math.max(0, (headX - x) / 15.0) : 1.0;
                        var damp = Math.min(dampLeft, dampRight);

                        var y = centerY + Math.sin(x * frequency + parent.phase) * amplitude * damp;
                        ctx.lineTo(x, y);
                    }
                    ctx.strokeStyle = Theme.palette.primary60;
                    ctx.stroke();
                }
            }
        }

        // Thumbnail
        Rectangle {
            color: Utils.withAlpha(Theme.palette.primary20, 0.5)
            radius: 6

            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.height

            Image {
                id: art
                fillMode: Image.PreserveAspectCrop
                source: root.player ? (root.player.trackArtUrl || "") : ""
                visible: source.toString() !== ""

                anchors.fill: parent

                layer {
                    enabled: true

                    effect: OpacityMask {
                        maskSource: Rectangle {
                            height: art.height
                            radius: 6
                            width: art.width
                        }
                    }
                }
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
