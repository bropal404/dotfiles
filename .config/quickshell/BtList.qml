import Quickshell
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts

// Bluetooth devices: paired first, then discovered. Click to connect / disconnect / pair.
ColumnLayout {
    id: root
    spacing: 4
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var devices: Bluetooth.devices.values
        .filter(d => d.paired || (d.deviceName || "") !== "")
        .sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || a.name.localeCompare(b.name))

    Component.onDestruction: if (adapter?.discovering) adapter.discovering = false

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 8
        StyledText {
            Layout.fillWidth: true
            text: !(root.adapter?.enabled ?? false) ? "Bluetooth" : root.adapter?.discovering ? "Searching for devices…" : "Bluetooth devices"
            color: Theme.fgSurfaceVariant
            font.pixelSize: 12
            font.weight: Font.DemiBold
        }
        IconButton {
            visible: root.adapter?.enabled ?? false
            icon: root.adapter?.discovering ? "󰓛" : "󰑐"
            iconSize: 16; implicitWidth: 30; implicitHeight: 30
            onClicked: root.adapter.discovering = !root.adapter.discovering
        }
        Toggle {
            visible: root.adapter !== null
            checked: root.adapter?.enabled ?? false
            Layout.rightMargin: 4
            onToggled: {
                root.adapter.enabled = !root.adapter.enabled;
                Toast.state("󰂯", "Bluetooth", root.adapter.enabled);
            }
        }
    }

    StyledText {
        visible: !(root.adapter?.enabled ?? false)
        Layout.leftMargin: 8
        text: root.adapter ? "Bluetooth is off" : "No Bluetooth adapter"
        color: Theme.fgSurfaceVariant
    }

    Repeater {
        model: (root.adapter?.enabled ?? false) ? root.devices.slice(0, 10) : []
        delegate: Rectangle {
            id: dev
            required property var modelData
            readonly property var d: modelData
            readonly property color fg: d.connected ? Theme.fgSecondaryContainer : Theme.fgSurface
            Layout.fillWidth: true
            implicitHeight: 44
            radius: Theme.radiusM
            color: d.connected ? Theme.secondaryContainer : "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 12
                Icon {
                    readonly property string i: dev.d.icon || ""
                    text: i.includes("headset") || i.includes("headphone") ? "󰋋"
                        : i.includes("audio") ? "󰓃"
                        : i.includes("mouse") ? "󰍽"
                        : i.includes("keyboard") ? "󰌌"
                        : i.includes("phone") ? "󰄜"
                        : i.includes("computer") ? "󰟀"
                        : i.includes("game") ? "󰊴" : "󰂯"
                    color: dev.fg
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    StyledText { Layout.fillWidth: true; text: dev.d.name; color: dev.fg; font.weight: dev.d.connected ? Font.DemiBold : Font.Normal }
                    StyledText {
                        visible: text !== ""
                        text: dev.d.pairing ? "Pairing…"
                            : dev.d.state === BluetoothDeviceState.Connecting ? "Connecting…"
                            : dev.d.state === BluetoothDeviceState.Disconnecting ? "Disconnecting…"
                            : dev.d.connected ? "Connected" + (dev.d.batteryAvailable ? " · " + Math.round(dev.d.battery * 100) + "%" : "")
                            : dev.d.paired ? "Paired" : ""
                        color: Theme.fgSurfaceVariant
                        font.pixelSize: 11
                    }
                }
                IconButton {
                    visible: dev.d.paired && !dev.d.connected
                    icon: "󰆴"; iconSize: 15; implicitWidth: 30; implicitHeight: 30
                    onClicked: dev.d.forget()
                }
            }
            StateLayer {
                radius: parent.radius
                onClicked: {
                    if (dev.d.connected) dev.d.disconnect();
                    else if (dev.d.paired) dev.d.connect();
                    else { dev.d.trusted = true; dev.d.pair(); }
                }
            }
        }
    }
}
