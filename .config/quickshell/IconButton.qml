import QtQuick

// Round icon button. `filled` → tonal container.
Rectangle {
    id: btn
    property string icon
    property int iconSize: 18
    property bool filled: false
    property color fg: filled ? Theme.fgSecondaryContainer : Theme.fgSurfaceVariant
    property alias tooltip: btn.toolTipText
    property string toolTipText: ""
    signal clicked(var mouse)

    implicitWidth: 36
    implicitHeight: 36
    radius: Theme.radiusPill
    color: filled ? Theme.secondaryContainer : "transparent"

    Icon { anchors.centerIn: parent; text: btn.icon; size: btn.iconSize; color: btn.fg }
    StateLayer { tint: btn.fg; onClicked: m => btn.clicked(m) }
}
