import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Wayland

import "./components"

ShellRoot {
    // Main shell bar
    PanelWindow {
        color: "transparent"
        exclusiveZone: height
        implicitHeight: 40
        implicitWidth: 1200

        anchors.top: true
        margins.top: 4
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "minos"

        // Background
        Rectangle {
            color: Utils.withAlpha(Theme.palette.primary5, 0.54)
            radius: height / 2

            anchors.fill: parent
        }

        // Workspace switcher
        Rectangle {
            color: "transparent"
            height: parent.height - 8
            radius: height / 2
            width: leftContent.width

            anchors {
                left: parent.left
                margins: 4
                verticalCenter: parent.verticalCenter
            }

            Row {
                id: leftContent
                anchors.centerIn: parent

                Workspaces {}
            }
        }

        // Focused window title
        Rectangle {
            color: Utils.withAlpha(Theme.palette.primary15, 0.67)
            height: parent.height - 8
            radius: height / 2
            width: centerContent.width + 32

            anchors.centerIn: parent

            border {
                color: Utils.withAlpha(Theme.palette.primary40, 0.33)
                width: 1
            }

            Row {
                id: centerContent
                anchors.centerIn: parent

                WindowTitle {}
            }
        }

        // Control center trigger
        Rectangle {
            color: Utils.withAlpha(Theme.palette.primary15, 0.67)
            height: parent.height - 8
            radius: height / 2
            width: rightContent.width + 32

            anchors {
                right: parent.right
                margins: 4
                verticalCenter: parent.verticalCenter
            }
            border {
                color: Utils.withAlpha(Theme.palette.primary40, 0.33)
                width: 1
            }

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
        exclusiveZone: 0
        implicitWidth: 320
        implicitHeight: 320
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
            right: ((Screen.width - 1200) / 2) + 4
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
            color: Utils.withAlpha(Theme.palette.primary5, 0.54)
            radius: 20

            anchors.fill: parent

            Text {
                color: Theme.palette.neutral80
                text: "Fluid as hell."
                anchors.centerIn: parent

                font {
                    family: Theme.fontFamily
                    pixelSize: Theme.fontSize
                }
            }
        }
    }
}
