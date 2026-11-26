import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick

// Icons-only dock on the left edge, shown while the monitor's workspace is floating-only.
// Lists that workspace's windows; click to focus + raise, scroll to cycle, middle click to close.
PanelWindow {
    id: dock
    required property var modelData
    screen: modelData

    readonly property var workspace: Hyprland.monitorFor(screen)?.activeWorkspace ?? null
    readonly property bool floating: workspace !== null && FloatState.workspaces.includes(workspace.id)
    // stable order (by address) so icons don't jump around when focus changes
    readonly property var windows: !floating ? [] : Hyprland.toplevels.values
        .filter(t => t.workspace?.id === workspace.id)
        .sort((a, b) => a.address.localeCompare(b.address))
    readonly property bool wanted: floating && windows.length > 0

    // keeps the last list while sliding out, so the dock doesn't empty before it leaves
    property var shownWindows: []
    onWindowsChanged: if (wanted) shownWindows = windows
    onWantedChanged: if (wanted) shownWindows = windows

    property real slide: wanted ? 1 : 0
    Behavior on slide { NumberAnimation { duration: Theme.durMedium; easing.type: Easing.OutCubic } }

    function focusWindow(t) {
        Quickshell.execDetached(["hyprctl", "eval", 'FloatFocus("0x' + t.address.replace(/^0x/, "") + '")']);
    }
    function cycle(step) {
        const n = shownWindows.length;
        if (n === 0) return;
        const i = shownWindows.findIndex(t => t.activated);
        focusWindow(shownWindows[((i < 0 ? 0 : i + step) + n) % n]);
    }

    visible: slide > 0.01
    color: "transparent"
    anchors { left: true }          // no top/bottom anchor: vertically centred
    exclusiveZone: 0
    implicitWidth: 64
    implicitHeight: Math.max(1, column.implicitHeight + 16)
    mask: Region { item: card }

    WlrLayershell.namespace: "qs-dock"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Rectangle {
        id: card
        width: 56
        height: parent.height
        x: 6 - (1 - dock.slide) * 64
        opacity: dock.slide
        radius: Theme.radiusXL
        color: Theme.alpha(Theme.surfaceContainer, 0.72)
        border.width: 1
        border.color: Theme.alpha(Theme.outlineVariant, 0.6)

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: w => dock.cycle(w.angleDelta.y > 0 ? -1 : 1)
        }

        Column {
            id: column
            anchors.centerIn: parent
            spacing: 6

            move: Transition { NumberAnimation { properties: "y"; duration: Theme.durShort; easing.type: Easing.OutCubic } }

            Repeater {
                model: ScriptModel { values: dock.shownWindows }
                delegate: Item {
                    id: entry
                    required property var modelData
                    required property int index
                    readonly property bool current: modelData.activated
                    readonly property string appId: modelData.wayland?.appId ?? ""
                    readonly property var desktop: appId ? DesktopEntries.heuristicLookup(appId) : null
                    width: 44; height: 44

                    // pop in, one after another
                    scale: 0
                    SequentialAnimation on scale {
                        PauseAnimation { duration: 60 + entry.index * 55 }
                        NumberAnimation { to: 1; duration: Theme.durMedium; easing.type: Easing.OutBack }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.radiusL
                        color: entry.current ? Theme.alpha(Theme.primary, 0.28)
                             : mouse.containsMouse ? Theme.alpha(Theme.fgSurface, 0.10) : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.durShort } }
                    }
                    IconImage {
                        anchors.centerIn: parent
                        implicitSize: 30
                        source: Quickshell.iconPath(entry.desktop?.icon || entry.appId, "application-x-executable")
                        scale: mouse.pressed ? 0.9 : mouse.containsMouse ? 1.18 : 1
                        Behavior on scale { NumberAnimation { duration: Theme.durShort; easing.type: Easing.OutBack } }
                    }
                    // focus marker grows on the focused window
                    Rectangle {
                        anchors { left: parent.left; leftMargin: -4; verticalCenter: parent.verticalCenter }
                        width: 3; radius: 1.5
                        height: entry.current ? 22 : 6
                        color: entry.current ? Theme.primary : Theme.outline
                        Behavior on height { NumberAnimation { duration: Theme.durMedium; easing.type: Easing.OutBack } }
                    }
                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                        onClicked: m => {
                            if (m.button === Qt.MiddleButton) entry.modelData.wayland?.close();
                            else dock.focusWindow(entry.modelData);
                        }
                        onWheel: w => dock.cycle(w.angleDelta.y > 0 ? -1 : 1)
                    }
                }
            }
        }
    }
}
