pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick

// Learns which apps you use: every newly opened window bumps its app's "frecency" score
// (frequency weighted by recency, half-life 5 days). The launcher pins the top apps.
// Stored in ~/.local/state/quickshell/by-shell/<id>/app-usage.json
Singleton {
    id: root

    readonly property real halfLifeMs: 5 * 24 * 3600 * 1000
    property var scores: ({})        // desktop-entry id → { s: score, t: last-used ms }
    property int revision: 0         // bumps on every change so bindings re-evaluate

    // apps that are always-open infrastructure, not worth pinning
    readonly property var ignored: ["quickshell", "org.quickshell", "hyprland-share-picker", "xdg-desktop-portal"]

    FileView {
        id: file
        path: Quickshell.statePath("app-usage.json")
        blockLoading: true
        atomicWrites: true
        printErrors: false
        onLoaded: { try { root.scores = JSON.parse(text()); root.revision++; } catch (e) { root.scores = {}; } }
    }
    Component.onCompleted: { try { scores = JSON.parse(file.text()); revision++; } catch (e) {} }

    function decayed(entry, now) {
        return entry.s * Math.pow(0.5, (now - entry.t) / halfLifeMs);
    }

    function record(id) {
        if (!id || ignored.some(x => id.toLowerCase().includes(x))) return;
        const now = Date.now();
        const e = scores[id];
        // ignore bursts (an app opening several windows at once)
        if (e && now - e.t < 4000) return;
        const s = e ? decayed(e, now) + 1 : 1;
        const next = Object.assign({}, scores);
        next[id] = { s: s, t: now };
        scores = next;
        revision++;
        saveTimer.restart();
    }

    function recordClass(cls) {
        const entry = DesktopEntries.heuristicLookup(cls);
        if (entry && !entry.noDisplay) record(entry.id);
    }

    function forget(id) {
        const next = Object.assign({}, scores);
        delete next[id];
        scores = next;
        revision++;
        saveTimer.restart();
    }

    // top-N desktop entries by current score
    function top(n) {
        void revision;
        const now = Date.now();
        return Object.keys(scores)
            .map(id => ({ id: id, score: decayed(scores[id], now), entry: DesktopEntries.byId(id) }))
            .filter(x => x.entry && !x.entry.noDisplay && x.score > 0.05)
            .sort((a, b) => b.score - a.score)
            .slice(0, n)
            .map(x => x.entry);
    }

    function scoreOf(id) {
        void revision;
        const e = scores[id];
        return e ? decayed(e, Date.now()) : 0;
    }

    Timer {
        id: saveTimer
        interval: 1500
        onTriggered: file.setText(JSON.stringify(root.scores))
    }

    // first run: seed from whatever is open right now so the pinned row isn't empty
    Timer {
        interval: 3000
        running: true
        onTriggered: {
            if (Object.keys(root.scores).length > 0) return;
            const next = {};
            const now = Date.now();
            for (const t of ToplevelManager.toplevels.values) {
                const e = DesktopEntries.heuristicLookup(t.appId);
                if (e && !e.noDisplay && !root.ignored.some(x => e.id.toLowerCase().includes(x)))
                    next[e.id] = { s: (next[e.id]?.s ?? 0) + 1, t: now };
            }
            root.scores = next;
            root.revision++;
            saveTimer.restart();
        }
    }

    // every window opened anywhere counts: launcher, keybinds, terminal, autostart
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name !== "openwindow") return;
            // data: address,workspace,class,title
            const parts = event.data.split(",");
            if (parts.length >= 3) root.recordClass(parts[2]);
        }
    }
}
