import QtQuick
import Quickshell.Io

import "../"

Row {
    id: root
    spacing: 10

    property string title: "Labyrinth"
    property string appId: ""
    property bool hasWindow: appId !== ""

    Process {
        id: watcher
        command: ["bash", "-c", "scripts/niri-active-window.sh"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                try {
                    let win = JSON.parse(data);
                    root.title = win.title || "Labyrinth";
                    root.appId = win.appId || "";
                } catch (e) {
                    console.log("[WindowTitle] Parse error:", e);
                }
            }
        }
    }

    Text {
        color: Theme.palette.primary80
        text: root.hasWindow ? Utils.getIcon(root.appId, root.title) : ""

        anchors.verticalCenter: parent.verticalCenter

        font {
            bold: true
            family: Theme.fontFamily
            pixelSize: Theme.fontSize
        }
    }

    Text {
        color: Theme.palette.neutral80
        elide: Text.ElideRight
        maximumLineCount: 1
        text: root.title
        width: Math.min(implicitWidth, 400)

        anchors.verticalCenter: parent.verticalCenter

        font {
            bold: true
            family: Theme.fontFamily
            pixelSize: Theme.fontSize
        }
    }
}
