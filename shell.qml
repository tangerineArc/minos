import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Wayland

import "./components"

ShellRoot {
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
