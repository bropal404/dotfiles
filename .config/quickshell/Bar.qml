import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts

// DUNE bar — a thin dusk-glass strip with a sand hairline, tracked caps and the eclipse motif.
PanelWindow {
    id: bar
    required property var modelData
    screen: modelData

    anchors { left: true; right: true; bottom: true }
    implicitHeight: Theme.barHeight
    exclusiveZone: Theme.barHeight
    color: "transparent"
    WlrLayershell.namespace: "qs-bar"

    function toggleMenu()  { panel.visible = false; launcher.visible = !launcher.visible; }
    function togglePanel() { launcher.visible = false; panel.visible = !panel.visible; }

    Launcher { id: launcher; bar: bar; screen: bar.screen }
    ControlCenter { id: panel; bar: bar; screen: bar.screen }

    // shared state for the status cluster
    readonly property var sink: Pipewire.defaultAudioSink
    PwObjectTracker { objects: [bar.sink] }
    readonly property real vol: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property var battery: UPower.displayDevice
    readonly property bool hasBattery: battery?.isLaptopBattery ?? false
    readonly property real batPct: { const p = battery?.percentage ?? 0; return p > 1 ? p / 100 : p; }
    readonly property bool charging: battery?.state === UPowerDeviceState.Charging
                                   || battery?.state === UPowerDeviceState.FullyCharged
    readonly property bool btOn: Bluetooth.defaultAdapter?.enabled ?? false
    readonly property int btConnected: Bluetooth.devices.values.filter(d => d.connected).length

    // low-battery omen: play the low pulse once when crossing 15% (only from the first bar)
    property bool warnedLow: false
    onBatPctChanged: {
        if (hasBattery && !charging && batPct <= 0.15 && !warnedLow) {
            warnedLow = true;
            if (Quickshell.screens[0] === bar.screen) Sfx.play("low");
        }
        if (batPct > 0.2 || charging) warnedLow = false;
    }

    // vertical hairline separator
    component Sep: Rectangle {
        Layout.preferredWidth: 1
        Layout.preferredHeight: 16
        Layout.alignment: Qt.AlignVCenter
        color: Theme.alpha(Theme.sand, 0.18)
    }

    Rectangle {
        id: surface
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Theme.alpha(Theme.sky, 0.66) }
            GradientStop { position: 0.5; color: Theme.alpha(Theme.surfaceContainer, 0.60) }
            GradientStop { position: 1.0; color: Theme.alpha(Theme.sky, 0.66) }
        }

        // sand hairline along the top edge, brightest at the centre (over the clock)
        Rectangle {
            anchors { left: parent.left; right: parent.right; top: parent.top }
            height: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0;  color: "transparent" }
                GradientStop { position: 0.3;  color: Theme.alpha(Theme.spice, 0.25) }
                GradientStop { position: 0.5;  color: Theme.alpha(Theme.flare, 0.65) }
                GradientStop { position: 0.7;  color: Theme.alpha(Theme.spice, 0.25) }
                GradientStop { position: 1.0;  color: "transparent" }
            }
        }

        // ── left cluster ──
        RowLayout {
            anchors { left: parent.left; top: parent.top; bottom: parent.bottom; leftMargin: 10 }
            spacing: 14

            // sigil → launcher (right click: power menu)
            Item {
                id: sigil
                Layout.fillHeight: true
                Layout.preferredWidth: 46
                Eclipse {
                    anchors.centerIn: parent
                    ringSize: 11
                    flareLength: sigilMouse.containsMouse || launcher.visible ? 46 : 34
                    intensity: launcher.visible ? 1 : sigilMouse.containsMouse ? 0.9 : 0.75
                    Behavior on flareLength { NumberAnimation { duration: Theme.durMedium; easing.type: Easing.OutExpo } }
                    Behavior on intensity { NumberAnimation { duration: Theme.durMedium } }
                }
                MouseArea {
                    id: sigilMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: m => {
                        if (m.button === Qt.RightButton)
                            Quickshell.execDetached(["qs", "ipc", "call", "power", "toggle"]);
                        else bar.toggleMenu();
                    }
                }
            }

            Sep {}

            // workspaces: tracked numerals; a single flare marker drifts to the focused one
            Item {
                id: wsBox
                Layout.fillHeight: true
                Layout.preferredWidth: wsRow.implicitWidth

                readonly property var activeWsIds: (Hyprland.workspaces?.values ?? []).map(w => w.id).filter(id => id > 0)
                readonly property var wsList: {
                    const base = [1, 2, 3, 4, 5];
                    return Array.from(new Set([...base, ...activeWsIds])).sort((a, b) => a - b);
                }
                readonly property int focusedId: Hyprland.focusedWorkspace?.id ?? 1
                readonly property int focusedIdx: wsList.indexOf(focusedId)

                Row {
                    id: wsRow
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -5
                    spacing: 0
                    Repeater {
                        model: wsBox.wsList
                        delegate: Item {
                            id: ws
                            required property int modelData
                            readonly property bool focused: wsBox.focusedId === modelData
                            readonly property bool occupied: wsBox.activeWsIds.includes(modelData)
                            width: 30; height: 22
                            StyledText {
                                anchors.centerIn: parent
                                text: (ws.modelData < 10 ? "0" : "") + ws.modelData
                                font.family: Theme.displayFont
                                font.pixelSize: 10
                                font.weight: ws.focused ? Font.Normal : Font.Light
                                color: ws.focused ? Theme.flare
                                     : ws.occupied ? Theme.alpha(Theme.sand, 0.85)
                                     : Theme.alpha(Theme.sand, 0.4)
                                Behavior on color { ColorAnimation { duration: Theme.durMedium } }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + ws.modelData + " })")
                            }
                        }
                    }
                }
                // the drifting marker
                Eclipse {
                    visible: wsBox.focusedIdx >= 0
                    y: parent.height / 2 + 10 - height / 2
                    x: wsBox.focusedIdx * 30 + 15 - width / 2
                    ringSize: 3
                    flareLength: 30
                    intensity: 0.9
                    Behavior on x { NumberAnimation { duration: Theme.durLong; easing.type: Easing.OutExpo } }
                }
                MouseArea {
                    anchors.fill: parent
                    z: -1
                    onWheel: w => Hyprland.dispatch(w.angleDelta.y > 0 ? "hl.dsp.focus({ workspace = \"e-1\" })" : "hl.dsp.focus({ workspace = \"e+1\" })")
                }
            }

        }

        // ── centre: date | time, ultra-wide and tracked ──
        Item {
            id: clockBox
            anchors.centerIn: parent
            width: clockRow.implicitWidth + 24
            height: parent.height
            SystemClock { id: clock; precision: SystemClock.Minutes }
            Row {
                id: clockRow
                anchors.centerIn: parent
                spacing: 14
                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Qt.formatDateTime(clock.date, "ddd  d  MMM")
                    caps: true
                    font.family: Theme.displayFont
                    font.pixelSize: 9
                    font.weight: Font.Normal
                    color: Theme.alpha(Theme.sand, 0.85)
                }
                Rectangle { width: 1; height: 14; anchors.verticalCenter: parent.verticalCenter; color: Theme.alpha(Theme.spice, 0.6) }
                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Qt.formatDateTime(clock.date, "HH : mm")
                    font.family: Theme.displayFont
                    font.pixelSize: 14
                    font.weight: Font.Light
                    font.letterSpacing: 3
                    color: Theme.flare
                }
            }
            StateLayer { tint: Theme.sand; onClicked: bar.togglePanel() }
        }

        // ── right cluster ──
        RowLayout {
            anchors { right: parent.right; top: parent.top; bottom: parent.bottom; rightMargin: 10; topMargin: 6; bottomMargin: 6 }
            spacing: 12

            MediaChip { Layout.fillHeight: true; onClicked: bar.togglePanel() }

            Row {
                Layout.alignment: Qt.AlignVCenter
                visible: SystemTray.items.values.length > 0
                spacing: 10
                Repeater {
                    model: SystemTray.items
                    delegate: IconImage {
                        id: trayIcon
                        required property var modelData
                        implicitSize: 15
                        opacity: trayMouse.containsMouse ? 1 : 0.7
                        source: modelData.icon
                        MouseArea {
                            id: trayMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mouse => {
                                const p = trayIcon.mapToItem(bar.contentItem, 0, 0);
                                if (mouse.button === Qt.MiddleButton) trayIcon.modelData.secondaryActivate();
                                else if (mouse.button === Qt.RightButton || trayIcon.modelData.onlyMenu) {
                                    if (trayIcon.modelData.hasMenu) trayIcon.modelData.display(bar, p.x, p.y);
                                } else trayIcon.modelData.activate();
                            }
                            onWheel: w => trayIcon.modelData.scroll(w.angleDelta.y, false)
                        }
                    }
                }
            }

            Sep { visible: SystemTray.items.values.length > 0 }

            // status → control centre
            Rectangle {
                id: status
                Layout.fillHeight: true
                Layout.preferredWidth: statusRow.implicitWidth + 22
                radius: Theme.radiusS
                color: panel.visible ? Theme.alpha(Theme.spice, 0.22) : "transparent"
                border.width: 1
                border.color: panel.visible ? Theme.alpha(Theme.spice, 0.7) : "transparent"
                readonly property color fg: Theme.sand
                Behavior on color { ColorAnimation { duration: Theme.durMedium } }

                Row {
                    id: statusRow
                    anchors.centerIn: parent
                    spacing: 12
                    Icon { text: Net.icon; color: status.fg; size: 14 }
                    Icon { visible: Net.vpnActive; text: "󰦝"; color: Theme.tertiary; size: 14 }
                    Icon {
                        visible: bar.btOn
                        text: bar.btConnected > 0 ? "󰂱" : "󰂯"
                        color: status.fg; size: 14
                    }
                    Row {
                        spacing: 5
                        Icon {
                            text: bar.muted ? "󰝟" : bar.vol < 0.34 ? "󰕿" : bar.vol < 0.67 ? "󰖀" : "󰕾"
                            color: status.fg; size: 14
                        }
                        StyledText {
                            visible: !bar.muted
                            text: Math.round(bar.vol * 100)
                            color: status.fg; font.pixelSize: 10; font.family: Theme.displayFont
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    Row {
                        id: batRow
                        visible: bar.hasBattery
                        spacing: 5
                        readonly property color c: !bar.charging && bar.batPct <= 0.15 ? Theme.error : status.fg
                        Icon {
                            text: bar.charging ? "󰂄" : ["󰂎", "󰁻", "󰁽", "󰁿", "󰂁", "󰁹"][Math.min(5, Math.floor(bar.batPct * 6))]
                            color: batRow.c; size: 14
                        }
                        StyledText {
                            text: Math.round(bar.batPct * 100)
                            color: batRow.c; font.pixelSize: 10; font.family: Theme.displayFont
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    // unread notifications: a small spice diamond with the count
                    Item {
                        visible: Notifs.count > 0 || Notifs.dnd
                        anchors.verticalCenter: parent.verticalCenter
                        width: Notifs.dnd ? 14 : nRow.implicitWidth; height: 16
                        Icon { visible: Notifs.dnd; anchors.centerIn: parent; text: "󰂛"; size: 14; color: status.fg }
                        Row {
                            id: nRow
                            visible: !Notifs.dnd
                            anchors.centerIn: parent
                            spacing: 5
                            Rectangle { width: 5; height: 5; rotation: 45; color: Theme.spice; anchors.verticalCenter: parent.verticalCenter }
                            StyledText {
                                text: Notifs.count
                                color: Theme.spice; font.pixelSize: 10; font.family: Theme.displayFont
                            }
                        }
                    }
                }
                StateLayer {
                    tint: status.fg
                    onClicked: m => {
                        if (m.button === Qt.MiddleButton && bar.sink?.audio) bar.sink.audio.muted = !bar.sink.audio.muted;
                        else bar.togglePanel();
                    }
                    onWheel: w => {
                        if (!bar.sink?.audio) return;
                        bar.sink.audio.volume = Math.max(0, Math.min(1, bar.sink.audio.volume + (w.angleDelta.y > 0 ? 0.05 : -0.05)));
                    }
                }
            }
        }
    }
}
