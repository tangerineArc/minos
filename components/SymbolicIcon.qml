import QtQuick
import Quickshell
import Qt5Compat.GraphicalEffects

import "../"

Item {
    id: root

    property string name: ""
    property color iconColor: "white"
    property int size: Theme.fontSize

    implicitWidth: size
    implicitHeight: size

    Image {
        id: rawIcon
        source: root.name ? Quickshell.iconPath(root.name) : ""
        visible: false

        sourceSize {
            height: root.size
            width: root.size
        }
    }

    ColorOverlay {
        color: root.iconColor
        source: rawIcon

        anchors.fill: rawIcon
    }
}
