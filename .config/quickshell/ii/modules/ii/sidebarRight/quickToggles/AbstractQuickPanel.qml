import QtQuick
import qs.modules.common

Rectangle {
    id: root

    radius: Appearance.rounding.small
    color: Appearance.colors.colLayer1
    border.width: 1
    border.color: Appearance.colors.colOutlineVariant

    signal openAudioOutputDialog()
    signal openAudioInputDialog()
    signal openBluetoothDialog()
    signal openNightLightDialog()
    signal openWifiDialog()
}
