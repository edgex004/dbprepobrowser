import QtQuick 2.0
import QtQuick.Layouts 1.0
import "../../Style"
import QtQml.Models 2.15
import "../../Script/logging.js" as LoggingFunctions
import ".."
import QtQuick.Controls.Material 2.14

Item{
    id:readOnlyList
    property string title: ""
    property var model
    Layout.fillHeight: true
    Layout.fillWidth: true

        ColumnLayout {
            anchors.fill: parent
            Rectangle {
                BodyText {
                    id:titlebody
                    text: readOnlyList.title
                }
                Layout.fillWidth: true
                Layout.preferredHeight: titlebody.height
                color: Qt.lighter(Material.primary, 1.5)
            }            

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: Material.background
            ListView {
                anchors.fill: parent
                delegate: BodyText {
                    text:dataEntry
                }
                model:readOnlyList.model
            }
        }
    }
    
}

