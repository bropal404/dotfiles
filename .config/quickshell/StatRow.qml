import QtQuick
import QtQuick.Layouts

// Icon + label + value with a thin progress track underneath.
ColumnLayout {
    id: r
    property string icon
    property string label
    property string detail
    property real value: 0
    property color accent: value > 0.85 ? Theme.error : Theme.primary
    implicitWidth: 340
    Layout.fillWidth: true
    spacing: 6

    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        Icon { text: r.icon; size: 16; color: Theme.fgSurfaceVariant; Layout.preferredWidth: 20 }
        StyledText { text: r.label; font.pixelSize: 12; font.weight: Font.DemiBold; color: Theme.fgSurface; Layout.fillWidth: true }
        StyledText { text: r.detail; font.pixelSize: 11; color: Theme.fgSurfaceVariant }
    }
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 6
        radius: 3
        color: Theme.surfaceContainerHighest
        clip: true
        Rectangle {
            height: parent.height
            radius: 3
            width: Math.max(height, parent.width * Math.max(0, Math.min(1, r.value)))
            color: r.accent
            Behavior on width { NumberAnimation { duration: Theme.durLong; easing.type: Easing.OutCubic } }
        }
    }
}
