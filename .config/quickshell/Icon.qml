import QtQuick

// Nerd-font glyph (Material Design Icons range)
Text {
    property int size: 18
    color: Theme.fgSurface
    font.family: Theme.iconFont
    font.pixelSize: size
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    renderType: Text.QtRendering
}
