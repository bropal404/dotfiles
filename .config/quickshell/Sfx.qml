pragma Singleton
import Quickshell
import QtQuick

// Dune sound effects (synthesised by ~/.config/hypr/sounds/gen.py), played via the sfx script,
// which also honours the global mute flag (~/.cache/dune-sfx-off; toggle with `sfx toggle`).
Singleton {
    function play(name, volume) {
        Quickshell.execDetached([Quickshell.env("HOME") + "/.config/hypr/scripts/sfx", name, String(volume ?? 0.7)]);
    }
}
