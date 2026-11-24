pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Backlight via sysfs (read) + logind SetBrightness (write, no root needed).
Singleton {
    id: bl

    property string device: ""
    property int max: 0
    property int raw: 0
    readonly property bool available: device !== "" && max > 0
    readonly property real value: available ? raw / max : 0

    function set(v) {
        if (!available) return;
        const r = Math.max(1, Math.round(Math.max(0.01, Math.min(1, v)) * max));
        raw = r;
        Quickshell.execDetached(["busctl", "call", "org.freedesktop.login1",
            "/org/freedesktop/login1/session/auto", "org.freedesktop.login1.Session",
            "SetBrightness", "ssu", "backlight", device, String(r)]);
    }

    function refresh() { curFile.reload(); }

    Process {
        running: true
        command: ["sh", "-c", "for d in /sys/class/backlight/*; do [ -e \"$d\" ] && basename \"$d\" && break; done"]
        stdout: StdioCollector { onStreamFinished: bl.device = text.trim() }
    }
    FileView {
        id: maxFile
        path: bl.device ? `/sys/class/backlight/${bl.device}/max_brightness` : ""
        onLoaded: bl.max = parseInt(text()) || 0
    }
    FileView {
        id: curFile
        path: bl.device ? `/sys/class/backlight/${bl.device}/brightness` : ""
        onLoaded: bl.raw = parseInt(text()) || 0
    }
    // sysfs doesn't emit inotify on brightness changes, so poll (cheap)
    Timer {
        interval: 1500; running: bl.device !== ""; repeat: true
        onTriggered: curFile.reload()
    }
}
