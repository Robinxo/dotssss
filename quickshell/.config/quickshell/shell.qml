import QtQuick
import Quickshell
import Quickshell.Wayland
import "components"

PanelWindow {
    WlrLayershell.layer: WlrLayer.Background
    exclusiveZone: -1
    color: "transparent"

    Weather {
    }

    Clock {
    }

}
