import QtQuick 2.0
import QtQuick.Layouts 1.0
import "../Style"
import QtQml.Models 2.15


    BaseMenu{
        id:toplevelmenu
             model: ListModel{
            ListElement {
                name: "Refresh"
            }
            ListElement {
                name: "Exit"
            }
        }
            Keys.onDownPressed: {
        console.log("Caught down key")
        }
        Component.onCompleted: {
            console.log("connected the select function ")

            this.onSelected.connect(this.select)
        }
        function select(name) {
        console.log("selected " + name)
        if (name == "Refresh"){
            repo.refresh()
        } else if (name =="Exit"){
            Qt.callLater(Qt.quit)
        }
    }

    }


