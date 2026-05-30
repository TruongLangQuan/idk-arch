import qs.modules.common
import qs.modules.common.widgets
import qs.services
import qs.modules.ii.sidebarRight.notifications
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    radius: Appearance.rounding.small
    color: Appearance.colors.colLayer1
    border.width: 1
    border.color: Appearance.colors.colOutlineVariant

    NotificationList {
        anchors.fill: parent
        anchors.margins: 5
    }
}
