import QtQuick

// M3-style switch. Emits toggled(); the owner flips its own state.
Rectangle {
    id: sw
    property bool checked: false
    signal toggled()

    implicitWidth: 44
    implicitHeight: 24
    radius: height / 2
    color: checked ? Theme.primary : Theme.surfaceContainerHighest
    border.width: 1
    border.color: checked ? Theme.primary : Theme.outline
    Behavior on color { ColorAnimation { duration: Theme.durShort } }

    Rectangle {
        width: sw.checked ? 18 : 14
        height: width
        radius: width / 2
        anchors.verticalCenter: parent.verticalCenter
        x: sw.checked ? parent.width - width - 4 : 5
        color: sw.checked ? Theme.fgPrimary : Theme.outline
        Behavior on x { NumberAnimation { duration: Theme.durShort; easing.type: Easing.OutCubic } }
        Behavior on width { NumberAnimation { duration: Theme.durShort } }
    }
    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: sw.toggled() }
}
