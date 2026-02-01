import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: bg

    property string timeString: ""

    function updateTime() {
        const now = new Date();
        timeString = now.toLocaleTimeString(Qt.locale(), "HH:mm");
    }

    implicitWidth: 400
    implicitHeight: 200
    WlrLayershell.layer: WlrLayer.Background
    exclusiveZone: -1
    Component.onCompleted: updateTime()
    color: "transparent"

    anchors {
        right: true
        top: true
    }

    margins {
        left: 20
        right: 200
        top: 300
    }

    Rectangle {
        anchors.fill: parent
        color: "#fff"
        radius: 50

        Text {
            id: clock

            anchors.centerIn: parent
            font.pixelSize: 100
            font.family: "JetBrains Mono Nerd"
            font.weight: Font.Bold
            color: "#888888"
            text: timeString
        }

    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: updateTime()
    }

}
