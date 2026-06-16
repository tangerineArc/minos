import QtQuick

import "../"

Item {
    id: root

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: Utils.withAlpha(Theme.palette.primary20, 0.67)
    }

    Rectangle {
        id: btToggleBtn
        width: height
        height: parent.height - 12
        radius: 8
        color: Utils.withAlpha(Theme.palette.primary10, 0.67)

        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: 6
        }

        SymbolicIcon {
            name: "bluetooth-active-symbolic"
            iconColor: Theme.palette.primary70
            size: Theme.fontSize + 4
            anchors.centerIn: parent
        }
    }

    Item {
        height: parent.height
        anchors {
            left: btToggleBtn.right
            right: parent.right
            leftMargin: 10
            rightMargin: 6
        }

        Text {
            text: "Bluetooth"
            color: Theme.palette.neutral10
            elide: Text.ElideRight
            maximumLineCount: 1

            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }

            font {
                bold: true
                family: Theme.fontFamily
                pixelSize: Theme.fontSize - 1
            }
        }
    }
}
