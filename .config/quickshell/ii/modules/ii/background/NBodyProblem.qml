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

    // Capture mouse
    MouseArea {
        id: mouseTracker
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }

    // Simulation properties
    readonly property real gravity: 1.5
    readonly property real dt: 0.8
    readonly property real softening: 25.0 // Prevents singularity collisions
    readonly property real maxSpeed: 16.0
    readonly property real mouseMass: 400.0 // Heavy gravity well

    // State arrays for 3 bodies
    property var bodies: [
        { x: 0, y: 0, vx: 0, vy: 0, mass: 220, color: Appearance.colors.colPrimary, trail: [] },
        { x: 0, y: 0, vx: 0, vy: 0, mass: 220, color: Appearance.colors.colSecondary, trail: [] },
        { x: 0, y: 0, vx: 0, vy: 0, mass: 220, color: Appearance.colors.colOutlineVariant, trail: [] }
    ]

    function initPositions() {
        if (width <= 0 || height <= 0) return;

        // Spread bodies in a triangle around the center
        let cx = width / 2;
        let cy = height / 2;
        let r = 180;

        // Body 1
        bodies[0].x = cx + r * Math.cos(0);
        bodies[0].y = cy + r * Math.sin(0);
        bodies[0].vx = -3.0;
        bodies[0].vy = 5.0;
        bodies[0].trail = [];

        // Body 2
        bodies[1].x = cx + r * Math.cos(2 * Math.PI / 3);
        bodies[1].y = cy + r * Math.sin(2 * Math.PI / 3);
        bodies[1].vx = 5.0;
        bodies[1].vy = -2.0;
        bodies[1].trail = [];

        // Body 3
        bodies[2].x = cx + r * Math.cos(4 * Math.PI / 3);
        bodies[2].y = cy + r * Math.sin(4 * Math.PI / 3);
        bodies[2].vx = -2.0;
        bodies[2].vy = -3.0;
        bodies[2].trail = [];
    }

    onWidthChanged: initPositions()
    onHeightChanged: initPositions()

    function stepSimulation() {
        if (width <= 0 || height <= 0) return;

        // Calculate forces
        let forces = [
            { fx: 0, fy: 0 },
            { fx: 0, fy: 0 },
            { fx: 0, fy: 0 }
        ];

        // 1. Gravitational pull between bodies
        for (let i = 0; i < 3; i++) {
            let bI = bodies[i];
            for (let j = i + 1; j < 3; j++) {
                let bJ = bodies[j];
                let dx = bJ.x - bI.x;
                let dy = bJ.y - bI.y;
                let distSq = dx * dx + dy * dy + softening * softening;
                let dist = Math.sqrt(distSq);

                // Force = G * m1 * m2 / r^2
                let fVal = (gravity * bI.mass * bJ.mass) / distSq;
                let fx = fVal * (dx / dist);
                let fy = fVal * (dy / dist);

                forces[i].fx += fx;
                forces[i].fy += fy;
                forces[j].fx -= fx;
                forces[j].fy -= fy;
            }

            // 2. Gravity attraction to Mouse Cursor
            if (mouseTracker.containsMouse) {
                let mdx = mouseTracker.mouseX - bI.x;
                let mdy = mouseTracker.mouseY - bI.y;
                let mdistSq = mdx * mdx + mdy * mdy + softening * softening;
                let mdist = Math.sqrt(mdistSq);

                let mfVal = (gravity * bI.mass * mouseMass) / mdistSq;
                forces[i].fx += mfVal * (mdx / mdist);
                forces[i].fy += mfVal * (mdy / mdist);
            }
        }

        // Apply forces, update velocities & positions
        for (let i = 0; i < 3; i++) {
            let b = bodies[i];
            let f = forces[i];

            // Acceleration = Force / Mass
            b.vx += (f.fx / b.mass) * dt;
            b.vy += (f.fy / b.mass) * dt;

            // Cap speeds to prevent high-gravity escape velocity
            let speed = Math.sqrt(b.vx * b.vx + b.vy * b.vy);
            if (speed > maxSpeed) {
                b.vx = (b.vx / speed) * maxSpeed;
                b.vy = (b.vy / speed) * maxSpeed;
            }

            // Update position
            b.x += b.vx * dt;
            b.y += b.vy * dt;

            // Boundary bounce
            const size = 16;
            if (b.x < size) {
                b.x = size;
                b.vx = -b.vx * 0.85;
            } else if (b.x > width - size) {
                b.x = width - size;
                b.vx = -b.vx * 0.85;
            }

            if (b.y < size) {
                b.y = size;
                b.vy = -b.vy * 0.85;
            } else if (b.y > height - size) {
                b.y = height - size;
                b.vy = -b.vy * 0.85;
            }

            // Add to trail
            b.trail.push({ x: b.x, y: b.y });
            if (b.trail.length > 80) {
                b.trail.shift();
            }
        }

        // Trigger UI updates
        root.bodies = bodies;
        trailCanvas.requestPaint();
        bodyRepeater.model = []; // Force update bindings
        bodyRepeater.model = bodies;
    }

    Timer {
        id: simTimer
        interval: 16
        running: true
        repeat: true
        onTriggered: root.stepSimulation()
    }

    // Fading trails
    Canvas {
        id: trailCanvas
        anchors.fill: parent
        opacity: 0.7

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            for (let bIdx = 0; bIdx < 3; bIdx++) {
                let trail = root.bodies[bIdx].trail;
                let color = root.bodies[bIdx].color;
                if (trail.length < 2) continue;

                for (let i = 1; i < trail.length; i++) {
                    ctx.beginPath();
                    ctx.moveTo(trail[i-1].x, trail[i-1].y);
                    ctx.lineTo(trail[i].x, trail[i].y);
                    ctx.lineWidth = 1.0 + (i / trail.length) * 2.0;

                    let alpha = i / trail.length;
                    ctx.strokeStyle = CF.ColorUtils.transparentize(color, 1.0 - alpha);
                    ctx.stroke();
                }
            }
        }
    }

    // Render bodies
    Repeater {
        id: bodyRepeater
        model: root.bodies

        delegate: Item {
            x: modelData.x - 12
            y: modelData.y - 12
            width: 24
            height: 24

            Rectangle {
                anchors.fill: parent
                radius: 12
                color: modelData.color

                // Glowing aura
                Rectangle {
                    anchors.centerIn: parent
                    width: 36; height: 36; radius: 18
                    color: parent.color
                    opacity: 0.35
                    z: -1
                }
            }
        }
    }
}
