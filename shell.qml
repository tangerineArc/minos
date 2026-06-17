import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import "./components"

ShellRoot {
    IpcHandler {
        target: "controlcenter"

        function toggle() {
            ccPopup.visible = !ccPopup.visible;
        }
    }

    // Space reserver
    PanelWindow {
        id: trickWindow
        color: "transparent"
        exclusiveZone: height
        implicitHeight: 42

        margins.top: 6
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "minos-space-reserver"

        anchors {
            left: true
            right: true
            top: true
        }
    }

    // Workspace switcher
    PanelWindow {
        color: "transparent"
        implicitHeight: trickWindow.height
        implicitWidth: leftContent.width + 10

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "minos-workspace-switcher"

        anchors {
            left: true
            top: true
        }
        margins {
            left: 8
            top: -trickWindow.height
        }

        // Background
        Rectangle {
            color: Utils.withAlpha(Theme.palette.primary5, 0.44)
            radius: 14

            anchors.fill: parent

            border {
                color: Utils.withAlpha(Theme.palette.primary60, 0.15)
                width: 1
            }
        }

        // Switcher
        Rectangle {
            color: "transparent"
            height: parent.height - 10
            width: leftContent.width + 10

            anchors.centerIn: parent

            Row {
                id: leftContent
                anchors.centerIn: parent

                Workspaces {}
            }
        }
    }

    // Focused window title
    PanelWindow {
        color: "transparent"
        implicitHeight: trickWindow.height
        implicitWidth: centerContent.width + 38

        anchors.top: true
        margins.top: -trickWindow.height
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "minos-focused-window-title"

        // Background
        Rectangle {
            color: Utils.withAlpha(Theme.palette.primary5, 0.44)
            radius: 14

            anchors.fill: parent

            border {
                color: Utils.withAlpha(Theme.palette.primary60, 0.15)
                width: 1
            }
        }

        // Title
        Rectangle {
            color: Utils.withAlpha(Theme.palette.primary15, 0.67)
            height: parent.height - 10
            radius: 10
            width: centerContent.width + 28

            anchors.centerIn: parent

            Row {
                id: centerContent
                anchors.centerIn: parent

                WindowTitle {}
            }
        }
    }

    // Controls Trigger
    PanelWindow {
        id: controlsWindow
        color: "transparent"
        implicitHeight: trickWindow.height
        implicitWidth: rightContent.width + 38

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "minos-controls-trigger"

        anchors {
            right: true
            top: true
        }
        margins {
            right: 8
            top: -trickWindow.height
        }

        // Background
        Rectangle {
            color: Utils.withAlpha(Theme.palette.primary5, 0.44)
            radius: 14

            anchors.fill: parent

            border {
                color: Utils.withAlpha(Theme.palette.primary60, 0.15)
                width: 1
            }
        }

        // Trigger
        Rectangle {
            color: Utils.withAlpha(Theme.palette.primary15, 0.67)
            height: parent.height - 10
            radius: 10
            width: rightContent.width + 28

            anchors.centerIn: parent

            Row {
                id: rightContent
                anchors.centerIn: parent

                ControlCenterTrigger {
                    onClicked: ccPopup.visible = !ccPopup.visible
                }
            }
        }
    }

    // Clock Window
    PanelWindow {
        id: clockWindow
        color: "transparent"
        implicitHeight: trickWindow.height
        implicitWidth: clockItem.width + 38

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "minos-clock"

        anchors {
            right: true
            top: true
        }
        margins {
            right: controlsWindow.width + 12
            top: -trickWindow.height
        }

        Rectangle {
            color: Utils.withAlpha(Theme.palette.primary5, 0.44)
            radius: 14

            anchors.fill: parent

            border {
                color: Utils.withAlpha(Theme.palette.primary60, 0.15)
                width: 1
            }
        }

        Rectangle {
            color: Utils.withAlpha(Theme.palette.primary15, 0.67)
            height: parent.height - 10
            radius: 10
            width: clockItem.width + 28

            anchors.centerIn: parent

            Clock {
                id: clockItem
                anchors.centerIn: parent
            }
        }
    }

    // Date tooltip popup
    PanelWindow {
        id: dateTooltip
        color: "transparent"
        implicitHeight: dateText.implicitHeight + 12
        implicitWidth: dateText.implicitWidth + 24
        visible: clockItem.isHovered

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "minos-date-tooltip"

        anchors {
            right: true
            top: true
        }
        margins {
            top: 4
            right: (controlsWindow.width + 12) + (clockWindow.width / 2) - (width / 2)
        }

        Rectangle {
            color: Theme.palette.neutral80
            radius: 8

            anchors.fill: parent

            Text {
                id: dateText
                color: Theme.palette.neutral10
                text: clockItem.dateText

                anchors.centerIn: parent

                font {
                    bold: true
                    family: Theme.fontFamily
                    pixelSize: 12
                }
            }
        }
    }

    // Media player window
    PanelWindow {
        id: mediaWindow
        color: "transparent"
        implicitHeight: trickWindow.height
        implicitWidth: mediaPlayerItem.width + 38

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "minos-media-player"

        anchors {
            right: true
            top: true
        }
        margins {
            right: controlsWindow.width + clockWindow.width + 16
            top: -trickWindow.height
        }

        // Background
        Rectangle {
            color: Utils.withAlpha(Theme.palette.primary5, 0.44)
            radius: 14

            anchors.fill: parent

            border {
                color: Utils.withAlpha(Theme.palette.primary60, 0.15)
                width: 1
            }
        }

        Rectangle {
            color: Utils.withAlpha(Theme.palette.primary15, 0.67)
            height: parent.height - 10
            radius: 10
            width: mediaPlayerItem.width + 28

            anchors.centerIn: parent

            MediaPlayer {
                id: mediaPlayerItem
                anchors.centerIn: parent
            }
        }
    }

    // Control center popup
    PanelWindow {
        id: ccPopup
        color: "transparent"
        implicitWidth: 320
        implicitHeight: ccColumn.implicitHeight + 29
        visible: false

        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "minos-control-center"

        anchors {
            right: true
            top: true
        }
        margins {
            top: 4
            right: 6
        }

        Connections {
            target: Qt.application

            function onStateChanged() {
                if (Qt.application.state !== Qt.ApplicationActive && ccPopup.visible) {
                    ccPopup.visible = false;
                }
            }
        }

        Shortcut {
            sequence: "Esc"
            onActivated: ccPopup.visible = false
        }

        Rectangle {
            color: Utils.withAlpha(Theme.palette.primary5, 0.44)
            radius: 14

            anchors.fill: parent

            border {
                color: Utils.withAlpha(Theme.palette.primary60, 0.15)
                width: 1
            }
        }

        Column {
            id: ccColumn
            spacing: 12

            anchors {
                left: parent.left
                margins: 14
                right: parent.right
                top: parent.top
                topMargin: 15
            }

            NetworkControls {}
            VolumeControl {}
            BrightnessControl {}
            PowerProfileControl {}
        }
    }
}
