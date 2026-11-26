import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts

// One notification: icon/image, app + time, summary, body, actions, dismiss.
Rectangle {
    id: root
    required property var notif
    property bool popup: false
    signal closed()

    readonly property bool critical: notif?.urgency === NotificationUrgency.Critical
    readonly property date received: Notifs.times[notif?.id] ?? new Date()

    implicitHeight: content.implicitHeight + 24
    radius: Theme.radiusL
    color: popup ? Theme.alpha(critical ? Theme.errorContainer : Theme.surfaceContainerHigh, 0.76) : critical ? Theme.errorContainer : Theme.surfaceContainerHighest
    border.width: popup ? 1 : 0
    border.color: Theme.alpha(Theme.outlineVariant, 0.6)

    // spice edge
    Rectangle {
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
        width: 2
        color: root.critical ? Theme.error : Theme.spice
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        onClicked: m => {
            if (m.button === Qt.MiddleButton) { root.notif.dismiss(); return; }
            const def = root.notif.actions.find(a => a.identifier === "default");
            if (def) def.invoke();
            root.closed();
        }
    }

    RowLayout {
        id: content
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
        spacing: 12

        Rectangle {
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: Theme.radiusS
            color: Theme.secondaryContainer
            clip: true
            Image {
                id: img
                anchors.fill: parent
                visible: status === Image.Ready
                source: root.notif?.image ?? ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }
            IconImage {
                id: appIcon
                anchors.centerIn: parent
                visible: !img.visible && source != ""
                implicitSize: 24
                source: root.notif?.appIcon ? Quickshell.iconPath(root.notif.appIcon, true) : ""
            }
            Icon {
                anchors.centerIn: parent
                visible: !img.visible && !appIcon.visible
                text: root.critical ? "󰀦" : "󰂚"
                color: Theme.fgSecondaryContainer
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                StyledText {
                    Layout.fillWidth: true
                    text: root.notif?.appName || "Notification"
                    caps: true
                    color: root.critical ? Theme.fgErrorContainer : Theme.spice
                    font.family: Theme.displayFont
                    font.pixelSize: 9
                    font.weight: Font.Normal
                }
                StyledText {
                    text: Qt.formatTime(root.received, "HH:mm")
                    color: Theme.fgSurfaceVariant
                    font.pixelSize: 11
                }
                IconButton {
                    icon: "󰅖"; iconSize: 14
                    implicitWidth: 24; implicitHeight: 24
                    onClicked: root.notif.dismiss()
                }
            }
            StyledText {
                Layout.fillWidth: true
                text: root.notif?.summary ?? ""
                color: root.critical ? Theme.fgErrorContainer : Theme.fgSurface
                font.pixelSize: 13
                font.weight: Font.DemiBold
                wrapMode: Text.Wrap
                maximumLineCount: 2
            }
            StyledText {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.notif?.body ?? ""
                textFormat: Text.StyledText
                color: root.critical ? Theme.fgErrorContainer : Theme.fgSurfaceVariant
                font.pixelSize: 12
                wrapMode: Text.Wrap
                maximumLineCount: root.popup ? 3 : 5
            }
            Flow {
                Layout.fillWidth: true
                Layout.topMargin: 6
                spacing: 6
                visible: actionsRep.count > 0
                Repeater {
                    id: actionsRep
                    model: (root.notif?.actions ?? []).filter(a => a.identifier !== "default")
                    delegate: Rectangle {
                        required property var modelData
                        implicitWidth: aLabel.implicitWidth + 24
                        implicitHeight: 30
                        radius: Theme.radiusS
                        color: Theme.secondaryContainer
                        StyledText {
                            id: aLabel
                            anchors.centerIn: parent
                            text: modelData.text
                            color: Theme.fgSecondaryContainer
                            font.pixelSize: 12
                            font.weight: Font.Medium
                        }
                        StateLayer { tint: Theme.fgSecondaryContainer; onClicked: { modelData.invoke(); root.closed(); } }
                    }
                }
            }
        }
    }
}
