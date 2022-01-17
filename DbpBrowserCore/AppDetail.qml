import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtQml.Models 2.1
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import "../Style"

Item {
    Layout.fillHeight: true
    Layout.fillWidth: true
    width: parent.width

    ColumnLayout {
        Layout.fillHeight: true
        Layout.fillWidth: true

        width: parent.width
        RowLayout {
            id: app_row
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumWidth: parent.width

            ColumnLayout {
                id: app_view
                Layout.minimumHeight: 25
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.maximumWidth: parent.width
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: Qt.lighter(Material.background, 1)
                    Rectangle {
                        anchors.margins: 20
                        width: parent.width-40
                        height: parent.height-40
                        anchors.left: parent.left
                        anchors.top: parent.top
                        color: parent.color

                        ColumnLayout {
                            width: parent.width

                            TitleText {
                                Layout.fillHeight: true
                                Layout.fillWidth: true

                                text: mainWindow.dbp_highlighted.name
                                width: parent.width
                            }
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.maximumWidth: parent.width
                            Layout.maximumHeight: parent.height

                            ListView {
                                id: photo_list
                                property int lastItem: 0
                                Layout.maximumWidth: parent.width
                                Layout.preferredWidth: parent.width
                                Layout.preferredHeight: (380)* 720 / 1280 + 50

                                Layout.minimumHeight: 25
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                cacheBuffer: 100
                                spacing: 10
                                orientation: ListView.Horizontal
                                focus: visible



                                delegate: Rectangle {
                                width: 380
                                height: (380)* 720 / 1280
                                property string source: dataEntry

                                color: this.ListView.isCurrentItem ? Material.accent: "transparent"
                                DownloadableImage {
                                    source: parent.source
                                    desiredwidth: 380
                                    snapToSize: true
                                    anchors.centerIn: parent
                                    color: Material.background
                                    onHeightChanged: {
                                        this.parent.height = this.height+4
                                    }
                                    onWidthChanged: {
                                        this.parent.width = this.width+4
                                    }
                                }
                            }

                            Keys.onDownPressed: {
                                option_list.forceActiveFocus()
                                option_list.currentIndex = 0
                                lastItem = currentIndex
                                currentIndex = -1
                            }
                            Keys.onPressed: {
                                if (event.key === Qt.Key_Return)
                                {
                                    zoom_image.source = photo_list.currentItem.source
                                    top_stack.gotoZoomPhoto()
                                }
                                else if (event.key === Qt.Key_Back || event.key == Qt.Key_Escape)
                                {
                                    option_list.currentIndex = -1
                                    stack.currentIndex = 0
                                }
                            }
                            signal left()
                            onLeft: {
                                photo_list.currentIndex = photo_list.currentIndex <= 0 ? 0: photo_list.currentIndex - 1;
                                zoom_image.source = photo_list.currentItem.source

                            }
                            signal right()
                            onRight: {
                                photo_list.currentIndex = photo_list.currentIndex < photo_list.count - 1 ? photo_list.currentIndex + 1: photo_list.count - 1;
                                zoom_image.source = photo_list.currentItem.source

                            }
                            Component.onCompleted: {
                                zoom_image.left.connect(left)
                                zoom_image.right.connect(right)
                            }

                            model: screenshotList
                        }
                        RowLayout {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            ColumnLayout {
                                Layout.preferredWidth: parent.width/2

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
                                    Layout.maximumHeight: 300
                                    Layout.maximumWidth: parent.width
                                    text: mainWindow.dbp_highlighted.description
                                    elide: Text.ElideRight
                                    maximumLineCount: 10
                                }
                            }

                            ListView {
                                id: option_list
                                currentIndex: -1

                                function select(option)
                                {
                                    if (option == "Install")
                                    {

                                } else if (option == "Readme"){
                                console.log("open readme")
                                readme_popup.open()
                            }
                        }
                        Keys.onDownPressed: {
                            option_list.currentIndex = option_list.currentIndex < option_list.count - 1 ? option_list.currentIndex + 1: option_list.count - 1;
                        }
                        Keys.onUpPressed: {
                            if (option_list.currentIndex <= 0)
                            {
                                option_list.currentIndex = -1
                                photo_list.forceActiveFocus()
                                photo_list.currentIndex = photo_list.lastItem
                            } else {
                            option_list.currentIndex = option_list.currentIndex <= 0 ? 0: option_list.currentIndex - 1;
                        }
                    }
                    Keys.onPressed: {
                        if (event.key === Qt.Key_Return)
                        {
                            // console.log("focus app info")
                            // mainWindow.app_focused=true
                            console.log("selected " + option_list.currentItem)
                            console.log("selected " + option_list.currentItem.name)
                            select(option_list.currentItem.nameOfThisDelegate)
                        }
                        else if (event.key === Qt.Key_Back || event.key == Qt.Key_Escape)
                        {
                            option_list.currentIndex = -1
                            stack.currentIndex = 0
                        }
                    }

                    Layout.minimumHeight: 25
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    cacheBuffer: 100
                    spacing: 10


                    delegate: ListDelegate {
                    id: rect
                    width: rect.ListView.isCurrentItem ? option_list.width: option_list.width - 35
                    property int indexOfThisDelegate: index
                    property string nameOfThisDelegate: name
                    property string idOfThisDelegate: id
                    property var dataOfThisDelegate: rawdata
                    RowLayout {
                        BodyText {
                            id: nameTxt
                            text: name
                            Layout.leftMargin: 20
                        }
                    }

                }
                model: ListModel {
                ListElement {
                    name: "Install"
                }
                ListElement {
                    name: "Readme"
                }

            }
        }

    }




}
}

}
}

}
}
Popup {
    id: readme_popup
    width: 800
    height: 600
    parent: Overlay.overlay
    ScrollView{
    width: 760
    height: 560
    x:20
    y:20
    clip: true
    BodyText {
        id: readme_text
        wrapMode: Text.Wrap
        width: 760

        Component.onCompleted: {
            repo.onReadmeChanged.connect(updateReadme)
            // readme_text.newReadme.connect(updateReadme)
        }
        function updateReadme(readme)
        {
            text = readme
        }
    }
    }
}
}
