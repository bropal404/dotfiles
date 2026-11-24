import QtQuick

Text {
    // caps: render as tracked uppercase, the Dune title style
    property bool caps: false
    color: Theme.fgSurface
    font.family: Theme.font
    font.pixelSize: 13
    font.capitalization: caps ? Font.AllUppercase : Font.MixedCase
    font.letterSpacing: caps ? Theme.tracking : 0.2
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    renderType: Text.QtRendering
}
