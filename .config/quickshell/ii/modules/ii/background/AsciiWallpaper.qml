import QtQuick
import qs.modules.common
import "AsciiArt.js" as AsciiArt

Item {
    id: root
    anchors.fill: parent

    readonly property string asciiArt: AsciiArt.art

    Rectangle {
        anchors.fill: parent
        color: "#050505" // Solid rich black background
    }

    Item {
        anchors.centerIn: parent
        width: asciiText.implicitWidth
        height: asciiText.implicitHeight

        Text {
            id: asciiText
            anchors.centerIn: parent
            text: root.asciiArt
            font.family: "Monocraft"
            // Dynamically scale font size based on screen width so it fits perfectly
            font.pixelSize: Math.max(6, Math.min(10, root.width / 210))
            color: Appearance.colors.colOnLayer1 // Monochrome text color
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            lineHeight: 0.85 // Compress vertical line spacing for dense character layout
            style: Text.Normal

            // Pulsing animation to simulate gravitational breathing/pulsing of the accretion disk
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { from: 0.7; to: 0.95; duration: 5000; easing.type: Easing.InOutSine }
                NumberAnimation { from: 0.95; to: 0.7; duration: 5000; easing.type: Easing.InOutSine }
            }
        }
    }
}
