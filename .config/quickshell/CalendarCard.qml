import Quickshell
import QtQuick
import QtQuick.Layouts

// Month calendar, Monday first. Scroll or arrows to change month.
Card {
    id: cal
    property date today: new Date()
    property int offset: 0
    readonly property date shown: new Date(today.getFullYear(), today.getMonth() + offset, 1)

    implicitHeight: col.implicitHeight + 24

    SystemClock { id: clock; precision: SystemClock.Hours; onDateChanged: cal.today = clock.date }

    readonly property var cells: {
        const y = shown.getFullYear(), m = shown.getMonth();
        const lead = (new Date(y, m, 1).getDay() + 6) % 7;
        const days = new Date(y, m + 1, 0).getDate();
        const out = [];
        for (let i = 0; i < 42; i++) {
            const d = new Date(y, m, i - lead + 1);
            out.push({ day: d.getDate(), inMonth: d.getMonth() === m,
                       isToday: d.toDateString() === today.toDateString(),
                       weekend: d.getDay() === 0 || d.getDay() === 6 });
        }
        // drop trailing week if fully outside the month
        return out.slice(0, Math.ceil((lead + days) / 7) * 7);
    }

    MouseArea {
        anchors.fill: parent
        onWheel: w => cal.offset += w.angleDelta.y > 0 ? -1 : 1
    }

    ColumnLayout {
        id: col
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            StyledText {
                Layout.fillWidth: true
                Layout.leftMargin: 6
                text: Qt.formatDate(cal.shown, "MMMM yyyy")
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }
            IconButton { visible: cal.offset !== 0; icon: "󰃭"; iconSize: 15; implicitWidth: 30; implicitHeight: 30; onClicked: cal.offset = 0 }
            IconButton { icon: "󰅁"; iconSize: 16; implicitWidth: 30; implicitHeight: 30; onClicked: cal.offset-- }
            IconButton { icon: "󰅂"; iconSize: 16; implicitWidth: 30; implicitHeight: 30; onClicked: cal.offset++ }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 7
            rowSpacing: 2
            columnSpacing: 2

            Repeater {
                model: ["M", "T", "W", "T", "F", "S", "S"]
                delegate: StyledText {
                    required property string modelData
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    color: Theme.fgSurfaceVariant
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                }
            }
            Repeater {
                model: cal.cells
                delegate: Item {
                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: 32
                    Rectangle {
                        anchors.centerIn: parent
                        width: 32; height: 32; radius: Theme.radiusS
                        color: modelData.isToday ? Theme.primary : "transparent"
                    }
                    StyledText {
                        anchors.centerIn: parent
                        text: modelData.day
                        font.pixelSize: 12
                        font.weight: modelData.isToday ? Font.Bold : Font.Normal
                        color: modelData.isToday ? Theme.fgPrimary
                             : !modelData.inMonth ? Theme.alpha(Theme.fgSurfaceVariant, 0.4)
                             : modelData.weekend ? Theme.tertiary : Theme.fgSurface
                    }
                }
            }
        }
    }
}
