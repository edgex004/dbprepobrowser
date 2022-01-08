import QtQuick 2.0
import QtQuick.Layouts 1.0
import "../Style"
import QtQml.Models 2.15

Item {
    id: basemenu
    default property alias contents: placeholder.model
    anchors.fill: parent
    signal selected(string item)


    Keys.onDownPressed: {
        placeholder.currentIndex = placeholder.currentIndex < placeholder.count - 1 ? placeholder.currentIndex + 1 : app_list.count - 1;
        mainWindow.dbp_highlighted = placeholder.currentItem.nameOfThisDelegate
        repo.update_details(mainWindow.dbp_highlighted)

    }
    Keys.onUpPressed: {
        placeholder.currentIndex = placeholder.currentIndex <= 0 ? 0 : placeholder.currentIndex - 1;
        mainWindow.dbp_highlighted = placeholder.currentItem.nameOfThisDelegate
        repo.update_details(mainWindow.dbp_highlighted)

    }
    Keys.onPressed: {
        if (event.key === Qt.Key_Return) {
            selected(placeholder.currentItem.nameOfThisDelegate)
           }
        else if (event.key === Qt.Key_Escape){
            basemenu.visible = false
            app_search.forceActiveFocus()
        }
    }
    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.2
    }
    Rectangle {
        anchors.margins: Style.popup_margin
        anchors.fill: parent
        radius: Style.corner_radius
        color: Style.bg_color



    ListView {
     id: placeholder
     anchors.fill: parent

     cacheBuffer: 100
     spacing: 10
     visible: !mainWindow.app_focused

    delegate: Rectangle{
     id: rect
     width:  parent.width
     radius: 5
     anchors.horizontalCenter: parent.horizontalCenter
     height: 40
     property bool isBlue: false
     property int indexOfThisDelegate: index
     property string nameOfThisDelegate: name

//     color: rectMouse.containsPress ? "blue" : Qt.lighter("#6bdce4", 0.8)
     color: rect.ListView.isCurrentItem ? Qt.lighter("#6bdce4", 0.4) : Qt.lighter("#6bdce4", 0.8)
     Text {
     id: nameTxt
     text: name
     font.pointSize: 12
     color: "#FFFFFF"
     anchors.left: parent.left
     anchors.leftMargin: 20
     anchors.verticalCenter: parent.verticalCenter
     }

     MouseArea {
     id:rectMouse
     anchors.fill: parent
     onClicked: {
         mainWindow.dbp_highlighted = nameTxt.text
         placeholder.currentIndex = rect.indexOfThisDelegate
         repo.update_details(mainWindow.dbp_highlighted)
     }
     }
}
    }

}
}
