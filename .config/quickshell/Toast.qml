pragma Singleton
import Quickshell
import Quickshell.Hyprland
import QtQuick

// Transient confirmation toasts (state changes, "copied", …). They are NOT notifications:
// nothing is stored in history and nothing plays a sound.
//
//   from QML:   Toast.show("󰖩", "Wi-Fi", "Off")      // icon, title, optional body
//               Toast.state("󰖩", "Wi-Fi", on)        // title + On/Off body
//   from shell: ~/.config/hypr/scripts/toast "Title" ["Body"] ["icon"]
//               qs ipc call toast post "<icon>" "<title>" "<body>"
Singleton {
    property string icon: ""
    property string title: ""
    property string body: ""
    property string monitor: ""      // toast appears on the monitor that was focused when it fired
    property int serial: 0           // bumps on every show, so the host can restart its timer
    property bool shown: false

    function show(icon, title, body) {
        this.icon = icon || "󰋽";
        this.title = title || "";
        this.body = body || "";
        monitor = Hyprland.focusedMonitor?.name ?? "";
        shown = true;
        serial++;
    }
    function state(icon, title, on, detail) {
        show(icon, title, (on ? "On" : "Off") + (detail ? " · " + detail : ""));
    }
    function hide() { shown = false; }
}
