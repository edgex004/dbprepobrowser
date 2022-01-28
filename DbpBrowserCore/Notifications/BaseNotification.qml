import QtQuick 2.0
import QtQuick.Layouts 1.0
import "../../Style"
import QtQml.Models 2.15
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import ".."

Item {
    property var model
    property string instructions: ""
    anchors.fill: parent
    id: basenotification
    visible: inner_popup.visible
    focus: inner_popup.visible
    signal open()
    signal selected(string item)

    onVisibleChanged: {
        if (!visible) {
            notifcationmanager.notificationOpen = false
        }
    }

    onOpen: {
        inner_popup.open()
    }

    Popup {
        id: inner_popup
        // anchors.fill: parent
        width: 800
        height: 600
        parent: Overlay.overlay


        BodyText {
            text: basenotification.instructions
        }
    }
}
