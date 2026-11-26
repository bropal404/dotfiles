//@ pragma UseQApplication
//@ pragma IconTheme Papirus-Dark
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

ShellRoot {
    Variants {
        id: bars
        model: Quickshell.screens
        Bar {}
    }

    // drifting sand behind windows
    Variants {
        id: storms
        model: Quickshell.screens
        Sandstorm {}
    }

    // login title card
    Variants {
        id: intros
        model: Quickshell.screens
        DuneIntro {}
    }

    // power menu (hold-to-confirm): `qs ipc call power toggle`
    Variants {
        id: powers
        model: Quickshell.screens
        PowerMenu {}
    }
    IpcHandler {
        target: "power"
        function toggle(): void {
            const name = Hyprland.focusedMonitor?.name;
            for (const p of powers.instances)
                if (p.screen.name === name) p.toggle();
        }
    }

    // `qs ipc call intro play` — title card + horn
    IpcHandler {
        target: "intro"
        function play(): void {
            Sfx.play("horn", 0.75);
            for (const i of intros.instances) i.play();
        }
    }

    // `qs ipc call sand toggle` / `sand gust`
    IpcHandler {
        target: "sand"
        function toggle(): void { for (const s of storms.instances) s.enabled = !s.enabled; }
        function enable(): void { for (const s of storms.instances) s.enabled = true; }
        function disable(): void { for (const s of storms.instances) s.enabled = false; }
        function gust(): void {
            Sfx.play("wind", 0.6);
            for (const s of storms.instances) { s.gust = true; }
            gustEnd.restart();
        }
    }
    Timer { id: gustEnd; interval: 4500; onTriggered: { for (const s of storms.instances) s.gust = false; } }

    // find-the-cursor rings: `qs ipc call locator ping <x> <y>`
    Variants {
        id: locators
        model: Quickshell.screens
        Locator {}
    }
    IpcHandler {
        target: "locator"
        function ping(x: int, y: int): void { for (const l of locators.instances) l.ping(x, y); }
    }

    // volume / brightness toast: `qs ipc call osd volume|brightness`
    Variants {
        id: osds
        model: Quickshell.screens
        Osd {}
    }
    IpcHandler {
        target: "osd"
        function volume(): void { _show("volume"); }
        function brightness(): void { Brightness.refresh(); _show("brightness"); }
        function _show(kind: string): void {
            const mon = Hyprland.focusedMonitor?.name;
            for (const o of osds.instances)
                if (o.screen.name === mon) o.show(kind);
        }
    }

    // window dock for floating-only workspaces (SUPER+SPACE)
    Variants {
        model: Quickshell.screens
        FloatDock {}
    }

    Variants {
        id: toasts
        model: Quickshell.screens
        NotificationToasts {}
    }

    // transient confirmation toasts: `qs ipc call toast post <icon> <title> <body>`
    // (shell scripts: ~/.config/hypr/scripts/toast)
    Variants {
        model: Quickshell.screens
        ToastHost {}
    }
    IpcHandler {
        target: "toast"
        function post(icon: string, title: string, body: string): void { Toast.show(icon, title, body); }
    }

    // `qs ipc call startmenu toggle` opens the app launcher on the focused monitor
    IpcHandler {
        target: "startmenu"
        function toggle(): void {
            const name = Hyprland.focusedMonitor?.name;
            for (const b of bars.instances)
                if (b.screen.name === name) b.toggleMenu();
        }
    }

    // `qs ipc call controlcenter toggle` opens the control center on the focused monitor
    IpcHandler {
        target: "controlcenter"
        function toggle(): void {
            const name = Hyprland.focusedMonitor?.name;
            for (const b of bars.instances)
                if (b.screen.name === name) b.togglePanel();
        }
    }
}
