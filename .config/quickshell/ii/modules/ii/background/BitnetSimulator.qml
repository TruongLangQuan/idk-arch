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

    // Network Topology: 4 layers
    readonly property var layerCounts: [4, 6, 6, 3]
    readonly property real paddingX: 120
    readonly property real paddingY: 100

    // Coordinates of all nodes
    // Organized as nodes[layerIndex][nodeIndex] = { x, y }
    property var nodes: []

    function calculateNodePositions() {
        if (width <= 0 || height <= 0) return;

        let newNodes = [];
        let numLayers = layerCounts.length;

        for (let l = 0; l < numLayers; l++) {
            let layerNodes = [];
            let count = layerCounts[l];
            let x = paddingX + l * (width - 2 * paddingX) / (numLayers - 1);

            for (let n = 0; n < count; n++) {
                let y = paddingY + n * (height - 2 * paddingY) / (count - 1);
                layerNodes.push({ x: x, y: y, active: 0.0 });
            }
            newNodes.push(layerNodes);
        }
        nodes = newNodes;
        
        // Re-initialize pulses
        initPulses();
    }

    onWidthChanged: calculateNodePositions()
    onHeightChanged: calculateNodePositions()

    // Synapse Connection Lines (drawn via GPU vector shapes)
    Shape {
        id: synapsesShape
        anchors.fill: parent
        opacity: 0.15
        visible: root.nodes.length > 0

        Repeater {
            model: root.nodes.length - 1 // Layers 0, 1, 2

            delegate: Item {
                id: srcLayerItem
                readonly property int srcL: index
                readonly property var srcNodes: root.nodes[srcL]
                readonly property var dstNodes: root.nodes[srcL + 1]

                Repeater {
                    model: srcNodes ? srcNodes.length : 0
                    delegate: Item {
                        id: srcNodeItem
                        readonly property int srcN: index
                        readonly property var srcPt: srcNodes[srcN]

                        Repeater {
                            model: dstNodes ? dstNodes.length : 0
                            delegate: ShapePath {
                                strokeColor: Appearance.colors.colPrimary
                                strokeWidth: 1.0
                                fillColor: "transparent"

                                readonly property var dstPt: dstNodes[index]
                                PathLine {
                                    x: srcPt ? srcPt.x : 0
                                    y: srcPt ? srcPt.y : 0
                                }
                                PathLine {
                                    x: dstPt ? dstPt.x : 0
                                    y: dstPt ? dstPt.y : 0
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Active Neural Pulses traveling between layers
    property var activePulses: []

    function initPulses() {
        if (nodes.length === 0) return;
        let pList = [];
        // Spawn 10 active pulses in staggered stages
        for (let i = 0; i < 10; i++) {
            let l = Math.floor(Math.random() * (layerCounts.length - 1));
            let srcN = Math.floor(Math.random() * layerCounts[l]);
            let dstN = Math.floor(Math.random() * layerCounts[l + 1]);
            let isPositive = Math.random() > 0.5;

            pList.push({
                layer: l,
                srcNode: srcN,
                dstNode: dstN,
                progress: Math.random(), // Stagger positions
                label: isPositive ? "+1" : "-1",
                speed: 1600 + Math.random() * 800
            });
        }
        activePulses = pList;
    }

    // Update pulses along connections
    Timer {
        id: pulseTimer
        interval: 16
        running: true
        repeat: true
        onTriggered: {
            if (nodes.length === 0 || activePulses.length === 0) return;

            let updated = [];
            for (let i = 0; i < activePulses.length; i++) {
                let p = activePulses[i];
                p.progress += 0.008 * (1600 / p.speed);

                // Check mouse collision with nodes to trigger active glow
                if (mouseTracker.containsMouse) {
                    let mx = mouseTracker.mouseX;
                    let my = mouseTracker.mouseY;
                    for (let l = 0; l < nodes.length; l++) {
                        for (let n = 0; n < nodes[l].length; n++) {
                            let nodePt = nodes[l][n];
                            let dx = mx - nodePt.x;
                            let dy = my - nodePt.y;
                            let dist = Math.sqrt(dx * dx + dy * dy);
                            if (dist < 40) {
                                nodePt.active = 1.0; // Light up node under cursor!
                                // Spawn pulse from this node if input/hidden layer
                                if (l < nodes.length - 1 && Math.random() < 0.05) {
                                    updated.push({
                                        layer: l,
                                        srcNode: n,
                                        dstNode: Math.floor(Math.random() * layerCounts[l+1]),
                                        progress: 0.0,
                                        label: Math.random() > 0.5 ? "+1" : "-1",
                                        speed: 1400 + Math.random() * 600
                                    });
                                }
                            }
                        }
                    }
                }

                // If pulse reached destination node
                if (p.progress >= 1.0) {
                    // Light up destination node
                    if (nodes[p.layer + 1] && nodes[p.layer + 1][p.dstNode]) {
                        nodes[p.layer + 1][p.dstNode].active = 0.8;
                    }

                    // Feedforward progression
                    let nextL = p.layer + 1;
                    if (nextL < layerCounts.length - 1) {
                        p.layer = nextL;
                        p.srcNode = p.dstNode;
                        p.dstNode = Math.floor(Math.random() * layerCounts[nextL + 1]);
                        p.progress = 0.0;
                        p.label = Math.random() > 0.5 ? "+1" : "-1";
                        p.speed = 1600 + Math.random() * 800;
                    } else {
                        // Warp pulse back to input layer
                        p.layer = 0;
                        p.srcNode = Math.floor(Math.random() * layerCounts[0]);
                        p.dstNode = Math.floor(Math.random() * layerCounts[1]);
                        p.progress = 0.0;
                        p.label = Math.random() > 0.5 ? "+1" : "-1";
                        p.speed = 1600 + Math.random() * 800;
                    }
                }

                // Node decay step
                for (let l = 0; l < nodes.length; l++) {
                    for (let n = 0; n < nodes[l].length; n++) {
                        if (nodes[l][n].active > 0.0) {
                            nodes[l][n].active -= 0.03;
                        }
                    }
                }

                updated.push(p);
            }

            // Cap pulse count to prevent overhead
            if (updated.length > 25) {
                updated = updated.slice(0, 25);
            }

            activePulses = updated;
            pulseRepeater.model = [];
            pulseRepeater.model = activePulses;
            nodesRepeater.model = [];
            nodesRepeater.model = nodes;
        }
    }

    // Render traveling pulses
    Repeater {
        id: pulseRepeater
        model: root.activePulses

        delegate: Item {
            id: pulseItem
            readonly property var srcPt: root.nodes[modelData.layer] ? root.nodes[modelData.layer][modelData.srcNode] : null
            readonly property var dstPt: root.nodes[modelData.layer + 1] ? root.nodes[modelData.layer + 1][modelData.dstNode] : null

            x: srcPt && dstPt ? srcPt.x + modelData.progress * (dstPt.x - srcPt.x) : 0
            y: srcPt && dstPt ? srcPt.y + modelData.progress * (dstPt.y - srcPt.y) : 0
            visible: srcPt !== null && dstPt !== null

            // Glowing Pulse Bob
            Rectangle {
                width: 6; height: 6; radius: 3
                color: Appearance.colors.colPrimary
                anchors.centerIn: parent

                Rectangle {
                    anchors.centerIn: parent
                    width: 14; height: 14; radius: 7
                    color: parent.color
                    opacity: 0.4
                    z: -1
                }
            }

            // Binary Weight label floating along
            Text {
                text: modelData.label
                font.family: "Monocraft"
                font.pixelSize: 10
                font.bold: true
                color: modelData.label === "+1" ? Appearance.colors.colPrimary : Appearance.colors.colSecondary
                opacity: 0.75
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.top
                anchors.bottomMargin: 4
            }
        }
    }

    // Render Neurons/Nodes
    Repeater {
        id: nodesRepeater
        model: root.nodes

        delegate: Item {
            id: layerNodesItem
            readonly property int layerIndex: index
            readonly property var layerData: modelData

            Repeater {
                model: layerData ? layerData.length : 0

                delegate: Item {
                    readonly property var nodePt: layerData[index]
                    x: nodePt ? nodePt.x - 12 : 0
                    y: nodePt ? nodePt.y - 12 : 0
                    width: 24
                    height: 24
                    visible: nodePt !== null

                    // Outer node boundary ring
                    Rectangle {
                        anchors.fill: parent
                        radius: 12
                        color: "transparent"
                        border.color: Appearance.colors.colPrimary
                        border.width: 1.5
                        opacity: 0.35 + nodePt.active * 0.65

                        // Inner core (glows when active)
                        Rectangle {
                            anchors.centerIn: parent
                            width: 12
                            height: 12
                            radius: 6
                            color: Appearance.colors.colPrimary
                            opacity: 0.15 + nodePt.active * 0.85

                            // Glow Aura
                            Rectangle {
                                anchors.centerIn: parent
                                width: 28; height: 28; radius: 14
                                color: parent.color
                                opacity: nodePt.active * 0.35
                                z: -1
                            }
                        }
                    }
                }
            }
        }
    }
}
