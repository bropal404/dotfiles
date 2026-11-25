import Quickshell
import QtQuick
import QtQuick.Layouts

// Wi-Fi network list with inline password entry for new secured networks.
ColumnLayout {
    id: root
    spacing: 4
    property string pwFor: ""

    Component.onCompleted: if (Net.wifiEnabled) Net.scan()

    // after switching Wi-Fi on, give the radio a moment, then list networks
    Connections { target: Net; function onWifiEnabledChanged() { if (Net.wifiEnabled) rescan.restart(); } }
    Timer { id: rescan; interval: 1500; onTriggered: Net.scan() }

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 8
        StyledText {
            Layout.fillWidth: true
            text: !Net.wifiEnabled ? "Wi-Fi" : Net.scanning ? "Scanning…" : "Wi-Fi networks"
            color: Theme.fgSurfaceVariant
            font.pixelSize: 12
            font.weight: Font.DemiBold
        }
        IconButton { visible: Net.wifiEnabled; icon: "󰑐"; iconSize: 16; implicitWidth: 30; implicitHeight: 30; onClicked: Net.scan() }
        Toggle { checked: Net.wifiEnabled; Layout.rightMargin: 4; onToggled: Net.setWifi(!Net.wifiEnabled) }
    }

    StyledText {
        visible: Net.lastError !== ""
        Layout.fillWidth: true
        Layout.leftMargin: 8
        text: Net.lastError
        color: Theme.error
        font.pixelSize: 12
        wrapMode: Text.Wrap
    }

    StyledText {
        visible: !Net.wifiEnabled
        Layout.leftMargin: 8
        text: "Wi-Fi is off"
        color: Theme.fgSurfaceVariant
    }

    Repeater {
        model: Net.wifiEnabled ? Net.networks.slice(0, 10) : []
        delegate: ColumnLayout {
            id: item
            required property var modelData
            Layout.fillWidth: true
            spacing: 4

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 44
                radius: Theme.radiusM
                color: item.modelData.active ? Theme.secondaryContainer : "transparent"
                readonly property color fg: item.modelData.active ? Theme.fgSecondaryContainer : Theme.fgSurface

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 12
                    Icon {
                        readonly property int s: item.modelData.signal
                        text: s > 75 ? "󰤨" : s > 50 ? "󰤥" : s > 25 ? "󰤢" : "󰤟"
                        color: parent.parent.fg
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        StyledText {
                            Layout.fillWidth: true
                            text: item.modelData.ssid
                            color: parent.parent.parent.fg
                            font.weight: item.modelData.active ? Font.DemiBold : Font.Normal
                        }
                        StyledText {
                            visible: text !== ""
                            text: Net.connecting === item.modelData.ssid ? "Connecting…"
                                : item.modelData.active ? "Connected"
                                : item.modelData.known ? "Saved" : ""
                            color: Theme.fgSurfaceVariant
                            font.pixelSize: 11
                        }
                    }
                    Icon { visible: item.modelData.secure; text: "󰌾"; size: 14; color: Theme.fgSurfaceVariant }
                }
                StateLayer {
                    radius: parent.radius
                    onClicked: {
                        const n = item.modelData;
                        if (n.active) Net.disconnect();
                        else if (n.secure && !n.known) root.pwFor = root.pwFor === n.ssid ? "" : n.ssid;
                        else Net.connect(n);
                    }
                }
            }

            // password row
            Rectangle {
                visible: root.pwFor === item.modelData.ssid
                Layout.fillWidth: true
                implicitHeight: 44
                radius: Theme.radiusPill
                color: Theme.surfaceContainerHighest
                border.width: 2
                border.color: Theme.primary
                onVisibleChanged: if (visible) pw.forceActiveFocus()

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 4
                    TextInput {
                        id: pw
                        Layout.fillWidth: true
                        echoMode: TextInput.Password
                        font.family: Theme.font
                        font.pixelSize: 13
                        color: Theme.fgSurface
                        verticalAlignment: TextInput.AlignVCenter
                        onAccepted: go()
                        function go() { Net.connect(item.modelData, text); text = ""; root.pwFor = ""; }
                        StyledText {
                            anchors.fill: parent
                            visible: pw.text === ""
                            text: "Password"
                            color: Theme.fgSurfaceVariant
                        }
                    }
                    IconButton { icon: "󰄬"; filled: true; implicitWidth: 36; implicitHeight: 36; onClicked: pw.go() }
                }
            }
        }
    }
}
