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
    id: basemenu
    visible: inner_popup.visible
    focus: inner_popup.visible
    
    signal open()
    signal selected(string item)
    signal close()

    onVisibleChanged: {
        if (visible) {
            this.forceActiveFocus()
        }
    }
    Keys.onDownPressed: {

        placeholder.currentIndex = placeholder.currentIndex < placeholder.count - 1 ? placeholder.currentIndex + 1: app_list.count - 1;
    }
    Keys.onUpPressed: {
        placeholder.currentIndex = placeholder.currentIndex <= 0 ? 0: placeholder.currentIndex - 1;
    }
    Keys.onPressed: {
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
        inner_popup.open()
    }
    onClose: {
        inner_popup.close()
    }


    Popup {
        id: inner_popup
        default property alias contents: placeholder.model
        // anchors.fill: parent
        width: 800
        height: 600
        parent: Overlay.overlay
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2



        BodyText {
            text: basemenu.instructions
        }

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
            


                delegate: Rectangle {
                id: rect
                visible: inner_popup.visible

                height: 40
                property bool isBlue: false
                property int indexOfThisDelegate: index
                property string nameOfThisDelegate: dataEntry
            
                color: rect.ListView.isCurrentItem ? Qt.lighter(Material.primary, 0.9): Qt.lighter(Material.primary, .7)
                width: rect.ListView.isCurrentItem ? parent.width: parent.width - 35
                BodyText {
                    visible: inner_popup.visible

                    id: nameTxt
                    text: dataEntry
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
