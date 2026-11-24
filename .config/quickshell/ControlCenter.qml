import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

PanelWindow {
    id: panel
    required property var bar

    visible: false
    color: "transparent"
    anchors { right: true; bottom: true }
    margins { right: Theme.gap + 2; bottom: Theme.barHeight + Theme.gap * 2 }
    implicitWidth: 420
    implicitHeight: Math.min(680, (screen?.height ?? 1080) - Theme.barHeight - Theme.gap * 4)
    exclusiveZone: 0

    WlrLayershell.namespace: "qs-control-center"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    HyprlandFocusGrab {
        windows: [panel, panel.bar]
        active: panel.visible
        onCleared: panel.visible = false
    }


    property string page: "main" // "main", "wifi", "bt", "vpn", "notifs"

    onVisibleChanged: {
        SysStats.active = visible;
        if (visible) PowerMode.refresh();
        if (!visible) page = "main";
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: panel.visible = false
        radius: Theme.radiusXL
        color: Theme.alpha(Theme.surfaceContainer, 0.94)
        border.width: 1
        border.color: Theme.alpha(Theme.outlineVariant, 0.5)
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            // ── Header Bar ──
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                // Back button if in subpage
                IconButton {
                    visible: panel.page !== "main"
                    icon: "󰁍"
                    iconSize: 18
                    implicitWidth: 36
                    implicitHeight: 36
                    onClicked: panel.page = "main"
                }

                // Title or User Greeting
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    StyledText {
                        text: panel.page === "wifi" ? "Wi-Fi Networks"
                            : panel.page === "bt" ? "Bluetooth Devices"
                            : panel.page === "vpn" ? "VPN Connections"
                            : panel.page === "notifs" ? "Notifications"
                            : "Quick Settings"
                        caps: true
                        font.family: Theme.displayFont
                        font.pixelSize: 13
                        font.weight: Font.Normal
                        color: Theme.fgSurface
                    }
                    StyledText {
                        text: panel.page === "main" ? ("Uptime: " + SysStats.uptime) : "Back to quick settings"
                        font.pixelSize: 11
                        color: Theme.fgSurfaceVariant
                    }
                }

                // Power & Lock Actions (main page only)
                Row {
                    visible: panel.page === "main"
                    spacing: 6
                    IconButton {
                        icon: "󰌾"
                        iconSize: 16
                        tooltip: "Lock Screen"
                        onClicked: { panel.visible = false; Quickshell.execDetached(["/home/gopal/.config/hypr/scripts/lock"]); }
                    }
                    IconButton {
                        icon: "󰤆"
                        iconSize: 16
                        tooltip: "Power Menu"
                        onClicked: { panel.visible = false; Quickshell.execDetached(["qs", "ipc", "call", "power", "toggle"]); }
                    }
                }
            }

            // ── Main Page Content ──
            Flickable {
                visible: panel.page === "main"
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: width
                contentHeight: mainCol.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                ColumnLayout {
                    id: mainCol
                    width: parent.width
                    spacing: 14

                    // ── 2x2 Quick Setting Tiles ──
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        // Wi-Fi Tile
                        Tile {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 187
                            icon: Net.icon
                            label: Net.ssid !== "" ? Net.ssid : "Wi-Fi"
                            sublabel: !Net.wifiEnabled ? "Off" : Net.ssid !== "" ? (Net.signal + "%") : "Disconnected"
                            active: Net.wifiEnabled
                            expandable: true
                            onToggled: Net.setWifi(!Net.wifiEnabled)
                            onExpand: panel.page = "wifi"
                        }

                        // Bluetooth Tile
                        Tile {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 187
                            icon: panel.bar.btOn ? (panel.bar.btConnected > 0 ? "󰂱" : "󰂯") : "󰂲"
                            label: "Bluetooth"
                            sublabel: !panel.bar.btOn ? "Off" : panel.bar.btConnected > 0 ? (panel.bar.btConnected + " connected") : "On"
                            active: panel.bar.btOn
                            expandable: true
                            onToggled: {
                                if (Bluetooth.defaultAdapter)
                                    Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled;
                            }
                            onExpand: panel.page = "bt"
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        // VPN Tile
                        Tile {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 187
                            icon: Net.vpnActive ? "󰦝" : "󰦞"
                            label: "VPN"
                            sublabel: Net.vpnActive ? (Net.vpns.find(v => v.active)?.name ?? "Active") : (Net.vpns.length > 0 ? "Off" : "None")
                            active: Net.vpnActive
                            expandable: true
                            onToggled: {
                                if (Net.vpns.length > 0) {
                                    const activeVpn = Net.vpns.find(v => v.active);
                                    Net.toggleVpn(activeVpn ?? Net.vpns[0]);
                                } else {
                                    panel.page = "vpn";
                                }
                            }
                            onExpand: panel.page = "vpn"
                        }

                        // Notifications / DND Tile
                        Tile {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 187
                            icon: Notifs.dnd ? "󰂛" : "󰂚"
                            label: "Do Not Disturb"
                            sublabel: Notifs.dnd ? "On (Muted)" : (Notifs.count > 0 ? (Notifs.count + " unread") : "Off")
                            active: Notifs.dnd
                            expandable: true
                            onToggled: Notifs.dnd = !Notifs.dnd
                            onExpand: panel.page = "notifs"
                        }
                    }

                    // ── Power: live draw + estimate, and the manual power-saver switch ──
                    RowLayout {
                        id: powerRow
                        Layout.fillWidth: true
                        spacing: 10

                        readonly property var dev: panel.bar.battery
                        readonly property real watts: dev?.changeRate ?? 0
                        readonly property real secs: panel.bar.charging ? (dev?.timeToFull ?? 0) : (dev?.timeToEmpty ?? 0)
                        function fmt(s) {
                            if (!s || s <= 0) return "";
                            const h = Math.floor(s / 3600), m = Math.round((s % 3600) / 60);
                            return h > 0 ? (h + "h " + m + "m") : (m + "m");
                        }

                        // Power-saver mode: Auto (follows charger) → On → Off
                        Tile {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 187
                            icon: PowerMode.override === "performance" ? "󱐋" : PowerMode.saving ? "󰌪" : "󰓅"
                            label: "Power Saver"
                            sublabel: PowerMode.override === "auto" ? ("Auto · " + (PowerMode.saving ? "saving" : "full power"))
                                    : PowerMode.override === "saver" ? "On · manual" : "Off · manual"
                            active: PowerMode.saving
                            onToggled: PowerMode.cycle()
                        }

                        // Battery draw + time estimate
                        Tile {
                            visible: panel.bar.hasBattery
                            Layout.fillWidth: true
                            Layout.preferredWidth: 187
                            icon: panel.bar.charging ? "󰂄" : "󰁹"
                            label: (powerRow.watts > 0 ? powerRow.watts.toFixed(1) : "—") + " W"
                            sublabel: {
                                const t = powerRow.fmt(powerRow.secs);
                                const pct = Math.round(panel.bar.batPct * 100) + "%";
                                return panel.bar.charging ? (t ? (t + " to full · " + pct) : ("Charging · " + pct))
                                                          : (t ? (t + " left · " + pct) : ("On battery · " + pct));
                            }
                            active: false
                            onToggled: {}
                        }
                    }

                    // ── Sliders: Volume & Brightness ──
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        // Volume Slider
                        M3Slider {
                            Layout.fillWidth: true
                            value: panel.bar.vol
                            muted: panel.bar.muted
                            icon: panel.bar.muted ? "󰝟" : panel.bar.vol < 0.34 ? "󰕿" : panel.bar.vol < 0.67 ? "󰖀" : "󰕾"
                            onMoved: v => {
                                if (panel.bar.sink?.audio) {
                                    panel.bar.sink.audio.volume = v;
                                    panel.bar.sink.audio.muted = false;
                                }
                            }
                            onIconClicked: {
                                if (panel.bar.sink?.audio)
                                    panel.bar.sink.audio.muted = !panel.bar.sink.audio.muted;
                            }
                        }

                        // Brightness Slider
                        M3Slider {
                            Layout.fillWidth: true
                            value: Brightness.value
                            icon: Brightness.value > 0.6 ? "󰃠" : Brightness.value > 0.25 ? "󰃟" : "󰃞"
                            onMoved: v => Brightness.set(v)
                            onIconClicked: Brightness.set(Brightness.value > 0.5 ? 0.2 : 0.8)
                        }
                    }

                    // ── Media Card (when active) ──
                    MediaCard {
                        Layout.fillWidth: true
                    }

                    // ── System Resource Telemetry ──
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: statsCol.implicitHeight + 24
                        radius: Theme.radiusL
                        color: Theme.surfaceContainerHigh
                        border.width: 1
                        border.color: Theme.alpha(Theme.outlineVariant, 0.4)

                        ColumnLayout {
                            id: statsCol
                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 14 }
                            spacing: 12

                            StatRow {
                                Layout.fillWidth: true
                                icon: "󰍛"
                                label: "CPU Usage"
                                detail: Math.round(SysStats.cpu * 100) + "%"
                                value: SysStats.cpu
                            }

                            StatRow {
                                Layout.fillWidth: true
                                icon: "󰘚"
                                label: "Memory"
                                detail: SysStats.memUsedGb.toFixed(1) + " / " + SysStats.memTotalGb.toFixed(1) + " GB (" + Math.round(SysStats.mem * 100) + "%)"
                                value: SysStats.mem
                            }

                            StatRow {
                                Layout.fillWidth: true
                                icon: "󰋊"
                                label: "Disk /"
                                detail: SysStats.diskLabel
                                value: SysStats.disk
                            }
                        }
                    }

                    // ── Mini Notification Preview (if unread) ──
                    Rectangle {
                        visible: Notifs.count > 0
                        Layout.fillWidth: true
                        implicitHeight: notifPrevCol.implicitHeight + 24
                        radius: Theme.radiusL
                        color: Theme.surfaceContainerHigh
                        border.width: 1
                        border.color: Theme.alpha(Theme.outlineVariant, 0.4)

                        ColumnLayout {
                            id: notifPrevCol
                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 14 }
                            spacing: 10

                            RowLayout {
                                Layout.fillWidth: true
                                StyledText {
                                    text: "Recent Notifications (" + Notifs.count + ")"
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                    color: Theme.fgSurface
                                    Layout.fillWidth: true
                                }
                                StyledText {
                                    text: "View all"
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                    color: Theme.primary
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: panel.page = "notifs"
                                    }
                                }
                            }

                            Repeater {
                                model: Notifs.list.slice(0, 2)
                                delegate: NotificationItem {
                                    required property var modelData
                                    notif: modelData
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }

            // ── Subpages (Wi-Fi, Bluetooth, VPN, Notifications) ──
            Flickable {
                visible: panel.page !== "main"
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: width
                contentHeight: subCol.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                ColumnLayout {
                    id: subCol
                    width: parent.width
                    spacing: 10

                    WifiList {
                        visible: panel.page === "wifi"
                        Layout.fillWidth: true
                    }

                    BtList {
                        visible: panel.page === "bt"
                        Layout.fillWidth: true
                    }

                    VpnList {
                        visible: panel.page === "vpn"
                        Layout.fillWidth: true
                    }

                    ColumnLayout {
                        visible: panel.page === "notifs"
                        Layout.fillWidth: true
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            StyledText {
                                text: Notifs.count + " notifications"
                                color: Theme.fgSurfaceVariant
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                Layout.fillWidth: true
                            }
                            IconButton {
                                visible: Notifs.count > 0
                                icon: "󰆴"
                                tooltip: "Clear all"
                                onClicked: Notifs.clearAll()
                            }
                        }

                        StyledText {
                            visible: Notifs.count === 0
                            text: "No notifications"
                            color: Theme.fgSurfaceVariant
                            font.pixelSize: 13
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: 40
                        }

                        Repeater {
                            model: Notifs.list
                            delegate: NotificationItem {
                                required property var modelData
                                notif: modelData
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }
    }
}
