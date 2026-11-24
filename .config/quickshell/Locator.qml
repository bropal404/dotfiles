import Quickshell
import Quickshell.Wayland
import QtQuick

// "Where's my cursor?" — shrinking rings converge on the pointer. `qs ipc call locator ping <x> <y>`
// x/y are global layout coords (from `hyprctl cursorpos`). Click-through overlay.
PanelWindow {
    id: loc
    required property var modelData
    screen: modelData

    property real px: 0
    property real py: 0
    property bool active: false

    function ping(gx, gy) {
        const lx = gx - screen.x, ly = gy - screen.y;
        if (lx < -40 || ly < -40 || lx > screen.width + 40 || ly > screen.height + 40) return;
        px = lx; py = ly;
        active = true;
        anim.restart();
        done.restart();
    }

    visible: active
    color: "transparent"
    anchors { left: true; right: true; top: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore
    mask: Region {}
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-locator"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Timer { id: done; interval: 1100; onTriggered: loc.active = false }

    property real t: 0
    NumberAnimation on t { id: anim; from: 0; to: 1; duration: 1000; easing.type: Easing.OutCubic; running: false }

    Repeater {
        model: 3
        Rectangle {
            required property int index
            readonly property real p: Math.max(0, Math.min(1, loc.t * 1.25 - index * 0.18))
            readonly property real d: 360 * (1 - p) + 44
            width: d; height: d; radius: d / 2
            x: loc.px - d / 2; y: loc.py - d / 2
            color: "transparent"
            border.width: 2
            border.color: Theme.alpha(Theme.primary, 0.9 * (1 - Math.abs(p - 0.5) * 1.2) * (p > 0 ? 1 : 0))
        }
    }
}
