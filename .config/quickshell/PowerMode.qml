pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Desktop power mode (see ~/.config/hypr/scripts/powermode).
//   override:  "auto" (follow the charger) | "saver" | "performance"
//   effective: "battery" | "ac"  — what the desktop is actually set to
Singleton {
    id: pm

    property string override: "auto"
    property string effective: "battery"
    readonly property bool saving: effective === "battery"
    readonly property string script: Quickshell.env("HOME") + "/.config/hypr/scripts/powermode"

    function refresh() { getter.running = true; }
    function set(mode) {
        override = mode;
        effective = mode === "saver" ? "battery" : mode === "performance" ? "ac" : effective;
        Quickshell.execDetached([script, "set", mode]);
        settle.restart();
    }
    // auto → saver → performance → auto
    function cycle() { set(override === "auto" ? "saver" : override === "saver" ? "performance" : "auto"); }

    Process {
        id: getter
        command: [pm.script, "get"]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim().split(" ");
                if (p.length === 2) { pm.override = p[0]; pm.effective = p[1]; }
            }
        }
    }
    Timer { id: settle; interval: 1500; onTriggered: pm.refresh() }
    Component.onCompleted: refresh()
}
