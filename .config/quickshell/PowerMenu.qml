import Quickshell
import Quickshell.Wayland
import QtQuick

// Power menu (Super+X): every action is press-and-hold. A spice bar fills as you hold;
// let go early and it drains away. Longer holds for heavier actions.
//   mouse: hold the button      keyboard: hold the underlined letter
PanelWindow {
    id: menu
    required property var modelData
    screen: modelData

    visible: false
    color: "transparent"
    anchors { left: true; right: true; top: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-power"
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    readonly property string home: Quickshell.env("HOME")

    // hold = milliseconds to hold before the action fires
    readonly property var actions: [
        { key: Qt.Key_L, letter: "L", label: "Lock",      icon: "lock",     hold: 400,  cmd: [home + "/.config/hypr/scripts/lock"] },
        { key: Qt.Key_U, letter: "U", label: "Sleep",     icon: "suspend",  hold: 800,  cmd: ["systemctl", "suspend"] },
        { key: Qt.Key_E, letter: "E", label: "Depart",    icon: "logout",   hold: 1200, cmd: ["hyprctl", "dispatch", "hl.dsp.exit()"] },
        { key: Qt.Key_R, letter: "R", label: "Rebirth",   icon: "reboot",   hold: 1800, cmd: ["systemctl", "reboot"] },
        { key: Qt.Key_S, letter: "S", label: "Shut down", icon: "shutdown", hold: 2200, cmd: ["systemctl", "poweroff"] }
    ]

    property int heldIndex: -1

    function open()  { heldIndex = -1; visible = true; focusItem.forceActiveFocus(); }
    function close() { visible = false; }
    function toggle() { visible ? close() : open(); }

    function fire(i) {
        const a = actions[i];
        close();
        // let the overlay fade before the screen locks / session ends
        Quickshell.execDetached(["sh", "-c", "sleep 0.25; exec \"$@\"", "sh"].concat(a.cmd));
    }

    onVisibleChanged: {
        if (visible) return;
        heldIndex = -1;
        for (let i = 0; i < actions.length; i++) rep.itemAt(i)?.reset();
    }

    Item {
        id: focusItem
        anchors.fill: parent
        focus: true

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) { menu.close(); event.accepted = true; return; }
            if (event.isAutoRepeat) { event.accepted = true; return; }
            for (let i = 0; i < menu.actions.length; i++) {
                if (event.key === menu.actions[i].key) {
                    menu.heldIndex = i;
                    rep.itemAt(i).beginHold();
                    event.accepted = true;
                    return;
                }
            }
        }
        Keys.onReleased: event => {
            if (event.isAutoRepeat) return;
            for (let i = 0; i < menu.actions.length; i++) {
                if (event.key === menu.actions[i].key) {
                    rep.itemAt(i).cancelHold();
                    event.accepted = true;
                    return;
                }
            }
        }

        // veil
        Rectangle {
            id: veil
            anchors.fill: parent
            color: "#0d0b0a"
            opacity: menu.visible ? 0.9 : 0
            Behavior on opacity { NumberAnimation { duration: Theme.durMedium; easing.type: Easing.OutCubic } }
            MouseArea { anchors.fill: parent; onClicked: menu.close() }
        }

        // title + hint
        StyledText {
            anchors { horizontalCenter: parent.horizontalCenter; bottom: row.top; bottomMargin: 56 }
            text: "Hold to confirm"
            caps: true
            font.family: Theme.displayFont
            font.pixelSize: 11
            font.letterSpacing: 8
            color: Theme.alpha(Theme.sand, 0.5)
            opacity: veil.opacity > 0.5 ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: Theme.durLong } }
        }

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 0
            opacity: menu.visible ? 1 : 0
            transform: Translate { y: menu.visible ? 0 : 14; Behavior on y { NumberAnimation { duration: Theme.durLong; easing.type: Easing.OutExpo } } }
            Behavior on opacity { NumberAnimation { duration: Theme.durMedium } }

            Repeater {
                id: rep
                model: menu.actions
                delegate: Item {
                    id: btn
                    required property var modelData
                    required property int index
                    width: 190
                    height: 240
                    property real progress: 0
                    readonly property bool holding: anim.running || mouse.pressed
                    readonly property bool hot: mouse.containsMouse || menu.heldIndex === index

                    function reset() { anim.stop(); drain.stop(); progress = 0; }
                    function beginHold() { anim.stop(); anim.from = progress; anim.to = 1; anim.duration = modelData.hold * (1 - progress); anim.start(); }
                    function cancelHold() {
                        anim.stop();
                        drain.from = progress; drain.to = 0; drain.duration = 350; drain.start();
                        menu.heldIndex = -1;
                    }

                    NumberAnimation { id: anim; target: btn; property: "progress"; easing.type: Easing.Linear
                        onFinished: { if (btn.progress >= 1) menu.fire(btn.index); } }
                    NumberAnimation { id: drain; target: btn; property: "progress"; easing.type: Easing.OutCubic }

                    // idle underline
                    Rectangle {
                        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 18 }
                        height: 1
                        color: Theme.alpha(Theme.sand, btn.hot ? 0.35 : 0.12)
                        Behavior on color { ColorAnimation { duration: Theme.durMedium } }
                    }
                    // hold fill — a spice line sweeping left→right along the underline…
                    Rectangle {
                        anchors { left: parent.left; bottom: parent.bottom; leftMargin: 18; bottomMargin: 0 }
                        width: (parent.width - 36) * btn.progress
                        height: 2
                        color: Theme.spice
                    }
                    // …and a warm glow rising behind the icon
                    Rectangle {
                        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 18 }
                        height: (parent.height - 36) * btn.progress
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 1.0; color: Theme.alpha(Theme.spice, 0.28) }
                        }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 26
                        Image {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 56; height: 56
                            sourceSize: Qt.size(112, 112)
                            source: "file://" + menu.home + "/.config/wlogout/icons/" + btn.modelData.icon + ".svg"
                            opacity: btn.hot || btn.holding ? 1 : 0.55
                            scale: 1 + btn.progress * 0.12
                            Behavior on opacity { NumberAnimation { duration: Theme.durMedium } }
                        }
                        StyledText {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: btn.modelData.label
                            caps: true
                            font.family: Theme.displayFont
                            font.pixelSize: 12
                            font.weight: Font.Light
                            font.letterSpacing: 6
                            color: btn.hot || btn.holding ? Theme.flare : Theme.alpha(Theme.sand, 0.55)
                            Behavior on color { ColorAnimation { duration: Theme.durMedium } }
                        }
                        StyledText {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: btn.progress > 0.02 ? (Math.max(0, btn.modelData.hold * (1 - btn.progress) / 1000)).toFixed(1) + " s"
                                                       : "hold  " + btn.modelData.letter
                            font.family: Theme.displayFont
                            font.pixelSize: 9
                            font.letterSpacing: 4
                            color: btn.progress > 0.02 ? Theme.spice : Theme.alpha(Theme.sand, 0.3)
                        }
                    }

                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPressed: btn.beginHold()
                        onReleased: btn.cancelHold()
                        onCanceled: btn.cancelHold()
                    }
                }
            }
        }
    }
}
