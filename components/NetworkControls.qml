import QtQuick

Item {
    id: root
    implicitHeight: 56
    implicitWidth: parent.width

    Row {
        spacing: 6
        anchors.fill: parent

        WifiControl {
            height: parent.height
            width: (parent.width - parent.spacing) / 2
        }

        BluetoothControl {
            height: parent.height
            width: (parent.width - parent.spacing) / 2
        }
    }
}
