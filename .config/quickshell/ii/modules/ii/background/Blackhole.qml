import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.functions as CF

Item {
    id: root
    anchors.fill: parent

    // Background
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.85
    }

    // Capture mouse hover
    MouseArea {
        id: mouseTracker
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }

    // Default center coordinates
    readonly property real defaultCenterX: parent.width / 2
    readonly property real defaultCenterY: parent.height / 2

    // Target coordinates for blackhole center
    property real targetX: mouseTracker.containsMouse ? mouseTracker.mouseX : defaultCenterX
    property real targetY: mouseTracker.containsMouse ? mouseTracker.mouseY : defaultCenterY

    // Smooth transition for blackhole center (spring gravity pull)
    Item {
        id: blackholeCenter
        x: targetX
        y: targetY

        Behavior on x {
            SpringAnimation { spring: 1.5; damping: 0.7; mass: 1.0 }
        }
        Behavior on y {
            SpringAnimation { spring: 1.5; damping: 0.7; mass: 1.0 }
        }

        // Schwarzschild Event Horizon & Gravitational Lensing Halo (Einstein Ring)
        Rectangle {
            id: eventHorizon
            width: 90
            height: 90
            radius: 45
            color: "#000000"
            anchors.centerIn: parent

            // Einstein Ring / Light Bending border
            border.color: Appearance.colors.colPrimary
            border.width: 1.5

            // Lensing glow layers
            Rectangle {
                anchors.centerIn: parent
                width: 96; height: 96; radius: 48
                color: Appearance.colors.colPrimary
                opacity: 0.35
                z: -1
            }
            Rectangle {
                anchors.centerIn: parent
                width: 115; height: 115; radius: 57.5
                color: Appearance.colors.colPrimary
                opacity: 0.15
                z: -2
            }
            Rectangle {
                anchors.centerIn: parent
                width: 140; height: 140; radius: 70
                color: Appearance.colors.colPrimary
                opacity: 0.06
                z: -3
            }
        }
    }

    // Accretion Disk Gas Particles State
    property var particles: []
    readonly property real dt: 1.0

    function initParticles() {
        if (width <= 0 || height <= 0) return;
        let pList = [];
        let numParticles = 120;
        for (let i = 0; i < numParticles; i++) {
            pList.push(createParticle(true));
        }
        particles = pList;
    }

    function createParticle(randomProgress) {
        let cx = blackholeCenter.x;
        let cy = blackholeCenter.y;

        // Distribute starting distances between 80px and 600px
        let r = 80 + (randomProgress ? Math.random() * 520 : 520);
        let angle = Math.random() * 2 * Math.PI;
        let px = cx + r * Math.cos(angle);
        let py = cy + r * Math.sin(angle);

        // Circular orbit velocity: v = sqrt(GM / r)
        let vMag = Math.sqrt(3500.0 / r) * (0.85 + Math.random() * 0.3);
        // Clockwise velocity vector
        let vx = -Math.sin(angle) * vMag;
        let vy = Math.cos(angle) * vMag;

        return {
            x: px,
            y: py,
            vx: vx,
            vy: vy,
            size: 1.5 + Math.random() * 2.0
        };
    }

    onWidthChanged: initParticles()
    onHeightChanged: initParticles()

    // Physics update step (gravity + friction decay)
    function stepSimulation() {
        if (width <= 0 || height <= 0 || particles.length === 0) return;

        let cx = blackholeCenter.x;
        let cy = blackholeCenter.y;
        const GM = 3200.0;       // Gravitational strength
        const friction = 0.0016; // Gas friction causing spiral collapse
        const eventHorizonRad = 45;

        for (let i = 0; i < particles.length; i++) {
            let p = particles[i];
            let dx = cx - p.x;
            let dy = cy - p.y;
            let distSq = dx * dx + dy * dy;
            let dist = Math.sqrt(distSq);

            // If crossed the Event Horizon boundary
            if (dist < eventHorizonRad) {
                let newP = createParticle(false);
                p.x = newP.x;
                p.y = newP.y;
                p.vx = newP.vx;
                p.vy = newP.vy;
                p.size = newP.size;
                continue;
            }

            // Gravity force: a = GM / r^2
            let acc = GM / (distSq + 200.0); // Softened
            let ax = acc * (dx / dist);
            let ay = acc * (dy / dist);

            // Orbit updates with gas energy decay
            p.vx += ax * dt - p.vx * friction * dt;
            p.vy += ay * dt - p.vy * friction * dt;

            p.x += p.vx * dt;
            p.y += p.vy * dt;
        }

        trailCanvas.requestPaint();
    }

    Timer {
        id: simTimer
        interval: 16
        running: true
        repeat: true
        onTriggered: root.stepSimulation()
    }

    // Unified render layer (Warped Spacetime Grid + Glowing Particles)
    Canvas {
        id: trailCanvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            let cx = blackholeCenter.x;
            let cy = blackholeCenter.y;
            let rs = 70; // Schwarzschild gravity warp radius

            // 1. Render Spacetime Curvature Funnel (Coordinate Grid)
            ctx.lineWidth = 1.0;
            ctx.strokeStyle = CF.ColorUtils.transparentize(Appearance.colors.colPrimary, 0.93);

            let stepX = 60;
            let stepY = 60;

            // Draw warped horizontal coordinate lines
            for (let gy = 0; gy < height + stepY; gy += stepY) {
                ctx.beginPath();
                for (let gx = 0; gx < width + stepX; gx += 20) {
                    let dx = gx - cx;
                    let dy = gy - cy;
                    let r = Math.sqrt(dx * dx + dy * dy);
                    let w = Math.pow(rs / (r + rs), 1.6);
                    let px = gx - dx * w;
                    let py = gy - dy * w;
                    if (gx === 0) ctx.moveTo(px, py);
                    else ctx.lineTo(px, py);
                }
                ctx.stroke();
            }

            // Draw warped vertical coordinate lines
            for (let gx = 0; gx < width + stepX; gx += stepX) {
                ctx.beginPath();
                for (let gy = 0; gy < height + stepY; gy += 20) {
                    let dx = gx - cx;
                    let dy = gy - cy;
                    let r = Math.sqrt(dx * dx + dy * dy);
                    let w = Math.pow(rs / (r + rs), 1.6);
                    let px = gx - dx * w;
                    let py = gy - dy * w;
                    if (gy === 0) ctx.moveTo(px, py);
                    else ctx.lineTo(px, py);
                }
                ctx.stroke();
            }

            // 2. Render Accretion Disk Gas Particles
            for (let i = 0; i < root.particles.length; i++) {
                let p = root.particles[i];
                let dx = p.x - cx;
                let dy = p.y - cy;
                let dist = Math.sqrt(dx * dx + dy * dy);

                // Relativistic compression heating: gas glow intensity increases near horizon
                let proximityAlpha = Math.min(1.0, 160.0 / dist);
                ctx.fillStyle = CF.ColorUtils.transparentize(Appearance.colors.colPrimary, 1.0 - (0.12 + proximityAlpha * 0.78));

                ctx.beginPath();
                ctx.arc(p.x, p.y, p.size, 0, 2 * Math.PI);
                ctx.fill();
            }
        }
    }
}
