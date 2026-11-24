import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Particles

// Drifting sand behind your windows: fine grains blown across the desktop, with the
// occasional gust. Sits on the Bottom layer (above the wallpaper, below windows),
// is click-through, and can be toggled:  qs ipc call sand toggle
PanelWindow {
    id: storm
    required property var modelData
    screen: modelData

    property bool enabled: false   // off by default: costs ~27% of a core. HYPER+W toggles it.
    property bool gust: false

    visible: enabled
    color: "transparent"
    anchors { left: true; right: true; top: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "qs-sandstorm"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    mask: Region {}   // never takes input

    ParticleSystem {
        id: sys
        anchors.fill: parent
        running: storm.visible
    }

    // fine dust: tiny, faint, slow
    ImageParticle {
        system: sys
        groups: ["dust"]
        source: "qrc:///particleresources/glowdot.png"
        color: Theme.alpha(Theme.sand, 0.22)
        colorVariation: 0.08
        alphaVariation: 0.15
        entryEffect: ImageParticle.Fade
    }
    // grains: fewer, warmer, a touch brighter
    ImageParticle {
        system: sys
        groups: ["grain"]
        source: "qrc:///particleresources/glowdot.png"
        color: Theme.alpha(Theme.spice, 0.35)
        colorVariation: 0.1
        alphaVariation: 0.2
        rotationVariation: 180
        entryEffect: ImageParticle.Fade
    }

    // wind enters from the left edge, plus a sparse seeding across the whole screen
    Emitter {
        system: sys
        group: "dust"
        x: -20; y: 0
        width: 20; height: parent.height
        emitRate: storm.gust ? 70 : 14
        lifeSpan: 16000; lifeSpanVariation: 4000
        size: 3; sizeVariation: 2; endSize: 2
        velocity: AngleDirection { angle: 4; angleVariation: 8; magnitude: storm.gust ? 260 : 70; magnitudeVariation: 40 }
        acceleration: PointDirection { y: 2; yVariation: 3 }
    }
    Emitter {
        system: sys
        group: "dust"
        anchors.fill: parent
        emitRate: 2
        lifeSpan: 9000; lifeSpanVariation: 3000
        size: 2; sizeVariation: 2
        velocity: AngleDirection { angle: 2; angleVariation: 10; magnitude: 45; magnitudeVariation: 25 }
    }
    Emitter {
        system: sys
        group: "grain"
        x: -20; y: parent.height * 0.35
        width: 20; height: parent.height * 0.65      // grains hug the lower dunes
        emitRate: storm.gust ? 30 : 4
        lifeSpan: 9000; lifeSpanVariation: 3000
        size: 5; sizeVariation: 3; endSize: 3
        velocity: AngleDirection { angle: 3; angleVariation: 6; magnitude: storm.gust ? 420 : 120; magnitudeVariation: 60 }
        acceleration: PointDirection { y: 6; yVariation: 4 }
    }

    // swirl
    Turbulence {
        system: sys
        anchors.fill: parent
        strength: storm.gust ? 60 : 22
    }

    // random gusts every 25–70 s, lasting 3–6 s
    Timer {
        id: gustTimer
        running: storm.visible
        repeat: false
        interval: 25000 + Math.random() * 45000
        onTriggered: { storm.gust = true; calm.interval = 3000 + Math.random() * 3000; calm.start(); }
    }
    Timer {
        id: calm
        onTriggered: { storm.gust = false; gustTimer.interval = 25000 + Math.random() * 45000; gustTimer.start(); }
    }
}
