pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Night light (hyprsunset) — state lives in ~/.config/hypr/scripts/nightlight, which also shows the toast.
Singleton {
    id: root
    property bool on: false
    readonly property string script: Quickshell.env("HOME") + "/.config/hypr/scripts/nightlight"

    function refresh() { if (!getter.running) getter.running = true; }
    function toggle() {
        on = !on;                          // optimistic; re-read once the script has run
        Quickshell.execDetached([script, "toggle"]);
        settle.restart();
    }

    Process {
        id: getter
        command: [root.script, "status"]
        stdout: StdioCollector { onStreamFinished: root.on = text.trim() === "on" }
    }
    Timer { id: settle; interval: 700; onTriggered: root.refresh() }
    Component.onCompleted: refresh()
}
