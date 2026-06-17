import QtQuick

import "../"

Item {
    id: root
    implicitWidth: clockText.implicitWidth
    implicitHeight: 32

    property string timeText: ""
    property string dateText: ""
    property bool isHovered: clockMouse.containsMouse

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true

        onTriggered: {
            let d = new Date();
            root.timeText = Qt.formatTime(d, "h:mm AP");
            root.dateText = Qt.formatDate(d, "ddd, d MMM");
        }
    }

    Text {
        id: clockText
        color: Theme.palette.secondary80
        text: root.timeText

        anchors.centerIn: parent

        font {
            bold: true
            family: Theme.fontFamily
            pixelSize: Theme.fontSize
        }
    }

    MouseArea {
        id: clockMouse
        hoverEnabled: true

        anchors.fill: parent
    }
}
