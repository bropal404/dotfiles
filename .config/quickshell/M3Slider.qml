import QtQuick
import QtQuick.Layouts

// Material 3 expressive slider: thick track with icon on the left and live percentage.
Item {
    id: s
    property real value: 0                 // 0..1
    property string icon
    property bool muted: false
    property bool showValue: true
    signal moved(real v)
    signal iconClicked()

    implicitHeight: 48
    implicitWidth: 360
    Layout.fillWidth: true

    readonly property real shown: drag.pressed ? drag.live : Math.max(0, Math.min(1, value))
    readonly property color accent: muted ? Theme.outline : Theme.primary

    Rectangle {
        id: track
        anchors.fill: parent
        radius: Theme.radiusPill
        color: Theme.surfaceContainerHighest
        border.width: 1
        border.color: Theme.alpha(Theme.outlineVariant, 0.4)
        clip: true

        // Active filled progress track
        Rectangle {
            id: fill
            height: parent.height
            width: Math.max(parent.height, parent.width * s.shown)
            radius: parent.radius
            color: s.accent
            Behavior on width { enabled: !drag.pressed; NumberAnimation { duration: Theme.durShort } }
            Behavior on color { ColorAnimation { duration: Theme.durMedium } }
        }

        // Left Icon Pill
        Rectangle {
            width: parent.height
            height: parent.height
            radius: Theme.radiusPill
            color: "transparent"
            z: 2

            Icon {
                anchors.centerIn: parent
                text: s.icon
                size: 20
                color: Theme.fgSurface
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: s.iconClicked()
            }
        }

        // Value text on right
        StyledText {
            visible: s.showValue
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            text: Math.round(s.shown * 100) + "%"
            color: Theme.fgSurface
            font.pixelSize: 12
            font.weight: Font.Bold
            z: 2
        }

        // Full width interactive slider drag
        MouseArea {
            id: drag
            property real live: 0
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            function at(x) { return Math.max(0, Math.min(1, x / track.width)); }
            onPressed: m => { live = at(m.x); s.moved(live); }
            onPositionChanged: m => { if (pressed) { live = at(m.x); s.moved(live); } }
            onWheel: w => s.moved(Math.max(0, Math.min(1, s.value + (w.angleDelta.y > 0 ? 0.05 : -0.05))))
        }
    }
}
