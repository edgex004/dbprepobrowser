import QtQuick 2.0
import QtQuick.Layouts 1.0
import "../../Style"
import QtQml.Models 2.15

BaseMenu {
    id: toplevelmenu

    model:
    ListModel {
        ListElement {
            property string dataEntry: "Refresh"
        }
        ListElement {
            property string dataEntry: "Toggle Fullscreen"
        }
        ListElement {
            property string dataEntry: "Apt Log"
        }
        ListElement {
            property string dataEntry: "Exit"
        }
    }

    Component.onCompleted: {
        this.onSelected.connect(this.select)
    }
    function select(name)
    {
        console.log("selected " + name)
        if (name === "Refresh") {
            repo.refresh()
        } else if (name === "Toggle Fullscreen") {
            if (mainWindow.visibility === 5){
                mainWindow.visibility = "Windowed"
            } else {
                mainWindow.visibility = "FullScreen"
            }
        } else if (name === "Apt Log") {
            dialogManager.openAptLog()
        } else if (name === "Exit") {
            Qt.callLater(Qt.quit)
        }
    }

}


