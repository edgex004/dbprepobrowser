import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtQml.Models 2.1
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import "../Style"  

    Item{
        id: applisttab

    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        width: parent.width
        Rectangle {
            color: Material.primary
            Layout.fillWidth: true
            height: 40
            z: 2
            RowLayout {
                id: rowLayout
                anchors.fill: parent
                anchors.centerIn: parent
                TextField {
                    id: app_search
                    focus: visible
                    placeholderText: "Type here.."
                    Layout.fillWidth: true
                    Layout.leftMargin: 10
                    font.pointSize: 12
                    Keys.forwardTo: [app_row]

                        onTextChanged: {
                            filterModel.setFilterString(text);
                        }
                    }
                    CheckBox {
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        text: "Descending"
                        onCheckedChanged: {
                            filterModel.setSortOrder(checked)
                        }
                    }
                }
            }
            RowLayout {
                id: app_row
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.maximumWidth: parent.width
                Keys.onDownPressed: {
                        app_list.currentIndex = app_list.currentIndex < app_list.count - 1 ? app_list.currentIndex + 1: app_list.count - 1;
                        mainWindow.dbp_highlighted = app_list.currentItem.dataOfThisDelegate
                    }
                    Keys.onUpPressed: {
                        app_list.currentIndex = app_list.currentIndex <= 0 ? 0: app_list.currentIndex - 1;
                        mainWindow.dbp_highlighted = app_list.currentItem.dataOfThisDelegate
                    }
                    Keys.onPressed: {
                        if (event.key === Qt.Key_Return)
                        {
                            console.log("focus app info")
                            mainWindow.app_focused=true
                        }
                        else if (event.key === Qt.Key_Escape)
                        {
                            console.log("app already unfocused")
                            topmenu.visible=true
                            topmenu.forceActiveFocus()
                        }
                        else if (event.key === Qt.Key_Back)
                        {
                            if (mainWindow.app_focused==false)
                            {
                                console.log("app already unfocused")
                            } else {
                                console.log("unfocus app info")
                                mainWindow.app_focused=false
                            }

                        }
                    }

        ListView {
            id: app_list
            model: filterModel
            Layout.minimumHeight: 25
            Layout.fillHeight: true
            Layout.fillWidth: true
            cacheBuffer: 100
            spacing: 10
            visible: !mainWindow.app_focused

            //     filterModel {
            //         onFilterUpdated: app_list.currentIndex = 0
            // }

            Connections {
                target: filterModel
                function onFilterUpdated()
                {
                    app_list.currentIndex = 0
                    mainWindow.dbp_highlighted = app_list.currentItem.dataOfThisDelegate

                }
            }
            Connections {
                target: repo
                function onRepoRefreshed()
                {
                    app_list.currentIndex = 0
                    mainWindow.dbp_highlighted = app_list.currentItem.dataOfThisDelegate
                }
            }

            delegate: Rectangle {
            id: rect
            width: app_list.width
            // anchors.horizontalCenter: parent.horizontalCenter
            height: 40
            property bool isBlue: false
            property int indexOfThisDelegate: index
            property string nameOfThisDelegate: name
            property string idOfThisDelegate: id
            property var dataOfThisDelegate: rawdata

            color: rect.ListView.isCurrentItem ? Qt.lighter(Material.primary, 0.4): Qt.lighter(Material.primary, 0.8)
            RowLayout{
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter

            Image {
                cache: true
                source: dataOfThisDelegate.icon
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                fillMode: Image.PreserveAspectFit
                Layout.leftMargin: 20

            }
            Text {
                id: nameTxt
                text: name
                // font.pointSize: 12
                color: Material.foreground
                Layout.leftMargin: 20
            }
            Item{
                Layout.fillWidth: true
            }
            Image {
                id: test
                source: "qrc:/images/star.svg"
                antialiasing: true
                visible: false
            }
            ColorOverlay {
                source:test
                color:Material.foreground
                antialiasing: true
                visible: rect.ListView.isCurrentItem
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
            }
            Text {
                text: dataOfThisDelegate.likes
                // font.pointSize: 12
                color: Material.foreground
                Layout.rightMargin: 20
            }
            Image {
                id: test
                source: "qrc:/images/arrow.svg"
                antialiasing: true
                visible: false
            }
            ColorOverlay {
                source:test
                color:Material.foreground
                antialiasing: true
                visible: rect.ListView.isCurrentItem
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                Layout.leftMargin: 20
            }
            Item {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                visible: !rect.ListView.isCurrentItem
                Layout.leftMargin: 20
            }


            }

            MouseArea {
                id: rectMouse
                anchors.fill: parent
                onClicked: {
                    mainWindow.dbp_highlighted = rect.dataOfThisDelegate
                    app_list.currentIndex = rect.indexOfThisDelegate
                }
            }



        }
            
        }
    ColumnLayout {
        id: app_view
        Layout.minimumHeight: 25
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.maximumWidth: parent.width/2
        Keys.onPressed: {
            if (event.key === Qt.Key_Return)
            {
            console.log("focus app info")
            mainWindow.app_focused=true
            }
            else if (event.key === Qt.Key_Escape)
            {
            console.log("unfocus app info")
            mainWindow.app_focused=false
            }
        }
    //        Layout.preferredWidth: parent.width/2
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: Qt.lighter(Material.primary, 0.8)
            width: parent.width/2
            Rectangle {
                anchors.margins: 20
                width: parent.width-40
                height: parent.height-40
                anchors.left: parent.left
                anchors.top: parent.top
                color: parent.color
                ColumnLayout {
                Text {
                text: dbp_highlighted.name
                font.pointSize: 20
                color: Material.foreground
                width: parent.width
                //        anchors.verticalCenter: parent.verticalCenter
            }
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.maximumWidth: parent.width
                    Layout.maximumHeight: parent.height
                    //                spacing: 10
                    DownloadableImage {
                        source: mainWindow.dbp_highlighted.screenshot
                    }
                        Text {
                            color: Material.foreground
                            text: "Version: " + mainWindow.dbp_highlighted.version
                        }
                        Text {
                            color: Material.foreground
                            text: "Maintainer: " + mainWindow.dbp_highlighted.maintainer
                        }
                        Text {
                            color: Material.foreground
                            text: "Likes: " + mainWindow.dbp_highlighted.likes
                        }
                        Text {
                            color: Material.foreground
                            text: "Downloads: " + mainWindow.dbp_highlighted.downloads
                        }
                        Text {
                            id: app_readme
                            wrapMode: Text.Wrap
                            color: Material.foreground
                            Layout.topMargin: 10
                            text: mainWindow.dbp_highlighted.description
                        }

                

                }
            }

        }
    }
}
}
    }