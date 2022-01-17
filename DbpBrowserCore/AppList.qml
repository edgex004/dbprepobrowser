import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtQml.Models 2.1
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import "../Style"

Item {
    // Drawer {
    //     id: app_drawer
    //     width: parent.width
    //     height: 0.66 * parent.height
    //     edge: Qt.TopEdge
    //     Label {
    //         text: "Content goes here!"
    //         anchors.centerIn: parent
    // }
    // }
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        width: parent.width
        Rectangle {
            color: Qt.lighter(Material.primary, 1)
            Layout.fillWidth: true
            height: 50
            z: 2
            RowLayout {
                id: rowLayout
                anchors.fill: parent
                anchors.centerIn: parent
                TextField {
                    id: app_search
                    focus: visible && !toplevelmenu.visible
                    placeholderText: "Type here.."
                    Layout.fillWidth: true
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    font.family: Style.fontFamily
                    font.pointSize: Style.bodyTextSize
                    color: Material.foreground
                    Keys.forwardTo: [app_row]

                        onTextChanged: {
                            filterModel.setFilterString(text);
                        }
                    }
                    // Button {
                    //     text: "Advanced"
                    //     onClicked: {
                    //         drawer.visible = true
                    // }
                    // }

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
                        function listProperty(item)
                        {
                            for (var p in item)
                            console.log(p + ": " + item[p]);
                        }
                        console.log("focus app info")
                        console.log("focus app info again")

                        listProperty(app_list.currentItem.dataOfThisDelegate)
                        console.log(app_list.currentItem.dataOfThisDelegate.details)
                        console.log("focus app info again")
                        screenshotList.clearDataSlot()
                        repo.update_details(app_list.currentItem.dataOfThisDelegate.details, app_list.currentItem.dataOfThisDelegate.readme)

                        stack.currentIndex = 1
                    }
                    else if (event.key === Qt.Key_Escape)
                    {
                        console.log("app already unfocused")
                        // top_stack.gotoMenu()
                        toplevelmenu.open()
                        // topmenu.forceActiveFocus()
                    }
                    else if (event.key === Qt.Key_Back)
                    {
                        // if (mainWindow.app_focused==false)
                        // {
                        //     console.log("app already unfocused")
                        // } else {
                        //     console.log("unfocus app info")
                        //     mainWindow.app_focused=false
                        // }

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
                    // visible: !mainWindow.app_focused

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
                            if (app_list.currentItem){
                                mainWindow.dbp_highlighted = app_list.currentItem.dataOfThisDelegate
                            }
                        }
                    }

                    delegate: ListDelegate {
                    id: rect
                    width: rect.ListView.isCurrentItem ? app_list.width: app_list.width - 35
                    property int indexOfThisDelegate: index
                    property string nameOfThisDelegate: name
                    property string idOfThisDelegate: id
                    property var dataOfThisDelegate: rawdata

                    RowLayout {
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
                        BodyText {
                            id: nameTxt
                            text: name
                            Layout.leftMargin: 20
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        Image {
                            id: star
                            source: "qrc:/images/star.svg"
                            antialiasing: true
                            visible: false

                        }
                        ColorOverlay {
                            source: star
                            color: Material.foreground
                            antialiasing: true
                            visible: true
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20
                            Layout.bottomMargin: 2

                        }
                        BodyText {
                            text: dataOfThisDelegate.likes
                            Layout.leftMargin: 5
                            Layout.rightMargin: 20

                        }
                        Image {
                            id: arrow
                            source: "qrc:/images/arrow.svg"
                            antialiasing: true
                            visible: false
                        }
                        ColorOverlay {
                            source: arrow
                            color: Material.foreground
                            antialiasing: true
                            visible: rect.ListView.isCurrentItem
                            Layout.preferredWidth: 30
                            Layout.preferredHeight: 30
                        }
                        // Item {
                        //     Layout.preferredWidth: 30
                        //     Layout.preferredHeight: 30
                        //     visible: !rect.ListView.isCurrentItem
                        //     Layout.leftMargin: 20
                        // }


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
                        function listProperty(item)
                        {
                            for (var p in item)
                            console.log(p + ": " + item[p]);
                        }
                        console.log("focus app info")
                        console.log("focus app info again")

                        listProperty(app_list.currentItem.dataOfThisDelegate)
                        console.log(app_list.currentItem.dataOfThisDelegate.details)
                        console.log("focus app info again")
                        repo.update_details(app_list.currentItem.dataOfThisDelegate.details,app_list.currentItem.dataOfThisDelegate.readme)
                        stack.currentIndex = 1

                    }
                    else if (event.key === Qt.Key_Escape)
                    {
                        // console.log("unfocus app info")
                        // mainWindow.app_focused=false
                    }
                }
                //        Layout.preferredWidth: parent.width/2
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: Qt.lighter(Material.background, 1)
                    width: parent.width/2
                    Rectangle {
                        anchors.margins: 20
                        width: parent.width-40
                        height: parent.height-40
                        anchors.left: parent.left
                        anchors.top: parent.top
                        color: parent.color
                        ColumnLayout {
                            TitleText {
                                text: dbp_highlighted.name
                                width: parent.width
                            }
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.maximumWidth: parent.width
                            Layout.maximumHeight: parent.height
                            //                spacing: 10
                            DownloadableImage {
                                source: mainWindow.dbp_highlighted.screenshot
                            }
                            BodyText {
                                text: "Version: " + mainWindow.dbp_highlighted.version
                            }
                            BodyText {
                                text: "Maintainer: " + mainWindow.dbp_highlighted.maintainer
                            }
                            BodyText {
                                text: "Likes: " + mainWindow.dbp_highlighted.likes
                            }
                            BodyText {
                                text: "Downloads: " + mainWindow.dbp_highlighted.downloads
                            }
                            BodyText {
                                id: app_description
                                wrapMode: Text.Wrap
                                Layout.topMargin: 10
                                Layout.fillWidth: true
                                Layout.maximumHeight: 80
                                Layout.maximumWidth: parent.width
                                text: mainWindow.dbp_highlighted.description
                                elide: Text.ElideRight
                                maximumLineCount: 2
                            }



                        }
                    }

                }
            }
        }
    }
}
