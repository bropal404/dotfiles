pragma Singleton
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import QtQuick

// Notification daemon: popups + history for the widgets panel.
Singleton {
    id: root

    property bool dnd: false
    property var popups: []      // notifications currently shown as toasts
    property var times: ({})     // id → arrival time
    readonly property var list: server.trackedNotifications.values
    readonly property int count: list.length

    function dismissPopup(n) { popups = popups.filter(p => p !== n); }
    function clearAll() {
        for (const n of list.slice()) n.dismiss();
        popups = [];
    }

    // ── click-through: open the notification AND bring the sending app forward ──
    // Apps (Chrome especially) can't raise their own window from here, so we find it ourselves.
    function findWindow(n) {
        const norm = s => (s ?? "").toLowerCase();
        const wins = Hyprland.toplevels.values.map(t => ({ t: t, cls: norm(t.wayland?.appId), title: norm(t.title) }));

        // web notifications from a browser carry the site, e.g. "web.whatsapp.com" → "whatsapp"
        const host = norm(n.body).match(/^\s*(?:<a [^>]*>)?(?:https?:\/\/)?((?:[a-z0-9-]+\.)+[a-z]{2,})/)?.[1];
        const site = host ? host.split(".").slice(-2)[0] : "";
        if (site) {
            const w = wins.find(w => w.title.includes(site));
            if (w) return w.t;
        }

        const names = [n.desktopEntry, n.appName].map(norm).filter(s => s !== "");
        for (const name of names) {
            const entry = DesktopEntries.byId(name) ?? DesktopEntries.heuristicLookup(name);
            const classes = [name, name.replace(/ /g, "-"), norm(entry?.startupClass), norm(entry?.id)].filter(s => s !== "");
            const w = wins.find(w => classes.includes(w.cls))
                   ?? wins.find(w => w.cls.endsWith("." + name) || w.title === name);
            if (w) return w.t;
        }
        return null;
    }

    function activate(n) {
        const target = findWindow(n);      // read before invoking: that may destroy the notification
        later.action = n.actions.find(a => a.identifier === "default") ?? null;
        later.address = target ? "0x" + target.address.replace(/^0x/, "") : "";
        later.restart();
    }
    // deferred: lets the panel release its focus grab, and the clicked item finish its handler
    // before invoking the action destroys it
    Timer {
        id: later
        property var action: null
        property string address: ""
        interval: 150
        onTriggered: {
            action?.invoke();
            if (address !== "") Quickshell.execDetached(["hyprctl", "eval", 'FloatFocus("' + address + '")']);
        }
    }

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: true
        actionsSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: n => {
            n.tracked = true;
            root.times[n.id] = new Date();
            n.closed.connect(() => root.dismissPopup(n));
            if (!root.dnd || n.urgency === NotificationUrgency.Critical) {
                root.popups = [n, ...root.popups].slice(0, 4);
                // a soft tone from the desert; an ominous pulse for critical ones
                if (n.urgency === NotificationUrgency.Critical) Sfx.play("low", 0.8);
                else if (n.appName !== "Arrakis") Sfx.play("notify", 0.55);
            }
        }
    }
}
