import Quickshell.Services.Mpris
import QtQuick

// Compact "now playing" chip in the bar; hidden when nothing is playing.
Rectangle {
    id: chip
    signal clicked()
    readonly property var player: Mpris.players.values.find(p => p.isPlaying) ?? null

    visible: player !== null
    implicitWidth: row.implicitWidth + 24
    radius: Theme.radiusPill
    color: Theme.tertiaryContainer

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 8
        Icon { text: "󰎈"; size: 15; color: Theme.fgTertiaryContainer }
        StyledText {
            width: Math.min(implicitWidth, 220)
            text: (chip.player?.trackTitle ?? "") + (chip.player?.trackArtist ? "  ·  " + chip.player.trackArtist : "")
            color: Theme.fgTertiaryContainer
            font.pixelSize: 12
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    StateLayer {
        tint: Theme.fgTertiaryContainer
        onClicked: m => {
            if (m.button === Qt.MiddleButton) chip.player?.togglePlaying();
            else chip.clicked();
        }
        onWheel: w => w.angleDelta.y > 0 ? chip.player?.previous() : chip.player?.next()
    }
}
