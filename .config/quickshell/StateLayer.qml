import QtQuick

// M3 state layer: hover 8%, press 12% of the content colour, plus click handling.
MouseArea {
    id: root
    property color tint: Theme.fgSurface
    property real radius: parent?.radius ?? 0

    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: root.tint
        opacity: root.pressed ? 0.12 : root.containsMouse ? 0.08 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.durShort } }
    }
}
