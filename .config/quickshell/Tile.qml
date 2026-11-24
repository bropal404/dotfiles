import QtQuick
import QtQuick.Layouts

// Quick-settings tile: toggles on click; optional chevron opens details.
Rectangle {
    id: tile
    property string icon
    property string label
    property string sublabel: ""
    property bool active: false
    property bool expandable: false
    property bool expanded: false
    signal toggled()
    signal expand()

    readonly property color fg: active ? Theme.fgPrimary : Theme.fgSurface
    readonly property color fgVariant: active ? Theme.alpha(Theme.fgPrimary, 0.8) : Theme.fgSurfaceVariant

    implicitHeight: 64
    implicitWidth: 176
    radius: active ? Theme.radiusL : Theme.radiusXL
    color: active ? Theme.primary : Theme.surfaceContainerHighest
    border.width: 1
    border.color: active ? Theme.alpha(Theme.primary, 0.6) : Theme.alpha(Theme.outlineVariant, 0.5)

    Behavior on color  { ColorAnimation { duration: Theme.durMedium } }
    Behavior on radius { NumberAnimation { duration: Theme.durMedium; easing.type: Easing.OutCubic } }

    MouseArea {
        id: clickArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: tile.toggled()

        Rectangle {
            anchors.fill: parent
            radius: tile.radius
            color: tile.fg
            opacity: clickArea.pressed ? 0.12 : clickArea.containsMouse ? 0.08 : 0
            Behavior on opacity { NumberAnimation { duration: Theme.durShort } }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: tile.expandable ? 6 : 12
        spacing: 10

        Icon {
            text: tile.icon
            size: 22
            color: tile.fg
            Layout.preferredWidth: 26
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            clip: true

            StyledText {
                Layout.fillWidth: true
                text: tile.label
                color: tile.fg
                font.pixelSize: 13
                font.weight: Font.DemiBold
            }
            StyledText {
                Layout.fillWidth: true
                visible: text !== ""
                text: tile.sublabel
                color: tile.fgVariant
                font.pixelSize: 11
            }
        }

        // Dedicated chevron button for expanding subpages
        Rectangle {
            visible: tile.expandable
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            radius: Theme.radiusS
            color: chevronArea.containsMouse ? Theme.alpha(tile.fg, 0.16) : "transparent"
            z: 2

            Icon {
                anchors.centerIn: parent
                text: "󰅂"
                size: 16
                color: tile.fg
            }

            MouseArea {
                id: chevronArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: tile.expand()
            }
        }
    }
}
