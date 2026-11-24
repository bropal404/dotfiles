pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// CPU / RAM / disk / uptime. Polls only while `active` (widgets panel open).
Singleton {
    id: s

    property bool active: false
    property real cpu: 0
    property real mem: 0
    property real memUsedGb: 0
    property real memTotalGb: 0
    property real disk: 0
    property string diskLabel: ""
    property string uptime: ""

    property var _prev: null

    FileView { id: stat; path: "/proc/stat"; blockAllReads: true }
    FileView { id: meminfo; path: "/proc/meminfo"; blockAllReads: true }
    FileView { id: up; path: "/proc/uptime"; blockAllReads: true }

    function sample() {
        stat.reload(); meminfo.reload(); up.reload();

        const nums = stat.text().split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
        const idle = nums[3] + (nums[4] || 0);
        const total = nums.reduce((a, b) => a + b, 0);
        if (_prev) {
            const dt = total - _prev.total;
            if (dt > 0) cpu = 1 - (idle - _prev.idle) / dt;
        }
        _prev = { idle, total };

        const m = {};
        for (const l of meminfo.text().split("\n")) {
            const p = l.split(/:\s+/);
            if (p.length === 2) m[p[0]] = parseInt(p[1]);
        }
        if (m.MemTotal) {
            memTotalGb = m.MemTotal / 1048576;
            memUsedGb = (m.MemTotal - m.MemAvailable) / 1048576;
            mem = memUsedGb / memTotalGb;
        }

        const secs = parseFloat(up.text()) || 0;
        const d = Math.floor(secs / 86400), h = Math.floor(secs % 86400 / 3600), min = Math.floor(secs % 3600 / 60);
        uptime = (d ? d + "d " : "") + (h ? h + "h " : "") + min + "m";
    }

    Timer {
        interval: 2000; running: s.active; repeat: true; triggeredOnStart: true
        onTriggered: { s.sample(); if (!df.running) df.running = true; }
    }

    Process {
        id: df
        command: ["df", "-P", "-B1", "/"]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = (text.trim().split("\n")[1] || "").split(/\s+/);
                const used = Number(f[2]), size = Number(f[1]);
                if (size) {
                    s.disk = used / size;
                    s.diskLabel = (used / 1e9).toFixed(0) + " / " + (size / 1e9).toFixed(0) + " GB";
                }
            }
        }
    }
}
