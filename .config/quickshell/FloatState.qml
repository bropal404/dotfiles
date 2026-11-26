pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Which workspaces are in floating-only mode. Written by hyprland.lua (save_float_state).
Singleton {
    id: root
    property var workspaces: []

    FileView {
        id: file
        path: Quickshell.env("XDG_RUNTIME_DIR") + "/hypr/" + Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") + "/floatws"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.workspaces = text().split("\n").filter(l => l.startsWith("ws ")).map(l => parseInt(l.slice(3)))
    }
}
