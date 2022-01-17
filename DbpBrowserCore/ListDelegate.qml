import QtQuick 2.15
import QtQuick.Controls.Material 2.14
import "../Style"  

Rectangle {
            height: 50
            property int indexOfThisDelegate: index
            property string nameOfThisDelegate: name

            color: this.ListView.isCurrentItem ? Qt.lighter(Material.primary, 0.9): Qt.lighter(Material.primary, .7)

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mainWindow.dbp_highlighted = parent.dataOfThisDelegate
                    app_list.currentIndex = parent.indexOfThisDelegate
                }
            }



        }