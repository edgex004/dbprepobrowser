import QtQuick 2.0
import QtQuick.Layouts 1.0
import "../../Style"
import QtQml.Models 2.15
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import ".."

Item {
    property string notifyText: ""
    anchors.fill: parent
    id: baseDialog
    visible: inner_popup.visible
    focus: inner_popup.visible
    signal open()

    onVisibleChanged: {
        dialogManager.dialogOpen = visible
        if (visible)
        {
            this.forceActiveFocus()
        }

    }

    onOpen: {
        inner_popup.open()
    }

    Keys.onUpPressed: {
        flicker.flick(0, 800)
    }
    Keys.onDownPressed: {
        flicker.flick(0, -800)
    }
    Keys.onPressed: {
        if (event.key === Qt.Key_Return)
        {
            inner_popup.close()
        }
    }

    Popup {
        id: inner_popup
        width: 800
        height: 600
        parent: Overlay.overlay
        x: (parent.width - width)/ 2
        y: (parent.height - height)/ 2

        Flickable {
            id: flicker
            width: 760
            height: 560
            contentWidth: readme_text.width; contentHeight: readme_text.height
            boundsBehavior: Flickable.StopAtBounds
            x: 20
            y: 20
            clip: true

            onVisibleChanged: {
                flicker.contentY = 0
            }

            BodyText {
                id: readme_text
                wrapMode: Text.Wrap
                width: 760
                text: baseDialog.notifyText


            }
        }
    }
}
