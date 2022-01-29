import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtQml.Models 2.1
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import "../Style"
import "../Script/logging.js" as LoggingFunctions


Item {
    id: app_detail
    property var target_app_detail
    Layout.fillHeight: true
    Layout.fillWidth: true
    width: parent.width
    onVisibleChanged:{
        if(visible){
            target_app_detail = applisttab.dbp_highlighted
            option_list.currentIndex = -1
            photo_list.shouldfocus = true
            photo_list.forceActiveFocus()
            photo_list.currentIndex = 0
            photo_list.lastItem = 0
        }
    }
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

                                text: applisttab.dbp_highlighted.name
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
                                property bool shouldfocus: true
                                focus: visible && !installmenu.visible && !dialogManager.dialogOpen && shouldfocus
                                


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
                                option_list.shouldfocus = true
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
                                else if (event.key == Qt.Key_Escape || event.key == Qt.Key_Delete)
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
                                    text: "Version: " + applisttab.dbp_highlighted.version
                                }
                                BodyText {
                                    text: "Maintainer: " + applisttab.dbp_highlighted.maintainer
                                }
                                BodyText {
                                    text: "Likes: " + applisttab.dbp_highlighted.likes
                                }
                                BodyText {
                                    text: "Downloads: " + applisttab.dbp_highlighted.downloads
                                }
                                BodyText {
                                    id: app_description
                                    wrapMode: Text.Wrap
                                    Layout.topMargin: 10
                                    Layout.fillWidth: true
                                    Layout.maximumHeight: 300
                                    Layout.maximumWidth: parent.width
                                    text: applisttab.dbp_highlighted.description
                                    elide: Text.ElideRight
                                    maximumLineCount: 10
                                }
                            }

                            ListView {
                                id: option_list
                                currentIndex: -1
                                property bool shouldfocus: false
                                focus: visible && !installmenu.visible && !dialogManager.dialogOpen && shouldfocus

                                function select(option)
                                {
                                    if (option == "Install") {
                                        installmenu.customOpen(applisttab.dbp_highlighted)
                                    } else if (option == "Update") {
                                        repo.upgrade(applisttab.dbp_highlighted.package_id,applisttab.dbp_highlighted.installedDevice)
                                    } else if (option == "Delete") {
                                        repo.delete(applisttab.dbp_highlighted.package_id,applisttab.dbp_highlighted.installedLocation)
                                    } else if (option == "Readme") {
                                        console.log("open readme")
                                        dialogManager.openReadme()
                                    } 
                                    // This seemed like a good idea, but ends up being ugly and not as helpful as I hoped
                                    // else if (option == "Log"){
                                    //     console.log("open log")
                                    //     log_popup.open()
                                    // }
                                }
                        Keys.onDownPressed: {
                            option_list.currentIndex = option_list.currentIndex < option_list.count - 1 ? option_list.currentIndex + 1: option_list.count - 1;
                        }
                        Keys.onUpPressed: {
                            if (option_list.currentIndex <= 0)
                            {
                                option_list.currentIndex = -1
                                photo_list.shouldfocus = true
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
                        else if (event.key == Qt.Key_Escape|| event.key == Qt.Key_Delete)
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
                    // property string idOfThisDelegate: id
                    property var dataOfThisDelegate: rawdata
                    // RowLayout {
                        BodyText {
                            id: nameTxt
                            text: name
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                            anchors.verticalCenter: parent.verticalCenter

                        }
                    // }

                }
            model:     ListModel {
                id:option_model
                Component.onCompleted: {
                    append({name: applisttab.dbp_highlighted.updateAvailable ?  "Update" : "Install"});
                    append({name: "Readme"});
                    applisttab.onDbp_highlightedChanged.connect(this.setText)
                    LoggingFunctions.listProperty(app_detail)
                    app_detail.onVisibleChanged.connect(this.visibleChange)
                }
                function visibleChange() {
                    if(app_detail.visible){
                        option_model.setText()
                        applisttab.dbp_highlighted.onUpdateAvailable_changed.connect(option_model.setText)
                        applisttab.dbp_highlighted.onDownloadPercent_changed.connect(option_model.setText)
                        applisttab.dbp_highlighted.onInstalledLocation_changed.connect(option_model.setText)
                    } else {
                        applisttab.dbp_highlighted.onUpdateAvailable_changed.disconnect(option_model.setText)
                        applisttab.dbp_highlighted.onDownloadPercent_changed.disconnect(option_model.setText)
                        applisttab.dbp_highlighted.onInstalledLocation_changed.disconnect(option_model.setText)
                    }
                }

                function setText() {
                    var top_button = applisttab.dbp_highlighted.downloadPercent ? "Cancel: Downloading... " + applisttab.dbp_highlighted.downloadPercent : 
                        applisttab.dbp_highlighted.updateAvailable ?  "Update" : 
                        applisttab.dbp_highlighted.installedLocation ?  "Delete" : 
                        "Install"
                    setProperty(0,"name", top_button)
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
    id: log_popup
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
        id: log_text
        wrapMode: Text.Wrap
        width: 760
        text: applisttab.dbp_highlighted.downloadLog

    }
    }
}
}
