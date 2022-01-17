import QtQuick 2.0
import QtQuick.Layouts 1.0
import "../Style"
import QtQml.Models 2.15
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14

Item {
    property var model
    anchors.fill: parent
    id: basemenu
    visible: inner_popup.visible
    focus: inner_popup.visible
    signal open()
    signal selected(string item)

    Keys.onDownPressed: {
        console.log("caught down key")

        placeholder.currentIndex = placeholder.currentIndex < placeholder.count - 1 ? placeholder.currentIndex + 1: app_list.count - 1;
    }
    Keys.onUpPressed: {
        placeholder.currentIndex = placeholder.currentIndex <= 0 ? 0: placeholder.currentIndex - 1;
    }
    Keys.onPressed: {
        console.log("caught key")
        if (event.key === Qt.Key_Return)
        {
            selected(placeholder.currentItem.nameOfThisDelegate)
        }
        else if (event.key === Qt.Key_Escape)
        {
            toplevelmenu.close()
        }
    }
    onOpen: {
        console.log("Open called")
        inner_popup.open()
    }

    Popup {
        id: inner_popup
        default property alias contents: placeholder.model
        // anchors.fill: parent
        width: 800
        height: 600
        parent: Overlay.overlay


        Rectangle {
            anchors.margins: Style.popup_margin
            anchors.fill: parent
            radius: Style.corner_radius
            color: Material.background



            ListView {
                id: placeholder
                anchors.fill: parent
                visible: inner_popup.visible
                cacheBuffer: 100
                model: basemenu.model
                spacing: 10
                onVisibleChanged: {
                    console.log("Listview visible change to " + visible)
                }
                delegate: Rectangle {
                id: rect
                visible: inner_popup.visible

                width: parent.width
                radius: 5
                anchors.horizontalCenter: parent.horizontalCenter
                height: 40
                property bool isBlue: false
                property int indexOfThisDelegate: index
                property string nameOfThisDelegate: name
                onVisibleChanged: {
                    console.log("Rectangle visible change to " + visible)
                }
                //     color: rectMouse.containsPress ? "blue": Qt.lighter("#6bdce4", 0.8)
                color: rect.ListView.isCurrentItem ? Qt.lighter(Material.primary, 0.4): Qt.lighter(Material.primary, 0.8)
                Text {
                    visible: inner_popup.visible

                    id: nameTxt
                    text: name
                    font.pointSize: 12
                    color: Material.foreground
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                }

                MouseArea {
                    id: rectMouse
                    anchors.fill: parent
                    onClicked: {
                        placeholder.currentIndex = rect.indexOfThisDelegate
                        basemenu.selected(placeholder.currentItem.nameOfThisDelegate)
                    }
                }
            }
        }

    }
}
}
