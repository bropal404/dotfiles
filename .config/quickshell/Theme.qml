pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Material You tokens. Colours live in colors.json, written by matugen from the
// wallpaper; the file is watched so re-running matugen re-themes the shell live.
//   matugen image <wallpaper> -m dark --source-color-index 0
Singleton {
    id: theme

    property var c: ({})

    FileView {
        id: file
        path: Quickshell.shellDir + "/colors.json"
        watchChanges: true
        blockLoading: true
        onFileChanged: reload()
        onLoaded: {
            try { theme.c = JSON.parse(text()); } catch (e) { console.warn("Theme: bad colors.json", e); }
        }
    }
    Component.onCompleted: {
        try { c = JSON.parse(file.text()); } catch (e) {}
    }

    function col(name, fallback) { return c[name] ?? fallback; }

    // ── colour roles ──
    readonly property color primary:                 col("primary", "#ffb68d")
    readonly property color fgPrimary:               col("on_primary", "#532201")
    readonly property color primaryContainer:        col("primary_container", "#6f3813")
    readonly property color fgPrimaryContainer:      col("on_primary_container", "#ffdbc9")
    readonly property color secondary:               col("secondary", "#e5bfa9")
    readonly property color secondaryContainer:      col("secondary_container", "#5c4131")
    readonly property color fgSecondaryContainer:    col("on_secondary_container", "#ffdbc9")
    readonly property color tertiary:                col("tertiary", "#cdc991")
    readonly property color tertiaryContainer:       col("tertiary_container", "#4b4a1d")
    readonly property color fgTertiaryContainer:     col("on_tertiary_container", "#eae5ab")
    readonly property color error:                   col("error", "#ffb4ab")
    readonly property color fgError:                 col("on_error", "#690005")
    readonly property color errorContainer:          col("error_container", "#93000a")
    readonly property color fgErrorContainer:        col("on_error_container", "#ffdad6")
    readonly property color surface:                 col("surface", "#1a120d")
    readonly property color surfaceContainerLowest:  col("surface_container_lowest", "#140d08")
    readonly property color surfaceContainerLow:     col("surface_container_low", "#221a15")
    readonly property color surfaceContainer:        col("surface_container", "#271e19")
    readonly property color surfaceContainerHigh:    col("surface_container_high", "#322823")
    readonly property color surfaceContainerHighest: col("surface_container_highest", "#3d332d")
    readonly property color fgSurface:               col("on_surface", "#f0dfd7")
    readonly property color fgSurfaceVariant:        col("on_surface_variant", "#d7c2b8")
    readonly property color outline:                 col("outline", "#a08d84")
    readonly property color outlineVariant:          col("outline_variant", "#52443c")
    readonly property color inverseSurface:          col("inverse_surface", "#f0dfd7")
    readonly property color inverseOnSurface:        col("inverse_on_surface", "#382e29")
    readonly property color shadow:                  col("shadow", "#000000")
    // Dune extras
    readonly property color sky:                     col("sky", "#161924")      // night sky over Arrakis
    readonly property color flare:                   col("flare", "#fff4ec")    // the eclipse flare point
    readonly property color spice:                   primary
    readonly property color sand:                    fgSurface

    function alpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a); }

    // ── type / shape / motion ──  (Dune: thin, wide, tracked caps; near-square shapes; slow motion)
    readonly property string font: "Lexend"                 // body text
    readonly property string displayFont: "Lexend Peta"     // ultra-wide titles / clock
    readonly property string iconFont: "JetBrainsMono Nerd Font Propo"
    readonly property real tracking: 2.2                    // letter spacing for caps labels
    readonly property real trackingWide: 6

    readonly property int barHeight: 40
    readonly property int gap: 8
    readonly property int radiusFull: 999
    readonly property int radiusPill: 2
    readonly property int radiusXL: 6
    readonly property int radiusL: 4
    readonly property int radiusM: 3
    readonly property int radiusS: 2

    readonly property int durShort: 200
    readonly property int durMedium: 420
    readonly property int durLong: 700
    // long, settling ease-out (like sand coming to rest)
    readonly property var curve: [0.16, 1, 0.3, 1, 1, 1]
}
