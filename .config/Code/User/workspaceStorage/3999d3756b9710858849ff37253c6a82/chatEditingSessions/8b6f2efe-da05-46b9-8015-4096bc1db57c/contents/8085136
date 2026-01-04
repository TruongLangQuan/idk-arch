import QtQuick
import QtQuick.Effects
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.ii.background.widgets

AbstractBackgroundWidget {
    id: root
    configEntryName: "wavevisualizer"

    property list<var> points: []
    property list<var> smoothPoints: []
    property real maxVisualizerValue: 1000
    property int smoothing: 2
    property bool live: true
    property color color: Appearance.m3colors.m3primary

    implicitHeight: 200
    implicitWidth: 300

    onPointsChanged: {
        canvas.requestPaint()
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            var points = root.points || [];
            var maxVal = root.maxVisualizerValue || 1;
            var h = height;
            var w = width;
            var n = points.length;
            if (n < 2) return;

            // Smoothing: simple moving average (optional)
            var smoothWindow = root.smoothing; // adjust for more/less smoothing
            root.smoothPoints = [];
            for (var i = 0; i < n; ++i) {
                var sum = 0, count = 0;
                for (var j = -smoothWindow; j <= smoothWindow; ++j) {
                    var idx = Math.max(0, Math.min(n - 1, i + j));
                    sum += points[idx];
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
                var x = i * w / (n - 1);
                var y = h - (root.smoothPoints[i] / maxVal) * h;
                ctx.lineTo(x, y);
            }
            ctx.lineTo(w, h);
            ctx.closePath();

            ctx.fillStyle = Qt.rgba(0, 0, 0, 0.15);
            // If QColor provided, try to extract rgba components safely
            try {
                ctx.fillStyle = Qt.rgba(root.color.r, root.color.g, root.color.b, 0.15);
            } catch (e) {}
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