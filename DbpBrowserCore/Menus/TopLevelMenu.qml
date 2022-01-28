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
            property string dataEntry: "Exit"
        }
    }

    Component.onCompleted: {
        this.onSelected.connect(this.select)
    }
    function select(name)
    {
        console.log("selected " + name)
        if (name == "Refresh") {
            repo.refresh()
        } else if (name =="Exit") {
            Qt.callLater(Qt.quit)
        }
    }

}


