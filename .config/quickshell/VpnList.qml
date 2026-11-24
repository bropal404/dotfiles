import QtQuick
import QtQuick.Layouts

// NetworkManager VPN / WireGuard connections.
ColumnLayout {
    spacing: 4

    StyledText {
        Layout.leftMargin: 8
        text: "VPN connections"
        color: Theme.fgSurfaceVariant
        font.pixelSize: 12
        font.weight: Font.DemiBold
    }
    StyledText {
        visible: Net.vpns.length === 0
        Layout.leftMargin: 8
        text: "No VPN connections configured in NetworkManager"
        color: Theme.fgSurfaceVariant
    }
    Repeater {
        model: Net.vpns
        delegate: Rectangle {
            id: v
            required property var modelData
            readonly property color fg: modelData.active ? Theme.fgSecondaryContainer : Theme.fgSurface
            Layout.fillWidth: true
            implicitHeight: 44
            radius: Theme.radiusM
            color: modelData.active ? Theme.secondaryContainer : "transparent"
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 12
                Icon { text: v.modelData.active ? "󰦝" : "󰦞"; color: v.fg }
                StyledText { Layout.fillWidth: true; text: v.modelData.name; color: v.fg }
                StyledText {
                    text: v.modelData.active ? "Connected" : v.modelData.type === "wireguard" ? "WireGuard" : "VPN"
                    color: Theme.fgSurfaceVariant
                    font.pixelSize: 11
                }
            }
            StateLayer { radius: parent.radius; onClicked: Net.toggleVpn(v.modelData) }
        }
    }
}
