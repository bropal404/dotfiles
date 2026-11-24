import QtQuick

// The Dune "eclipse flare": a hairline of light with a ringed black sun at its centre.
// Used as the launcher sigil, the workspace marker, separators and in the intro.
Item {
    id: e
    property real ringSize: 9
    property real flareLength: 48
    property real intensity: 1.0          // 0..1 brightness of line + glow
    property color color: Theme.flare
    property bool showRing: true

    implicitWidth: Math.max(flareLength, ringSize)
    implicitHeight: ringSize * 2.6

    // flare line, brightest in the middle
    Rectangle {
        anchors.centerIn: parent
        width: e.flareLength
        height: 1
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.35; color: Theme.alpha(Theme.spice, 0.35 * e.intensity) }
            GradientStop { position: 0.5; color: Theme.alpha(e.color, 0.95 * e.intensity) }
            GradientStop { position: 0.65; color: Theme.alpha(Theme.spice, 0.35 * e.intensity) }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    // soft halo (stacked translucent discs)
    Repeater {
        model: e.showRing ? 3 : 0
        Rectangle {
            required property int index
            anchors.centerIn: parent
            width: e.ringSize * (1.5 + index * 0.55)
            height: width
            radius: width / 2
            color: Theme.alpha(e.color, (0.10 - index * 0.03) * e.intensity)
        }
    }

    // the black sun with its burning rim
    Rectangle {
        visible: e.showRing
        anchors.centerIn: parent
        width: e.ringSize
        height: width
        radius: width / 2
        color: "#07070a"
        border.width: Math.max(1, e.ringSize / 7)
        border.color: Theme.alpha(e.color, 0.55 + 0.45 * e.intensity)
    }
}
