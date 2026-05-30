import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import qs.modules.common

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

    readonly property real defaultCenterX: parent.width / 2
    readonly property real defaultCenterY: parent.height / 2

    // Interpolated target coordinates
    property real targetX: mouseTracker.containsMouse ? mouseTracker.mouseX : defaultCenterX
    property real targetY: mouseTracker.containsMouse ? mouseTracker.mouseY : defaultCenterY

    Behavior on targetX { SpringAnimation { spring: 1.5; damping: 0.8 } }
    Behavior on targetY { SpringAnimation { spring: 1.5; damping: 0.8 } }

    // Lorenz Attractor Equations & Path Generator
    property string pathData1: ""
    property string pathData2: ""
    property string pathData3: ""
    property var points1: []
    property var points2: []
    property var points3: []

    function regeneratePaths() {
        if (width <= 0 || height <= 0) return;

        let res1 = generateLorenzPath(0.1, 0.0, 0.0, 1000);
        pathData1 = res1.path;
        points1 = res1.points;

        let res2 = generateLorenzPath(0.1, 0.001, 0.0, 1000);
        pathData2 = res2.path;
        points2 = res2.points;

        let res3 = generateLorenzPath(0.1, 0.002, 0.0, 1000);
        pathData3 = res3.path;
        points3 = res3.points;
    }

    function generateLorenzPath(x0, y0, z0, steps) {
        let x = x0, y = y0, z = z0;
        const sigma = 10.0;
        const rho = 28.0;
        const beta = 8.0 / 3.0;
        const dt = 0.012;

        let points = [];
        let pathStr = "";

        // Scale factors
        const scale = Math.min(width, height) / 45.0;
        const offsetX = width / 2;
        const offsetY = height / 2 + 100;

        for (let i = 0; i < steps; i++) {
            let dx = sigma * (y - x) * dt;
            let dy = (x * (rho - z) - y) * dt;
            let dz = (x * y - beta * z) * dt;
            x += dx;
            y += dy;
            z += dz;

            // X = x, Y = z (projection of the attractor)
            let px = offsetX + x * scale;
            let py = offsetY - (z - 25) * scale;

            points.push({x: px, y: py});

            if (i === 0) {
                pathStr += "M " + px.toFixed(1) + " " + py.toFixed(1);
            } else {
                pathStr += " L " + px.toFixed(1) + " " + py.toFixed(1);
            }
        }
        return { points: points, path: pathStr };
    }

    onWidthChanged: regeneratePaths()
    onHeightChanged: regeneratePaths()

    // 3D Tilting and Container Group
    Item {
        id: container
        anchors.fill: parent

        // GPU-accelerated 3D Tilting Transform based on mouse proximity
        transform: [
            Rotation {
                origin.x: defaultCenterX
                origin.y: defaultCenterY
                axis { x: 1; y: 0; z: 0 }
                angle: (targetY - defaultCenterY) / 25
            },
            Rotation {
                origin.x: defaultCenterX
                origin.y: defaultCenterY
                axis { x: 0; y: 1; z: 0 }
                angle: -(targetX - defaultCenterX) / 25
            }
        ]

        // Attractor Trails using GPU Vector Shapes
        Shape {
            anchors.fill: parent
            antialiasing: true

            ShapePath {
                strokeColor: Qt.rgba(Appearance.colors.colPrimary.r, Appearance.colors.colPrimary.g, Appearance.colors.colPrimary.b, 0.35)
                strokeWidth: 1.5
                fillColor: "transparent"
                PathSvg { path: root.pathData1 }
            }

            ShapePath {
                strokeColor: Qt.rgba(Appearance.colors.colPrimary.r, Appearance.colors.colPrimary.g, Appearance.colors.colPrimary.b, 0.2)
                strokeWidth: 1.2
                fillColor: "transparent"
                PathSvg { path: root.pathData2 }
            }

            ShapePath {
                strokeColor: Qt.rgba(Appearance.colors.colOutlineVariant.r, Appearance.colors.colOutlineVariant.g, Appearance.colors.colOutlineVariant.b, 0.15)
                strokeWidth: 1.0
                fillColor: "transparent"
                PathSvg { path: root.pathData3 }
            }
        }

        // Progress Driver for Tracing Particles
        property real progress: 0
        NumberAnimation on progress {
            from: 0
            to: 1
            duration: 12000
            loops: Animation.Infinite
            running: true
        }

        // Particle 1 (Primary Path)
        Rectangle {
            width: 8; height: 8; radius: 4
            color: Appearance.colors.colPrimary
            property var pt: root.points1.length > 0 ? root.points1[Math.floor(container.progress * (root.points1.length - 1))] : null
            x: pt ? pt.x - 4 : 0
            y: pt ? pt.y - 4 : 0
            visible: pt !== null

            Rectangle {
                anchors.centerIn: parent
                width: 16; height: 16; radius: 8
                color: parent.color
                opacity: 0.4
                z: -1
            }
        }

        // Particle 2 (Slightly Diverged Path)
        Rectangle {
            width: 8; height: 8; radius: 4
            color: Appearance.colors.colPrimary
            opacity: 0.7
            property var pt: root.points2.length > 0 ? root.points2[Math.floor(container.progress * (root.points2.length - 1))] : null
            x: pt ? pt.x - 4 : 0
            y: pt ? pt.y - 4 : 0
            visible: pt !== null

            Rectangle {
                anchors.centerIn: parent
                width: 16; height: 16; radius: 8
                color: parent.color
                opacity: 0.3
                z: -1
            }
        }

        // Particle 3 (More Diverged Path)
        Rectangle {
            width: 6; height: 6; radius: 3
            color: Appearance.colors.colOutlineVariant
            opacity: 0.5
            property var pt: root.points3.length > 0 ? root.points3[Math.floor(container.progress * (root.points3.length - 1))] : null
            x: pt ? pt.x - 3 : 0
            y: pt ? pt.y - 3 : 0
            visible: pt !== null

            Rectangle {
                anchors.centerIn: parent
                width: 12; height: 12; radius: 6
                color: parent.color
                opacity: 0.2
                z: -1
            }
        }
    }
}
