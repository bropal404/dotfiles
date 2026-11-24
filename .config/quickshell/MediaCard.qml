import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts

// Now-playing card with art, seek bar and controls. Cycles between players.
Card {
    id: card
    property int idx: 0
    readonly property var players: Mpris.players.values
    readonly property var player: players.length === 0 ? null
        : players.find(p => p.isPlaying && idx === 0) ?? players[Math.min(idx, players.length - 1)]

    visible: player !== null
    implicitHeight: 132
    clip: true
    color: Theme.surfaceContainerHigh

    // blurred-ish art backdrop
    Image {
        anchors.fill: parent
        source: card.player?.trackArtUrl ?? ""
        fillMode: Image.PreserveAspectCrop
        opacity: 0.18
        asynchronous: true
    }

    // keep position ticking while playing
    Timer {
        running: card.player?.isPlaying ?? false
        interval: 1000; repeat: true
        onTriggered: card.player.positionChanged()
    }

    function fmt(s) { s = Math.max(0, Math.floor(s)); return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0"); }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 14

        Rectangle {
            Layout.preferredWidth: 104
            Layout.preferredHeight: 104
            radius: Theme.radiusM
            color: Theme.secondaryContainer
            clip: true
            Icon { anchors.centerIn: parent; text: "󰎈"; size: 36; color: Theme.fgSecondaryContainer; visible: art.status !== Image.Ready }
            Image {
                id: art
                anchors.fill: parent
                source: card.player?.trackArtUrl ?? ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize.width: 208
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                StyledText {
                    Layout.fillWidth: true
                    text: card.player?.identity ?? ""
                    color: Theme.primary
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                }
                StyledText {
                    visible: card.players.length > 1
                    text: (card.players.indexOf(card.player) + 1) + "/" + card.players.length
                    color: Theme.fgSurfaceVariant
                    font.pixelSize: 11
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: card.idx = (card.players.indexOf(card.player) + 1) % card.players.length }
                }
            }
            StyledText {
                Layout.fillWidth: true
                text: card.player?.trackTitle || "Unknown title"
                font.pixelSize: 15
                font.weight: Font.DemiBold
            }
            StyledText {
                Layout.fillWidth: true
                text: card.player?.trackArtist || ""
                color: Theme.fgSurfaceVariant
                font.pixelSize: 12
            }

            Item { Layout.fillHeight: true }

            // progress
            Rectangle {
                visible: card.player?.lengthSupported ?? false
                Layout.fillWidth: true
                implicitHeight: 4
                radius: 2
                color: Theme.alpha(Theme.fgSurface, 0.15)
                Rectangle {
                    height: parent.height; radius: 2
                    width: card.player && card.player.length > 0 ? parent.width * Math.min(1, card.player.position / card.player.length) : 0
                    color: Theme.primary
                }
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    enabled: card.player?.canSeek ?? false
                    cursorShape: Qt.PointingHandCursor
                    onClicked: m => card.player.position = card.player.length * Math.max(0, Math.min(1, (m.x - 6) / parent.width))
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 4
                StyledText {
                    text: card.player?.lengthSupported ? card.fmt(card.player.position) + " / " + card.fmt(card.player.length) : ""
                    color: Theme.fgSurfaceVariant
                    font.pixelSize: 11
                    Layout.fillWidth: true
                }
                IconButton { icon: "󰒮"; implicitWidth: 32; implicitHeight: 32; enabled: card.player?.canGoPrevious ?? false; onClicked: card.player.previous() }
                Rectangle {
                    implicitWidth: 44; implicitHeight: 36
                    radius: card.player?.isPlaying ? Theme.radiusS : 18
                    color: Theme.primary
                    Behavior on radius { NumberAnimation { duration: Theme.durMedium } }
                    Icon { anchors.centerIn: parent; text: card.player?.isPlaying ? "󰏤" : "󰐊"; color: Theme.fgPrimary; size: 20 }
                    StateLayer { tint: Theme.fgPrimary; onClicked: card.player.togglePlaying() }
                }
                IconButton { icon: "󰒭"; implicitWidth: 32; implicitHeight: 32; enabled: card.player?.canGoNext ?? false; onClicked: card.player.next() }
            }
        }
    }
}
