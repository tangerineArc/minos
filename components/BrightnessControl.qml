import QtQuick
import QtQuick.Controls
import Quickshell.Io

import "../"

Item {
    id: root
    implicitHeight: 84
    implicitWidth: parent.width

    property real currentBrightness: 0.5
    property real currentTemp: 6500
    property bool isNightlight: currentTemp < 6500

    Timer {
        id: brightThrottle
        property real targetVal: -1

        interval: 32 // ~30 fps

        onTriggered: {
            if (targetVal >= 0) {
                brightSet.command = ["brightnessctl", "s", Math.round(targetVal * 100) + "%", "-q"];
                brightSet.running = true;
                targetVal = -1;
            }
        }
    }

    Timer {
        id: tempThrottle
        property int targetVal: -1

        interval: 32

        onTriggered: {
            if (targetVal >= 0) {
                tempSet.command = ["bash", "-c", "echo " + targetVal + " > ~/.cache/qs_color_temp && busctl --user set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q " + targetVal];
                tempSet.running = true;
                targetVal = -1;
            }
        }
    }

    Process {
        id: brightGet
        command: ["bash", "-c", "scripts/brightness-stream.sh"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                let val = parseInt(data);
                if (!isNaN(val) && brightMouse && !brightMouse.pressed)
                    root.currentBrightness = val / 100.0;
            }
        }
    }

    Process {
        id: brightSet
    }

    Process {
        id: tempGet
        command: ["bash", "-c", "f=\"$HOME/.cache/qs_color_temp\"; if [ -f \"$f\" ]; then v=$(cat \"$f\"); busctl --user set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q \"$v\" 2>/dev/null; else v=6500; fi; echo \"$v\";"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                let val = parseInt(data);
                if (!isNaN(val) && tempMouse && !tempMouse.pressed)
                    root.currentTemp = val;
            }
        }
    }

    Process {
        id: tempSet
    }

    // Background
    Rectangle {
        id: containerBg
        color: Utils.withAlpha(Theme.palette.primary20, 0.67)
        radius: 10

        anchors.fill: parent
    }

    Row {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        // Nightlight toggle
        Rectangle {
            id: nightlightToggle
            width: height
            height: parent.height
            radius: 8

            color: root.isNightlight ? Utils.withAlpha(Theme.palette.primary60, 0.67) : Utils.withAlpha(Theme.palette.primary10, 0.67)

            SymbolicIcon {
                name: "night-light-symbolic"
                iconColor: root.isNightlight ? Theme.palette.primary10 : Theme.palette.primary70
                size: Theme.fontSize + 6
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    let targetTemp = root.isNightlight ? 6500 : 4000;
                    root.currentTemp = targetTemp;
                    tempSet.command = ["bash", "-c", "echo " + targetTemp + " > ~/.cache/qs_color_temp && busctl --user set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q " + targetTemp];
                    tempSet.running = true;
                }
            }
        }

        // Sliders column
        Column {
            height: parent.height
            spacing: 8
            width: parent.width - nightlightToggle.width - 8

            // Screen brightness slider
            Item {
                width: parent.width
                height: (parent.height - 8) / 2

                Rectangle {
                    color: "transparent"
                    anchors.fill: parent
                    radius: 6

                    // Filled track
                    Rectangle {
                        color: Utils.withAlpha(Theme.palette.primary60, 0.67)
                        height: parent.height
                        radius: parent.radius
                        width: Math.max(0, root.currentBrightness * parent.width - 8)

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

                    SymbolicIcon {
                        iconColor: root.currentBrightness > 0.2 ? Theme.palette.primary10 : Theme.palette.primary70
                        name: "display-brightness-symbolic"
                        size: Theme.fontSize + 2

                        anchors {
                            left: parent.left
                            leftMargin: 10
                            verticalCenter: parent.verticalCenter
                        }
                    }
                }

                MouseArea {
                    id: brightMouse

                    function updateBrightness(mouse) {
                        let percent = Math.max(0.0, Math.min(1.0, mouse.x / width));
                        root.currentBrightness = percent;
                        brightThrottle.targetVal = percent;

                        if (!brightThrottle.running)
                            brightThrottle.start();
                    }

                    cursorShape: Qt.PointingHandCursor
                    onPressed: mouse => updateBrightness(mouse)
                    preventStealing: true

                    anchors.fill: parent

                    onPositionChanged: mouse => {
                        if (pressed)
                            updateBrightness(mouse);
                    }

                    // Brightness toolTip
                    ToolTip {
                        height: 20
                        width: 40
                        visible: brightMouse.pressed
                        x: Math.max(0, Math.min(parent.width - width, (root.currentBrightness * parent.width) - (width / 2)))
                        y: -22

                        background: Rectangle {
                            color: Theme.palette.neutral80
                            radius: 8
                        }

                        contentItem: Text {
                            color: Theme.palette.neutral10
                            horizontalAlignment: Text.AlignHCenter
                            text: Math.round(root.currentBrightness * 100)
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

            // Temperature Slider
            Item {
                height: (parent.height - 8) / 2
                opacity: root.isNightlight ? 1.0 : 0.4
                width: parent.width

                Rectangle {
                    color: "transparent"
                    radius: 6

                    anchors.fill: parent

                    // Filled Track
                    Rectangle {
                        color: Utils.withAlpha(Theme.palette.primary60, 0.67)
                        height: parent.height
                        radius: parent.radius
                        width: Math.max(0, ((root.currentTemp - 2000) / 4500) * parent.width - 8)

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

                    SymbolicIcon {
                        iconColor: (root.isNightlight && root.currentTemp > 2880) ? Theme.palette.primary10 : Theme.palette.primary70
                        name: "weather-clear-night-symbolic"
                        size: Theme.fontSize + 2

                        anchors {
                            left: parent.left
                            leftMargin: 10
                            verticalCenter: parent.verticalCenter
                        }
                    }
                }

                MouseArea {
                    id: tempMouse

                    function updateTemp(mouse) {
                        let percent = Math.max(0.0, Math.min(1.0, mouse.x / width));
                        let rawTemp = 2000 + (percent * 4500);
                        let targetTemp = Math.round(rawTemp / 10) * 10;
                        root.currentTemp = targetTemp;
                        tempThrottle.targetVal = targetTemp;

                        if (!tempThrottle.running)
                            tempThrottle.start();
                    }

                    cursorShape: Qt.PointingHandCursor
                    enabled: root.isNightlight
                    onPressed: mouse => updateTemp(mouse)
                    preventStealing: true

                    anchors.fill: parent

                    onPositionChanged: mouse => {
                        if (pressed)
                            updateTemp(mouse);
                    }

                    // Temperature toolTip
                    ToolTip {
                        height: 20
                        width: 48
                        visible: tempMouse.pressed
                        x: Math.max(0, Math.min(parent.width - width, (((root.currentTemp - 2000) / 4500) * parent.width) - (width / 2)))
                        y: -22

                        background: Rectangle {
                            color: Theme.palette.neutral80
                            radius: 8
                        }

                        contentItem: Text {
                            color: Theme.palette.neutral10
                            horizontalAlignment: Text.AlignHCenter
                            text: Math.round(root.currentTemp) + "K"
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
        }
    }
}
