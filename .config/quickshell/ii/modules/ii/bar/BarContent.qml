import qs.modules.ii.bar.weather
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Services.Mpris
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

Item { // Bar content region
    id: root

    property var screen: root.QsWindow.window?.screen
    property var brightnessMonitor: Brightness.getMonitorForScreen(screen)
    property real useShortenedForm: (Appearance.sizes.barHellaShortenScreenWidthThreshold >= screen?.width) ? 2 : (Appearance.sizes.barShortenScreenWidthThreshold >= screen?.width) ? 1 : 0
    readonly property int centerSideModuleWidth: (useShortenedForm == 2) ? Appearance.sizes.barCenterSideModuleWidthHellaShortened : (useShortenedForm == 1) ? Appearance.sizes.barCenterSideModuleWidthShortened : Appearance.sizes.barCenterSideModuleWidth

    component VerticalBarSeparator: Text {
        Layout.fillHeight: true
        verticalAlignment: Text.AlignVCenter
        text: "│"
        font.family: "JetBrains Mono NF"
        font.pixelSize: Appearance.font.pixelSize.normal
        color: Appearance.colors.colOutlineVariant
    }

    // Background shadow
    Loader {
        active: Config.options.bar.showBackground && Config.options.bar.cornerStyle === 1 && Config.options.bar.floatStyleShadow
        anchors.fill: barBackground
        sourceComponent: StyledRectangularShadow {
            anchors.fill: undefined // The loader's anchors act on this, and this should not have any anchor
            target: barBackground
        }
    }
    // Background
    Rectangle {
        id: barBackground
        anchors {
            fill: parent
            margins: Config.options.bar.cornerStyle === 1 ? (Appearance.sizes.hyprlandGapsOut) : 0 // idk why but +1 is needed
        }
        color: Config.options.bar.showBackground ? Appearance.colors.colLayer0 : "transparent"
        radius: Config.options.bar.cornerStyle === 1 ? Appearance.rounding.windowRounding : 0
        border.width: Config.options.bar.cornerStyle === 1 ? 1 : 0
        border.color: Appearance.colors.colLayer0Border
    }

    // Left Group: Workspace indicator pill floating on the left
    BarGroup {
        id: leftWorkspaceGroup
        anchors {
            left: parent.left
            leftMargin: Appearance.rounding.screenRounding + 10
            verticalCenter: parent.verticalCenter
        }
        Workspaces {
            id: workspacesWidget
            Layout.fillHeight: true
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                onPressed: event => {
                    if (event.button === Qt.RightButton) {
                        GlobalStates.overviewOpen = !GlobalStates.overviewOpen;
                    }
                }
            }
        }
    }

    // Center Group - Media (Music + Visualizer)
    BarGroup {
        id: centerMediaGroup
        visible: MprisController.activePlayer !== null && MprisController.activePlayer.playbackState === MprisPlaybackState.Playing
        width: visible ? implicitWidth : 0
        height: visible ? implicitHeight : 0
        anchors {
            right: centerResourcesGroup.left
            rightMargin: visible ? 10 : 0
            verticalCenter: parent.verticalCenter
        }
        Media {}
    }

    // Center Group: CPU/RAM/Memory indicator pill floating in the middle
    BarGroup {
        id: centerResourcesGroup
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        Resources {
            alwaysShowAllResources: true
        }
    }

    // Right Group: Status indicator pill floating on the right
    BarGroup {
        id: rightStatusGroup
        anchors {
            right: parent.right
            rightMargin: Appearance.rounding.screenRounding + 10
            verticalCenter: parent.verticalCenter
        }

        ClockWidget {
            showDate: true
            Layout.alignment: Qt.AlignVCenter
        }

        VerticalBarSeparator {}

        SysTray {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillHeight: true
            invertSide: Config?.options.bar.bottom
        }

        BatteryIndicator {
            visible: Battery.available
            Layout.alignment: Qt.AlignVCenter
        }

        RowLayout {
            spacing: 10
            Layout.alignment: Qt.AlignVCenter
            Text {
                font.family: "JetBrains Mono NF"
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colOnLayer0
                text: `[VOL: ${Audio.sink?.audio?.muted ? "MUTE" : Math.round((Audio.sink?.audio?.volume ?? 0) * 100) + "%"}]`
            }
            Text {
                font.family: "JetBrains Mono NF"
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colOnLayer0
                text: `[NET: ${Network.ethernet ? "ETH" : (Network.wifiStatus === "connected" ? Network.networkName : "DISC")}]`
            }
            HyprlandXkbIndicator {
                Layout.alignment: Qt.AlignVCenter
                color: Appearance.colors.colOnLayer0
            }
        }

        RippleButton {
            implicitWidth: 44
            implicitHeight: 28
            buttonRadius: Appearance.rounding.small
            onClicked: GlobalStates.sessionOpen = !GlobalStates.sessionOpen
            contentItem: Text {
                anchors.centerIn: parent
                font.family: "JetBrains Mono NF"
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colOnLayer0
                text: "[PWR]"
            }
        }
    }
}
