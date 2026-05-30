import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

MouseArea {
    id: root
    property bool borderless: Config.options.bar.borderless
    readonly property var chargeState: Battery.chargeState
    readonly property bool isCharging: Battery.isCharging
    readonly property bool isPluggedIn: Battery.isPluggedIn
    readonly property real percentage: Battery.percentage
    readonly property bool isLow: percentage <= Config.options.battery.low / 100

    implicitWidth: batteryProgress.implicitWidth
    implicitHeight: Appearance.sizes.barHeight

    hoverEnabled: !Config.options.bar.tooltips.clickToShow

    Text {
        id: batteryProgress
        anchors.centerIn: parent
        font.family: "JetBrains Mono NF"
        font.pixelSize: Appearance.font.pixelSize.small
        color: (isLow && !isCharging) ? Appearance.colors.colError : Appearance.colors.colOnLayer0
        text: `[BAT: ${Math.round(percentage * 100)}%${isCharging ? "+" : ""}]`
    }

    BatteryPopup {
        id: batteryPopup
        hoverTarget: root
    }
}
