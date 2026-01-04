pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
//import Caelestia.Services
import QtQuick 2.15
import QtQuick.Effects

Item {
    id: root

    // Properties expected by Background.qml when instantiating this widget
    property int screenWidth: 0
    property int screenHeight: 0
    property int scaledScreenWidth: 0
    property int scaledScreenHeight: 0
    property real wallpaperScale: 1.0

    // Visualizer-specific properties
    property var points: []
    property var smoothPoints: []
    property real maxVisualizerValue: 1000
    property int smoothing: 2
    property bool live: true
    property color color: "white"

    implicitWidth: 300
    implicitHeight: 200

    onPointsChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent
        renderTarget: Canvas.Image
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            var pts = root.points || [];
            var maxVal = root.maxVisualizerValue || 1;
            var h = height;
            var w = width;
            var n = pts.length;
            if (n < 2) return;

            var smoothWindow = root.smoothing;
            root.smoothPoints = [];
            for (var i = 0; i < n; ++i) {
                var sum = 0, count = 0;
                for (var j = -smoothWindow; j <= smoothWindow; ++j) {
                    var idx = Math.max(0, Math.min(n - 1, i + j));
                    sum += pts[idx] || 0;
                    count++;
                }
                root.smoothPoints.push(sum / count);
            }
            if (!root.live) {
                for (var k = 0; k < root.smoothPoints.length; ++k) root.smoothPoints[k] = 0;
            }

            ctx.beginPath();
            ctx.moveTo(0, h);
            for (var i = 0; i < n; ++i) {
                var x = (n === 1) ? w/2 : i * w / (n - 1);
                var y = h - (root.smoothPoints[i] / maxVal) * h;
                ctx.lineTo(x, y);
            }
            ctx.lineTo(w, h);
            ctx.closePath();

            // Draw fill
            ctx.fillStyle = 'rgba(255,255,255,0.12)';
            try { ctx.fillStyle = Qt.rgba(root.color.r, root.color.g, root.color.b, 0.12); } catch (e) {}
            ctx.fill();
        }
    }

    layer.enabled: true
    layer.effect: MultiEffect {
        source: canvas
        saturation: 0.2
        blurEnabled: true
        blurMax: 7
        blur: 1
    }
}
