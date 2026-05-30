import QtQuick
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

    // Shifting center (magnetic pull)
    property real targetX: mouseTracker.containsMouse ? mouseTracker.mouseX : defaultCenterX
    property real targetY: mouseTracker.containsMouse ? mouseTracker.mouseY : defaultCenterY

    // Proximity factor (0.0 to 1.0)
    readonly property real proximity: {
        if (!mouseTracker.containsMouse) return 0.0;
        const dx = mouseTracker.mouseX - defaultCenterX;
        const dy = mouseTracker.mouseY - defaultCenterY;
        const dist = Math.sqrt(dx * dx + dy * dy);
        const maxDist = Math.sqrt(defaultCenterX * defaultCenterX + defaultCenterY * defaultCenterY);
        return Math.max(0.0, 1.0 - (dist / (maxDist * 0.4)));
    }

    Item {
        id: atomContainer
        x: targetX
        y: targetY

        Behavior on x {
            SpringAnimation { spring: 2.0; damping: 0.8 }
        }
        Behavior on y {
            SpringAnimation { spring: 2.0; damping: 0.8 }
        }

        // Nucleus (Cluster of Protons and Neutrons)
        Item {
            id: nucleus
            anchors.centerIn: parent

            Repeater {
                model: 8
                delegate: Rectangle {
                    width: 14 + Math.random() * 4
                    height: width
                    radius: width / 2
                    color: index % 2 === 0 ? Appearance.colors.colPrimary : Appearance.colors.colOutlineVariant
                    opacity: 0.95

                    readonly property real angle: (index / 8) * 2 * Math.PI
                    readonly property real offsetDist: 10 + 6 * Math.sin(pulsateAnimation.progress * 2 * Math.PI)
                    x: offsetDist * Math.cos(angle) - radius / 2
                    y: offsetDist * Math.sin(angle) - radius / 2
                }
            }

            Rectangle {
                anchors.centerIn: parent
                width: 45; height: 45; radius: 22.5
                color: Appearance.colors.colPrimary
                opacity: 0.12
                z: -1
            }

            NumberAnimation {
                id: pulsateAnimation
                target: pulsateAnimation
                property: "progress"
                from: 0
                to: 1
                duration: 3000
                loops: Animation.Infinite
                running: true
                property real progress: 0
            }
        }

        // Three tilted electron orbits
        Repeater {
            model: [
                { angle: 15, duration: 2500, size: 280, color: Appearance.colors.colPrimary },
                { angle: 75, duration: 3200, size: 340, color: Appearance.colors.colPrimary },
                { angle: 135, duration: 4000, size: 400, color: Appearance.colors.colPrimary }
            ]

            delegate: Item {
                id: orbitItem
                width: modelData.size
                height: modelData.size
                anchors.centerIn: parent

                rotation: modelData.angle + root.proximity * 25
                transform: Scale {
                    id: orbitScale
                    yScale: 0.25 + root.proximity * 0.15
                    Behavior on yScale {
                        SpringAnimation { spring: 1.5; damping: 0.7 }
                    }
                }

                Behavior on rotation {
                    SpringAnimation { spring: 1.5; damping: 0.7 }
                }

                // Orbit track ring
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    border.color: modelData.color
                    border.width: 1.5
                    opacity: 0.25 + root.proximity * 0.25
                }

                // Electron container that rotates (GPU render thread)
                Item {
                    anchors.fill: parent
                    
                    RotationAnimator on rotation {
                        from: 0
                        to: 360
                        duration: modelData.duration
                        loops: Animation.Infinite
                        running: true
                    }

                    // Electron (small glowing dot)
                    Rectangle {
                        width: 10
                        height: 10
                        radius: 5
                        color: modelData.color
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top

                        transform: Scale {
                            yScale: 1.0 / orbitScale.yScale
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: 20; height: 20; radius: 10
                            color: parent.color
                            opacity: 0.4
                            z: -1
                        }
                    }
                }
            }
        }
    }
}
