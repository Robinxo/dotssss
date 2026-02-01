import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: bg

    property string apiData: ""

    implicitWidth: 400
    implicitHeight: 200
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Background
    exclusiveZone: -1
    Component.onCompleted: curlProc.running = true

    anchors {
        right: true
        top: true
    }

    margins {
        left: 500
        right: 1000
        top: 100
    }

    Process {
        id: curlProc

        command: ["curl", "-s", "https://wttr.in/new+delhi?format=1"]

        stdout: StdioCollector {
            onStreamFinished: {
                bg.apiData = text.trim();
            }
        }

    }

    Rectangle {
        anchors.fill: parent
        color: "#ffffff"
        radius: 50

        Text {
            anchors.centerIn: parent
            font.pixelSize: 70
            font.family: "JetBrains Mono Nerd"
            font.weight: Font.Bold
            color: "#888888"
            text: bg.apiData
        }

    }

}
