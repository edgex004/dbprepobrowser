import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtQml.Models 2.1
import QtQuick.Layouts 1.15
// import QtQuick.Controls.Styles 1.4
import QtGamepad 1.0
import "DbpBrowserCore"



ApplicationWindow {
    id: mainWindow
    property var dbp_highlighted: QtObject {
        property string name: ""
        property string version: ""
        property string screenshot: ""
        property string maintainer: ""
        property string likes: ""
        property string downloads: ""
        property string description: ""
        
    }


    property bool app_focused: false

    visible: true
    width: 1280
    height: 720

    title: "DBP Repo Browser"


    Gamepad {
        id: gamepad1
        deviceId: GamepadManager.connectedGamepads.length > 0 ? GamepadManager.connectedGamepads[0]: -1
    }

    Connections {
        target: GamepadManager
        function onGamepadConnected(deviceId)
        {
            console.log("Connected gamepad: "+deviceId)
            gamepad1.deviceId = deviceId
        }
    }

    GamepadKeyNavigation {
        id: gamepadKeyNavigation
        gamepad: gamepad1
        active: true
        buttonBKey: Qt.Key_Return
        buttonAKey: Qt.Key_Back
        buttonYKey: Qt.Key_PageDown
        buttonXKey: Qt.Key_PageUp
        buttonStartKey: Qt.Key_Escape
        buttonSelectKey: Qt.Key_Escape
        onButtonAKeyChanged: {
            console.log("button A changed")
        }
        onLeftKeyChanged: {
            console.log("button left changed")
        }
    }
StackLayout{
    id: top_stack
    signal gotoBase()
    // signal gotoMenu()
    signal gotoZoomPhoto()

    onGotoBase: {this.currentIndex = 0}
    // onGotoMenu: {this.currentIndex = 1}
    onGotoZoomPhoto: {this.currentIndex = 1}

    ColumnLayout {
        anchors.fill: parent
        TabBar {
            id: bar
            width: parent.width
            TabButton {
                text: qsTr("App Repo")
            }
            TabButton {
                text: qsTr("My Apps")
            }
            TabButton {
                text: qsTr("Downloads")
            }
        }

        StackLayout {
            width: parent.width
            currentIndex: bar.currentIndex
            AppListTab { }
            Item {
                id: discoverTab
            }
            Item {
                id: activityTab
            }
        }

    }

    // AppListTab { }


    // TopLevelMenu {
    //     id: topmenu
    //     visible: false
    // }
StackLayout{
DownloadableImage {
// Image {
    id: zoom_image
    // Layout.fillHeight: true
    // Layout.fillWidth: true
    Layout.preferredWidth: 1280
    Layout.preferredHeight: 720
    x:0
    y:0
    desiredwidth: 1280
    visible: true
    // width: parent.width
    // height: parent.height
    focus: visible


    signal right()
    signal left()


    Keys.onRightPressed: {
        zoom_image.right()
    }
    Keys.onLeftPressed: {
        zoom_image.left()
    }
    Keys.onPressed: {
        if (event.key === Qt.Key_Back || event.key == Qt.Key_Escape)
        {
            console.log("Go invisible!")
            top_stack.gotoBase()
        }
    }


}
Rectangle{
        Layout.preferredWidth: 1200
    Layout.preferredHeight: 700
    color:"red"

}
}
    TopLevelMenu {
        id:toplevelmenu
    }
}


}
