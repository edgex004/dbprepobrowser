import QtQuick 2.0
import QtQuick.Layouts 1.0
import "../Style"
import QtQml.Models 2.15


    BaseMenu{
        id:toplevelmenu
        ListModel{
            ListElement {
                name: "Refresh"
            }
            ListElement {
                name: "Exit"
            }
        }
        onSelected: repo.refresh()
    }


