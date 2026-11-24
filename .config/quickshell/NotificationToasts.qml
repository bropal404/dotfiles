import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: toasts
    required property var modelData
    screen: modelData

    visible: Notifs.popups.length > 0
    color: "transparent"
    anchors { top: true; right: true }
    margins { top: Theme.gap + 8; right: Theme.gap + 8 }
    implicitWidth: 380
    implicitHeight: Math.min(640, contentCol.implicitHeight + 10)
    exclusiveZone: 0

    WlrLayershell.namespace: "qs-notifications"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    ColumnLayout {
        id: contentCol
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 8

        Repeater {
            model: Notifs.popups
            delegate: Item {
                id: wrapper
                required property var modelData
                Layout.fillWidth: true
                implicitHeight: item.implicitHeight

                NotificationItem {
                    id: item
                    anchors.fill: parent
                    notif: wrapper.modelData
                    popup: true
                    onClosed: Notifs.dismissPopup(wrapper.modelData)
                }

                // Auto dismiss timer (6s for standard, 10s for low, none for critical)
                Timer {
                    interval: wrapper.modelData.urgency === 0 ? 4000 : 7000
                    running: !hoverWatcher.containsMouse && wrapper.modelData.urgency !== 2
                    repeat: false
                    onTriggered: Notifs.dismissPopup(wrapper.modelData)
                }

                MouseArea {
                    id: hoverWatcher
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                }
            }
        }
    }
}
