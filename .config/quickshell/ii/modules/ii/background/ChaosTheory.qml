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

    // Double pendulum physics properties
    property real theta1: Math.PI / 2
    property real theta2: Math.PI / 2
    property real omega1: 0
    property real omega2: 0
    property real l1: 180
    property real l2: 150
    property real m1: 2.0
    property real m2: 2.0
    property real g: 9.8
    property real dt: 0.16 // Time step

    // Pivot in the center of the screen
    property real pivotX: width / 2
    property real pivotY: height / 2 - 50

    property real x1: 0
    property real y1: 0
    property real x2: 0
    property real y2: 0

    property var trailPoints: []

    function stepPhysics() {
        // Mouse magnetic pull force on Bob 2
        let Fx = 0;
        let Fy = 0;
        if (mouseTracker.containsMouse) {
            let dx = mouseTracker.mouseX - (pivotX + x2);
            let dy = mouseTracker.mouseY - (pivotY + y2);
            let dist = Math.sqrt(dx * dx + dy * dy);
            if (dist > 1.0) {
                // Attractive force, stronger when closer, capped
                let pullStrength = Math.min(18.0, 350.0 / dist);
                Fx = (dx / dist) * pullStrength;
                Fy = (dy / dist) * pullStrength;
            }
        }

        // Standard Double Pendulum Accelerations
        let delta = theta1 - theta2;
        let num1 = -g * (2 * m1 + m2) * Math.sin(theta1) - m2 * g * Math.sin(theta1 - 2 * theta2) - 2 * Math.sin(delta) * m2 * (omega2 * omega2 * l2 + omega1 * omega1 * l1 * Math.cos(delta));
        let den1 = l1 * (2 * m1 + m2 - m2 * Math.cos(2 * theta1 - 2 * theta2));
        let alpha1 = num1 / den1;

        let num2 = 2 * Math.sin(delta) * (omega1 * omega1 * l1 * (m1 + m2) + g * (m1 + m2) * Math.cos(theta1) + omega2 * omega2 * l2 * m2 * Math.cos(delta));
        let den2 = l2 * (2 * m1 + m2 - m2 * Math.cos(2 * theta1 - 2 * theta2));
        let alpha2 = num2 / den2;

        // Apply mouse pull force as joint torque
        if (Fx !== 0 || Fy !== 0) {
            let t1 = l1 * Math.cos(theta1) * Fx - l1 * Math.sin(theta1) * Fy;
            let t2 = l2 * Math.cos(theta2) * Fx - l2 * Math.sin(theta2) * Fy;
            alpha1 += t1 / (m1 * l1 * l1);
            alpha2 += t2 / (m2 * l2 * l2);
        }

        // Integration (Euler-Cromer)
        omega1 += alpha1 * dt;
        omega2 += alpha2 * dt;

        // Subtle air resistance to prevent infinity drift
        omega1 *= 0.998;
        omega2 *= 0.998;

        theta1 += omega1 * dt;
        theta2 += omega2 * dt;

        // Update positions of the bobs
        x1 = l1 * Math.sin(theta1);
        y1 = l1 * Math.cos(theta1);
        x2 = x1 + l2 * Math.sin(theta2);
        y2 = y1 + l2 * Math.cos(theta2);

        // Save positions to trail buffer
        trailPoints.push({x: pivotX + x2, y: pivotY + y2});
        if (trailPoints.length > 120) {
            trailPoints.shift();
        }

        // Redraw canvas trail
        trailCanvas.requestPaint();
    }

    Timer {
        id: physicsTimer
        interval: 16
        running: true
        repeat: true
        onTriggered: root.stepPhysics()
    }

    // Fading chaotic path trail
    Canvas {
        id: trailCanvas
        anchors.fill: parent
        opacity: 0.75

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            if (root.trailPoints.length < 2) return;

            // Draw fading path segments
            for (var i = 1; i < root.trailPoints.length; i++) {
                ctx.beginPath();
                ctx.moveTo(root.trailPoints[i-1].x, root.trailPoints[i-1].y);
                ctx.lineTo(root.trailPoints[i].x, root.trailPoints[i].y);
                ctx.lineWidth = 1.0 + (i / root.trailPoints.length) * 2.0;

                // Fades from transparent to solid primary color at the tip
                let alpha = (i / root.trailPoints.length);
                ctx.strokeStyle = CF.ColorUtils.transparentize(Appearance.colors.colPrimary, 1.0 - alpha);
                ctx.stroke();
            }
        }
    }

    // Pivot anchor point
    Rectangle {
        x: root.pivotX - 4
        y: root.pivotY - 4
        width: 8
        height: 8
        radius: 4
        color: Appearance.colors.colOutlineVariant
    }

    // Upper Arm
    Rectangle {
        x: root.pivotX - 1.5
        y: root.pivotY
        width: 3
        height: root.l1
        color: Appearance.colors.colOutlineVariant
        opacity: 0.35
        transformOrigin: Item.Top
        rotation: root.theta1 * 180 / Math.PI
    }

    // Upper Bob (Elbow joint)
    Rectangle {
        x: root.pivotX + root.x1 - 5
        y: root.pivotY + root.y1 - 5
        width: 10
        height: 10
        radius: 5
        color: Appearance.colors.colOutlineVariant
        opacity: 0.7
    }

    // Lower Arm
    Rectangle {
        x: root.pivotX + root.x1 - 1.5
        y: root.pivotY + root.y1
        width: 3
        height: root.l2
        color: Appearance.colors.colPrimary
        opacity: 0.55
        transformOrigin: Item.Top
        rotation: root.theta2 * 180 / Math.PI
    }

    // Lower Bob (Chaotic tip)
    Rectangle {
        x: root.pivotX + root.x2 - 8
        y: root.pivotY + root.y2 - 8
        width: 16
        height: 16
        radius: 8
        color: Appearance.colors.colPrimary

        Rectangle {
            anchors.centerIn: parent
            width: 28; height: 28; radius: 14
            color: parent.color
            opacity: 0.35
            z: -1
        }
    }
}
