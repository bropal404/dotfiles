//@ pragma UseQApplication
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Greetd
import QtQuick

// DUNE login — title card greeter for greetd.
ShellRoot {
    id: root
    readonly property string user: Quickshell.env("DUNE_GREETER_USER") || "gopal"
    property string status: "THE SLEEPER MUST AWAKEN"
    property bool failed: false
    property bool busy: false
    property string session: Quickshell.env("DUNE_GREETER_SESSION") || "start-hyprland"

    readonly property color sand: "#eac5b2"
    readonly property color spice: "#d98a4e"
    readonly property color night: "#0d0b0a"

    function submit(pw) {
        if (busy) return;
        if (!Greetd.available) { failed = true; status = "GREETD OFFLINE"; return; }
        busy = true; failed = false; status = "VERIFYING";
        pending = pw;
        Greetd.createSession(user);
    }
    property string pending: ""

    Connections {
        target: Greetd
        function onAuthMessage(message, error, responseRequired, echoResponse) {
            if (responseRequired) Greetd.respond(root.pending);
            else Greetd.respond("");
        }
        function onAuthFailure(message) {
            root.busy = false; root.failed = true; root.pending = "";
            root.status = "ACCESS DENIED";
            Greetd.cancelSession();
            for (const f of fields.instances) f.clear();
        }
        function onReadyToLaunch() {
            root.status = "ARRAKIS AWAITS";
            Greetd.launch([root.session], [], true);
        }
        function onError(error) { root.busy = false; root.failed = true; root.status = "ERROR"; }
    }

    Variants {
        id: fields
        model: Quickshell.screens
        PanelWindow {
            id: win
            required property var modelData
            screen: modelData
            anchors { left: true; right: true; top: true; bottom: true }
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            color: "#0d0b0a"

            function clear() { pw.text = ""; pw.forceActiveFocus(); }
            readonly property real k: Math.max(1.0, Math.min(1.5, 1500 / Math.max(width, 1) * 1.0 + (width < 2000 ? 0.15 : 0)))

            Image {
                anchors.fill: parent
                source: Qt.resolvedUrl("wallpaper.jpg")
                fillMode: Image.PreserveAspectCrop
                opacity: 0.8
            }
            // vignette
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#99000000" }
                    GradientStop { position: 0.5; color: "#22000000" }
                    GradientStop { position: 1.0; color: "#cc000000" }
                }
            }
            // letterbox
            Rectangle { width: parent.width; height: 110 * win.k; color: root.night; anchors.top: parent.top }
            Rectangle { width: parent.width; height: 110 * win.k; color: root.night; anchors.bottom: parent.bottom }

            // clock
            Text {
                id: clock
                anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter; verticalCenterOffset: -170 * win.k }
                font { family: "Lexend Peta"; weight: Font.Thin; pixelSize: 92 * win.k; letterSpacing: 40 * win.k }
                color: root.sand
                text: Qt.formatTime(new Date(), "hh") + "  " + Qt.formatTime(new Date(), "mm")
                style: Text.Raised; styleColor: "#80000000"
                Timer { interval: 1000; running: true; repeat: true; onTriggered: { const d = new Date(); clock.text = Qt.formatTime(d, "hh") + "  " + Qt.formatTime(d, "mm"); date.text = Qt.formatDate(d, "dddd   ·   dd MMMM").toUpperCase(); } }
            }
            // eclipse flare
            Rectangle { anchors.centerIn: parent; anchors.verticalCenterOffset: -70 * win.k; width: 720 * win.k; height: 1; color: "#73eac5b2" }
            Rectangle { anchors.centerIn: parent; anchors.verticalCenterOffset: -70 * win.k; width: 220 * win.k; height: 1; color: "#e6fff0e6" }
            Rectangle {
                anchors.centerIn: parent; anchors.verticalCenterOffset: -70 * win.k
                width: 11 * win.k; height: width; radius: width / 2
                color: "#0a0a0e"; border.width: 2; border.color: "#fff4ec"
            }
            Text {
                id: date
                anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter; verticalCenterOffset: -28 * win.k }
                font { family: "Lexend"; weight: Font.Light; pixelSize: 13 * win.k; letterSpacing: 9 * win.k }
                color: root.spice
                text: Qt.formatDate(new Date(), "dddd   ·   dd MMMM").toUpperCase()
            }

            // user label
            Text {
                anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter; verticalCenterOffset: 36 * win.k }
                font { family: "Lexend"; weight: Font.Light; pixelSize: 11 * win.k; letterSpacing: 8 * win.k }
                color: Qt.rgba(0.92, 0.77, 0.70, 0.55)
                text: root.user.toUpperCase()
            }

            // password
            Rectangle {
                id: box
                width: 420 * win.k; height: 44 * win.k
                anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter; verticalCenterOffset: 90 * win.k }
                color: "#590d0b0a"
                border.width: 1
                border.color: root.failed ? "#f2e0563b" : (pw.activeFocus ? "#d98a4e" : "#59eac5b2")
                Behavior on border.color { ColorAnimation { duration: 400 } }

                Text {
                    anchors.centerIn: parent
                    visible: pw.text.length === 0
                    text: root.status
                    font { family: "Lexend"; weight: Font.Light; pixelSize: 11 * win.k; letterSpacing: 6 * win.k }
                    color: root.failed ? "#e0563b" : "#99eac5b2"
                }
                TextInput {
                    id: pw
                    anchors.fill: parent
                    echoMode: TextInput.Password
                    passwordCharacter: "◆"
                    horizontalAlignment: TextInput.AlignHCenter
                    verticalAlignment: TextInput.AlignVCenter
                    font { family: "Lexend"; pixelSize: 11 * win.k }
                    color: root.sand
                    enabled: !root.busy
                    focus: true
                    cursorVisible: false
                    cursorDelegate: Item {}
                    onAccepted: if (text.length) root.submit(text)
                    onTextChanged: if (text.length) { root.failed = false; root.status = "THE SLEEPER MUST AWAKEN"; }
                    Component.onCompleted: forceActiveFocus()
                }
                // shake on failure
                SequentialAnimation on anchors.horizontalCenterOffset {
                    id: shake; running: false
                    NumberAnimation { to: -14; duration: 50 }
                    NumberAnimation { to: 14; duration: 80 }
                    NumberAnimation { to: -8; duration: 70 }
                    NumberAnimation { to: 0; duration: 60 }
                }
                Connections { target: root; function onFailedChanged() { if (root.failed) shake.restart(); } }
            }

            // lower letterbox text
            Text {
                anchors { left: parent.left; leftMargin: 60 * win.k; bottom: parent.bottom; bottomMargin: 46 * win.k }
                text: "FEAR IS THE MIND-KILLER"
                font { family: "Lexend"; weight: Font.Light; pixelSize: 9 * win.k; letterSpacing: 7 * win.k }
                color: "#99eac5b2"
            }
            Text {
                anchors { right: parent.right; rightMargin: 60 * win.k; bottom: parent.bottom; bottomMargin: 46 * win.k }
                text: "ARRAKIS  ·  " + root.user.toUpperCase()
                font { family: "Lexend"; weight: Font.Light; pixelSize: 9 * win.k; letterSpacing: 7 * win.k }
                color: "#99eac5b2"
            }
        }
    }
}
