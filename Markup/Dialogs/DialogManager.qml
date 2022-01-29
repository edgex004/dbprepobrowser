import QtQuick 2.0
import QtQuick.Layouts 1.0
import "../../Style"
import QtQml.Models 2.15

Item {
    id: dialogManager
    property bool dialogOpen: false

    onDialogOpenChanged: {
        if (!this.dialogOpen){
            for (var i = 0; i < notifcationmanager.length; i++) {
                if (notifcationmanager.children[i].visible) {
                    this.dialogOpen = true
                }
            }
        }
    }

    Component.onCompleted: {
        repo.mountSelectionMissing.connect(mountselectfailed.open)
    }

    function openReadme(){
        readmePopup.open()
    }

    BaseDialog {
        id: mountselectfailed
        notifyText: "Selected mount point is no longer available."
    }

    BaseDialog {
        id: readmePopup
        Component.onCompleted: {
            repo.onReadmeChanged.connect(updateReadme)
        }
        function updateReadme(readme)
        {
            notifyText = readme
        }
    }

}


