import QtQuick

import "../"

Item {
    id: root
    implicitWidth: triggerRow.implicitWidth
    implicitHeight: 32

    Row {
        id: triggerRow
        spacing: 10

        anchors.centerIn: parent

        SymbolicIcon {
            iconColor: Theme.palette.primary60
            name: "network-wireless-symbolic"

            anchors.verticalCenter: parent.verticalCenter
        }

        SymbolicIcon {
            iconColor: Theme.palette.primary60
            name: "bluetooth-active-symbolic"

            anchors.verticalCenter: parent.verticalCenter
        }

        Row {
            spacing: 4

            SymbolicIcon {
                iconColor: Theme.palette.primary60
                name: "battery-level-60-symbolic"

                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                color: Theme.palette.neutral80
                text: "85"

                anchors.verticalCenter: parent.verticalCenter

                font {
                    bold: true
                    family: Theme.fontFamily
                    pixelSize: Theme.fontSize
                }
            }
        }
    }

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent

        onClicked: {
            console.log("TODO: Drop the control center popup here");
        }
    }
}
