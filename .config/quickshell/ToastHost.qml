import Quickshell
import Quickshell.Wayland
import QtQuick

// Renders Toast on the monitor that was focused when it fired. Click-through, no focus, ~2.2s, bottom centre.
PanelWindow {
    id: host
    required property var modelData
    screen: modelData

    readonly property bool here: Toast.monitor === "" || Toast.monitor === screen.name

    visible: card.opacity > 0.01
    color: "transparent"
    anchors { bottom: true }
    margins { bottom: 56 }       // same spot as the volume / brightness OSD
    implicitWidth: Math.max(240, Math.min(460, row.implicitWidth + 44))
    implicitHeight: 56
    exclusionMode: ExclusionMode.Ignore
    mask: Region {}

    WlrLayershell.namespace: "qs-toast"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Timer { id: hideTimer; interval: 2200; onTriggered: Toast.hide() }
    Connections { target: Toast; function onSerialChanged() { hideTimer.restart(); } }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: Theme.radiusXL
        color: Theme.alpha(Theme.surfaceContainerHigh, 0.72)
        border.width: 1
        border.color: Theme.alpha(Theme.outlineVariant, 0.8)
        opacity: Toast.shown && host.here ? 1 : 0
        transform: Translate { y: Toast.shown && host.here ? 0 : 8; Behavior on y { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } } }
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 14
            Icon { anchors.verticalCenter: parent.verticalCenter; text: Toast.icon; size: 22; color: Theme.primary }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                StyledText {
                    caps: true
                    text: Toast.title
                    font.pixelSize: 11
                    color: Theme.fgSurfaceVariant
                }
                StyledText {
                    visible: Toast.body !== ""
                    text: Toast.body
                    font.pixelSize: 14
                    font.weight: Font.Light
                    width: Math.min(implicitWidth, 380)
                }
            }
        }
    }
}
