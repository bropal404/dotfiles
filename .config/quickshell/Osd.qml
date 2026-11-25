import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import QtQuick

// Toast for volume / brightness changes. Driven by IPC (see shell.qml):
//   qs ipc call osd volume | brightness
// Click-through, never takes focus, fades after ~1.4s.
PanelWindow {
    id: osd
    required property var modelData
    screen: modelData

    property string kind: "volume"
    readonly property var sink: Pipewire.defaultAudioSink
    PwObjectTracker { objects: [osd.sink] }

    readonly property real vol: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real level: kind === "volume" ? (muted ? 0 : vol) : Brightness.value
    readonly property string glyph: kind === "volume"
        ? (muted ? "󰝟" : vol < 0.34 ? "󰕿" : vol < 0.67 ? "󰖀" : "󰕾")
        : (Brightness.value > 0.6 ? "󰃠" : Brightness.value > 0.25 ? "󰃟" : "󰃞")
    readonly property string label: kind === "volume" ? (muted ? "MUTED" : "VOLUME") : "BRIGHTNESS"

    function show(k) {
        kind = k;
        shown = true;
        hideTimer.restart();
    }
    property bool shown: false

    visible: card.opacity > 0.01
    color: "transparent"
    anchors { bottom: true }
    margins { bottom: 72 }
    implicitWidth: 320
    implicitHeight: 64
    exclusionMode: ExclusionMode.Ignore
    mask: Region {}

    WlrLayershell.namespace: "qs-osd"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Timer { id: hideTimer; interval: 1400; onTriggered: osd.shown = false }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: Theme.radiusXL
        color: Theme.alpha(Theme.surfaceContainerHigh, 0.82)
        border.width: 1
        border.color: Theme.alpha(Theme.outlineVariant, 0.8)
        opacity: osd.shown ? 1 : 0
        transform: Translate { y: osd.shown ? 0 : 8; Behavior on y { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } } }
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        Icon {
            id: ico
            anchors { left: parent.left; leftMargin: 18; verticalCenter: parent.verticalCenter }
            width: 28
            size: 24
            text: osd.glyph
            color: osd.muted && osd.kind === "volume" ? Theme.outline : Theme.primary
        }

        Column {
            anchors { left: ico.right; leftMargin: 14; right: pct.left; rightMargin: 14; verticalCenter: parent.verticalCenter }
            spacing: 8
            StyledText {
                caps: true
                text: osd.label
                font.pixelSize: 10
                color: Theme.fgSurfaceVariant
            }
            Rectangle {
                width: parent.width; height: 3; radius: 1.5
                color: Theme.alpha(Theme.fgSurface, 0.14)
                Rectangle {
                    height: parent.height; radius: parent.radius
                    width: parent.width * Math.max(0, Math.min(1, osd.level))
                    color: osd.muted && osd.kind === "volume" ? Theme.outline : Theme.primary
                    Behavior on width { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                }
            }
        }

        StyledText {
            id: pct
            anchors { right: parent.right; rightMargin: 18; verticalCenter: parent.verticalCenter }
            width: 40
            horizontalAlignment: Text.AlignRight
            text: Math.round(osd.level * 100)
            font.pixelSize: 15
            font.weight: Font.Light
        }
    }
}
