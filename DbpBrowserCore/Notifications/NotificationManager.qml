import QtQuick 2.0
import QtQuick.Layouts 1.0
import "../../Style"
import QtQml.Models 2.15

Item {
    id: notificationmanager
    property bool notificationOpen: false

    onNotificationOpenChanged: {
        if (!this.notificationOpen){
            for (var i = 0; i < notifcationmanager.length; i++) {
                if (notifcationmanager.children[i].visible) {
                    this.notificationOpen = true
                }
            }
        }
    }

    Component.onCompleted: {
        repo.mountSelectionMissing.connect(mountselectfailed.open)
    }

    BaseNotification {
        id: mountselectfailed
        instructions: "Selected mount point is no longer available."
    }

}


