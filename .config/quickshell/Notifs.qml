pragma Singleton
import Quickshell
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
