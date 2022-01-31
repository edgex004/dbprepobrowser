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
        repo.debFileMissing.connect(debnotfound.open)
    }

    function openReadme(){
        readmePopup.open()
    }
    
    function openAptLog(){
        aptLogPopup.open()
    }

    BaseDialog {
        id: mountselectfailed
        notifyText: "Selected mount point is no longer available."
    }
    
    BaseDialog {
        id: debnotfound
        notifyText: "A deb library could not be found. Please check apt log for details."
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
    
    BaseDialog {
        id: aptLogPopup
        Component.onCompleted: {
            repo.onApt_log_changed.connect(updateReadme)
        }
        function updateReadme(log)
        {
            notifyText = log
        }
    }

}


