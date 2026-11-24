import Quickshell
import Quickshell.Wayland
import QtQuick

// Cinematic title card shown at login:  qs ipc call intro play
// Black → the eclipse flare ignites → ARRAKIS emerges from wide tracking → letterbox bars
// part to reveal the desktop. Click-through; never grabs input.
PanelWindow {
    id: intro
    required property var modelData
    screen: modelData

    visible: false
    color: "transparent"
    anchors { left: true; right: true; top: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-intro"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    mask: Region {}

    property string title: "A R R A K I S"
    property string subtitle: "WELCOME  ·  " + (Quickshell.env("USER") ?? "").toUpperCase()

    function play() {
        seq.stop();
        veil.opacity = 1; flare.flareLength = 0; flare.intensity = 0;
        titleText.opacity = 0; titleText.font.letterSpacing = 46;
        sub.opacity = 0; topBar.height = height * 0.5; botBar.height = height * 0.5;
        content.opacity = 1;
        visible = true;
        seq.start();
    }

    // letterbox halves: start closed (full black), then part to cinema bars, then slide away
    Rectangle { id: topBar; anchors { left: parent.left; right: parent.right; top: parent.top } color: "#050404" }
    Rectangle { id: botBar; anchors { left: parent.left; right: parent.right; bottom: parent.bottom } color: "#050404" }
    Rectangle { id: veil; anchors.fill: parent; color: "#050404" }

    Item {
        id: content
        anchors.fill: parent

        Eclipse {
            id: flare
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -10
            ringSize: 16
            flareLength: 0
            intensity: 0
        }
        Text {
            id: titleText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: flare.top
            anchors.bottomMargin: 26
            text: intro.title
            color: Theme.sand
            opacity: 0
            font.family: Theme.displayFont
            font.weight: Font.Thin
            font.pixelSize: Math.round(intro.height * 0.045)
            font.letterSpacing: 46
            renderType: Text.QtRendering
        }
        Text {
            id: sub
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: flare.bottom
            anchors.topMargin: 30
            text: intro.subtitle
            color: Theme.spice
            opacity: 0
            font.family: Theme.displayFont
            font.weight: Font.Light
            font.pixelSize: Math.round(intro.height * 0.011)
            font.letterSpacing: 8
            renderType: Text.QtRendering
        }
    }

    SequentialAnimation {
        id: seq
        PauseAnimation { duration: 250 }
        ParallelAnimation {
            NumberAnimation { target: flare; property: "intensity"; to: 1; duration: 1600; easing.type: Easing.InOutQuad }
            NumberAnimation { target: flare; property: "flareLength"; to: intro.width * 0.6; duration: 2400; easing.type: Easing.OutExpo }
            SequentialAnimation {
                PauseAnimation { duration: 700 }
                ParallelAnimation {
                    NumberAnimation { target: titleText; property: "opacity"; to: 1; duration: 1800; easing.type: Easing.InOutQuad }
                    NumberAnimation { target: titleText; property: "font.letterSpacing"; to: 22; duration: 3200; easing.type: Easing.OutCubic }
                }
            }
        }
        NumberAnimation { target: sub; property: "opacity"; to: 1; duration: 900; easing.type: Easing.InOutQuad }
        PauseAnimation { duration: 900 }
        // reveal: the black veil lifts into cinema bars, then the bars slide off-screen
        ParallelAnimation {
            NumberAnimation { target: veil; property: "opacity"; to: 0; duration: 1600; easing.type: Easing.InOutQuad }
            NumberAnimation { target: topBar; property: "height"; to: intro.height * 0.11; duration: 1600; easing.type: Easing.InOutCubic }
            NumberAnimation { target: botBar; property: "height"; to: intro.height * 0.11; duration: 1600; easing.type: Easing.InOutCubic }
        }
        ParallelAnimation {
            NumberAnimation { target: content; property: "opacity"; to: 0; duration: 1400; easing.type: Easing.InQuad }
            NumberAnimation { target: topBar; property: "height"; to: 0; duration: 1800; easing.type: Easing.InOutCubic }
            NumberAnimation { target: botBar; property: "height"; to: 0; duration: 1800; easing.type: Easing.InOutCubic }
        }
        ScriptAction { script: intro.visible = false }
    }
}
