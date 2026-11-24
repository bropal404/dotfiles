import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

// App launcher: type-to-filter list, Enter runs the top hit (or the text as a command).
PanelWindow {
    id: menu
    required property var bar

    visible: false
    color: "transparent"
    anchors { left: true; bottom: true }
    margins { left: Theme.gap + 2; bottom: Theme.barHeight + Theme.gap * 2 }
    implicitWidth: 380
    implicitHeight: 540
    exclusiveZone: 0

    WlrLayershell.namespace: "qs-launcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    HyprlandFocusGrab {
        windows: [menu, menu.bar]
        active: menu.visible
        onCleared: menu.visible = false
    }

    property string query: ""
    property int current: 0

    readonly property var apps: {
        const q = query.trim().toLowerCase();
        return DesktopEntries.applications.values
            .filter(a => !a.noDisplay && (q === ""
                || a.name.toLowerCase().includes(q)
                || (a.genericName || "").toLowerCase().includes(q)
                || (a.keywords || []).some(k => k.toLowerCase().includes(q))))
            .sort((a, b) => {
                if (q !== "") {
                    const as = a.name.toLowerCase().startsWith(q), bs = b.name.toLowerCase().startsWith(q);
                    if (as !== bs) return as ? -1 : 1;
                }
                if (q !== "") {
                    const fa = AppUsage.scoreOf(a.id), fb = AppUsage.scoreOf(b.id);
                    if (fa !== fb) return fb - fa;
                }
                return a.name.localeCompare(b.name);
            });
    }

    readonly property var pinned: AppUsage.top(6)

    onVisibleChanged: if (visible) { input.text = ""; current = 0; input.forceActiveFocus(); }
    onCurrentChanged: list.positionViewAtIndex(current, ListView.Contain)

    function launch(app) { app.execute(); visible = false; }
    function runQuery() {
        if (apps.length > 0) launch(apps[Math.min(current, apps.length - 1)]);
        else if (query.trim() !== "") { Quickshell.execDetached(["sh", "-c", query]); visible = false; }
    }
    function sh(cmd) { Quickshell.execDetached(["sh", "-c", cmd]); visible = false; }

    Rectangle {
        id: body
        anchors.fill: parent
        radius: Theme.radiusXL
        color: Theme.surfaceContainer
        border.width: 1
        border.color: Theme.alpha(Theme.outlineVariant, 0.5)

        // open animation
        opacity: menu.visible ? 1 : 0
        transform: Translate { y: menu.visible ? 0 : 16; Behavior on y { NumberAnimation { duration: Theme.durMedium; easing.type: Easing.OutCubic } } }
        Behavior on opacity { NumberAnimation { duration: Theme.durShort } }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            // ── search bar ──
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 52
                radius: Theme.radiusPill
                color: Theme.surfaceContainerHighest

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18
                    spacing: 12
                    Icon { text: "󰍉"; size: 20; color: Theme.fgSurfaceVariant }
                    TextInput {
                        id: input
                        Layout.fillWidth: true
                        verticalAlignment: TextInput.AlignVCenter
                        font.family: Theme.font
                        font.pixelSize: 15
                        color: Theme.fgSurface
                        selectionColor: Theme.primary
                        selectedTextColor: Theme.fgPrimary
                        clip: true
                        onTextChanged: { menu.query = text; menu.current = 0; }
                        Keys.onPressed: event => {
                            const n = menu.apps.length;
                            if ((event.modifiers & Qt.AltModifier) && event.key >= Qt.Key_1 && event.key <= Qt.Key_6) {
                                const p = menu.pinned[event.key - Qt.Key_1];
                                if (p) menu.launch(p);
                                event.accepted = true;
                                return;
                            }
                            if (event.key === Qt.Key_Escape) menu.visible = false;
                            else if (event.key === Qt.Key_Down || (event.key === Qt.Key_Tab)) menu.current = Math.min(menu.current + 1, n - 1);
                            else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab) menu.current = Math.max(menu.current - 1, 0);
                            else if (event.key === Qt.Key_PageDown) menu.current = Math.min(menu.current + 8, n - 1);
                            else if (event.key === Qt.Key_PageUp) menu.current = Math.max(menu.current - 8, 0);
                            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) menu.runQuery();
                            else return;
                            event.accepted = true;
                        }
                        StyledText {
                            anchors.fill: parent
                            visible: input.text === ""
                            text: "Seek an app, or speak a command"
                            color: Theme.fgSurfaceVariant
                            font.pixelSize: 15
                        }
                    }
                }
            }

            // ── pinned: learned from what you open most (right-click to unpin) ──
            ColumnLayout {
                Layout.fillWidth: true
                visible: menu.query === "" && menu.pinned.length > 0
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 4
                    spacing: 10
                    StyledText {
                        text: "Frequent"
                        caps: true
                        font.family: Theme.displayFont
                        font.pixelSize: 9
                        color: Theme.spice
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: Theme.alpha(Theme.spice, 0.5) }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }
                }

                Row {
                    Layout.fillWidth: true
                    spacing: 0
                    Repeater {
                        model: menu.pinned
                        delegate: Item {
                            id: pin
                            required property var modelData
                            required property int index
                            width: (menu.width - 28) / 6
                            height: 74
                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 2
                                radius: Theme.radiusS
                                color: pinMouse.containsMouse ? Theme.alpha(Theme.spice, 0.14) : "transparent"
                                border.width: pinMouse.containsMouse ? 1 : 0
                                border.color: Theme.alpha(Theme.spice, 0.45)
                                Behavior on color { ColorAnimation { duration: Theme.durShort } }
                            }
                            Column {
                                anchors.centerIn: parent
                                spacing: 6
                                IconImage {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    implicitSize: 30
                                    source: Quickshell.iconPath(pin.modelData.icon, "application-x-executable")
                                }
                                StyledText {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: pin.width - 8
                                    horizontalAlignment: Text.AlignHCenter
                                    text: pin.modelData.name
                                    font.pixelSize: 10
                                    color: pinMouse.containsMouse ? Theme.flare : Theme.fgSurfaceVariant
                                }
                            }
                            // Alt+N hint
                            StyledText {
                                anchors { top: parent.top; right: parent.right; topMargin: 4; rightMargin: 6 }
                                text: pin.index + 1
                                font.family: Theme.displayFont
                                font.pixelSize: 8
                                color: Theme.alpha(Theme.sand, 0.3)
                            }
                            MouseArea {
                                id: pinMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: m => m.button === Qt.RightButton ? AppUsage.forget(pin.modelData.id) : menu.launch(pin.modelData)
                            }
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.alpha(Theme.sand, 0.08) }
            }

            // ── apps ──
            ListView {
                id: list
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 2
                model: menu.apps
                boundsBehavior: Flickable.StopAtBounds
                highlightMoveDuration: Theme.durShort
                currentIndex: menu.current
                highlight: Rectangle {
                    radius: Theme.radiusS
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: Theme.alpha(Theme.spice, 0.28) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                    Rectangle { width: 2; height: parent.height; color: Theme.spice }
                }

                delegate: Item {
                    id: row
                    required property var modelData
                    required property int index
                    readonly property bool sel: index === menu.current
                    width: ListView.view.width
                    height: 48
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 14
                        IconImage {
                            implicitSize: 28
                            source: Quickshell.iconPath(row.modelData.icon, "application-x-executable")
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            StyledText {
                                Layout.fillWidth: true
                                text: row.modelData.name
                                color: row.sel ? Theme.flare : Theme.fgSurface
                                font.pixelSize: 14
                                font.weight: Font.Medium
                            }
                            StyledText {
                                Layout.fillWidth: true
                                visible: text !== ""
                                text: row.modelData.genericName || row.modelData.comment || ""
                                color: row.sel ? Theme.alpha(Theme.sand, 0.8) : Theme.fgSurfaceVariant
                                font.pixelSize: 11
                            }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: menu.current = row.index
                        onClicked: menu.launch(row.modelData)
                    }
                }

                StyledText {
                    anchors.centerIn: parent
                    visible: menu.apps.length === 0 && menu.query.trim() !== ""
                    text: "Press Enter to run “" + menu.query.trim() + "”"
                    color: Theme.fgSurfaceVariant
                }
            }

            // ── session row ──
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                StyledText {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    text: Quickshell.env("USER")
                    caps: true
                    font.family: Theme.displayFont
                    font.pixelSize: 10
                    color: Theme.fgSurfaceVariant
                }
                IconButton { icon: "󰒓"; onClicked: menu.sh("pavucontrol") }
                IconButton { icon: "󰌾"; filled: true; onClicked: menu.sh("/home/gopal/.config/hypr/scripts/lock") }
                IconButton {
                    icon: "󰐥"; filled: true
                    color: Theme.errorContainer; fg: Theme.fgErrorContainer
                    onClicked: menu.sh("qs ipc call power toggle")
                }
            }
        }
    }
}
