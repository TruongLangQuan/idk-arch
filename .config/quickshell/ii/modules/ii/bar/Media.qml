import qs.modules.common
import qs.modules.common.widgets
import qs.services
import qs
import qs.modules.common.functions

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import Quickshell.Hyprland
import Quickshell.Io

Item {
    id: root
    property bool borderless: Config.options.bar.borderless
    readonly property MprisPlayer activePlayer: MprisController.activePlayer
    readonly property string cleanedTitle: StringUtils.cleanMusicTitle(activePlayer?.trackTitle) || Translation.tr("No media")
    property var visualizerPoints: []

    Process {
        id: cavaProc
        running: activePlayer !== null && activePlayer.playbackState === MprisPlaybackState.Playing
        onRunningChanged: {
            if (!running) {
                root.visualizerPoints = [];
            }
        }
        command: ["cava", "-p", `${FileUtils.trimFileProtocol(Directories.scriptPath)}/cava/raw_output_config.txt`]
        stdout: SplitParser {
            onRead: data => {
                let rawPoints = data.split(";").map(p => parseFloat(p.trim())).filter(p => !isNaN(p));
                if (rawPoints.length > 0) {
                    let numBars = 10;
                    let downsampled = new Array(numBars).fill(0);
                    let groupSize = Math.max(1, Math.floor(rawPoints.length / numBars));
                    for (let i = 0; i < numBars; i++) {
                        let sum = 0;
                        let count = 0;
                        let start = i * groupSize;
                        let end = (i === numBars - 1) ? rawPoints.length : (i + 1) * groupSize;
                        for (let j = start; j < end; j++) {
                            sum += rawPoints[j];
                            count++;
                        }
                        downsampled[i] = count > 0 ? (sum / count) : 0;
                    }
                    root.visualizerPoints = downsampled;
                } else {
                    root.visualizerPoints = [];
                }
            }
        }
    }

    Layout.fillHeight: true
    implicitWidth: rowLayout.implicitWidth + rowLayout.spacing * 2
    implicitHeight: Appearance.sizes.barHeight

    Timer {
        running: activePlayer?.playbackState == MprisPlaybackState.Playing
        interval: Config.options.resources.updateInterval
        repeat: true
        onTriggered: activePlayer.positionChanged()
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.MiddleButton | Qt.BackButton | Qt.ForwardButton | Qt.RightButton | Qt.LeftButton
        onPressed: (event) => {
            if (event.button === Qt.MiddleButton) {
                activePlayer.togglePlaying();
            } else if (event.button === Qt.BackButton) {
                activePlayer.previous();
            } else if (event.button === Qt.ForwardButton || event.button === Qt.RightButton) {
                activePlayer.next();
            } else if (event.button === Qt.LeftButton) {
                GlobalStates.mediaControlsOpen = !GlobalStates.mediaControlsOpen
            }
        }
    }

    RowLayout { // Real content
        id: rowLayout

        spacing: 4
        anchors.fill: parent

        ClippedFilledCircularProgress {
            id: mediaCircProg
            Layout.alignment: Qt.AlignVCenter
            lineWidth: Appearance.rounding.unsharpen
            value: activePlayer?.position / activePlayer?.length
            implicitSize: 20
            colPrimary: Appearance.colors.colOnSecondaryContainer
            enableAnimation: false

            Item {
                anchors.centerIn: parent
                width: mediaCircProg.implicitSize
                height: mediaCircProg.implicitSize
                
                MaterialSymbol {
                    anchors.centerIn: parent
                    fill: 1
                    text: activePlayer?.isPlaying ? "pause" : "music_note"
                    iconSize: Appearance.font.pixelSize.normal
                    color: Appearance.m3colors.m3onSecondaryContainer
                }
            }
        }

        StyledText {
            visible: Config.options.bar.verbose
            width: rowLayout.width - (CircularProgress.size + rowLayout.spacing * 2)
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true // Ensures the text takes up available space
            Layout.rightMargin: rowLayout.spacing
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight // Truncates the text on the right
            color: Appearance.colors.colOnLayer1
            text: `${cleanedTitle}${activePlayer?.trackArtist ? ' • ' + activePlayer.trackArtist : ''}`
        }

        RowLayout {
            id: visualizerRow
            spacing: 2
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: 4
            Layout.rightMargin: 4
            implicitWidth: 48
            implicitHeight: 16
            visible: root.visualizerPoints.length > 0 && root.activePlayer?.playbackState === MprisPlaybackState.Playing

            Repeater {
                model: 10
                delegate: Rectangle {
                    required property int index
                    width: 3
                    height: {
                        let val = (root.visualizerPoints && root.visualizerPoints.length > index) ? root.visualizerPoints[index] : 0;
                        let h = 2 + (val / 1000.0) * 14;
                        return Math.max(2, Math.min(16, h));
                    }
                    color: Appearance.colors.colPrimary
                    radius: 1.5

                    Behavior on height {
                        NumberAnimation { duration: 50; easing.type: Easing.OutQuad }
                    }
                }
            }
        }

    }

}
