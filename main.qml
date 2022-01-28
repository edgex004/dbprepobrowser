import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtQml.Models 2.1
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import QtGamepad 1.0
import "DbpBrowserCore"
import "DbpBrowserCore/Menus"
import "DbpBrowserCore/Notifications"
import "DbpBrowserCore/Widgets"



ApplicationWindow {
    id: mainWindow

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
    onGotoZoomPhoto: {this.currentIndex = 1}

    ColumnLayout {
        RowLayout{
            Layout.fillWidth: true
            ColoredSVG {
                source: "qrc:/images/lbutton.svg"
                Layout.preferredWidth: 60
                Layout.preferredHeight: 40
                Layout.alignment: Qt.AlignVCenter
                color: Qt.lighter(Material.primary, 1.7)
            }
            TabBar {
                id: bar
                Layout.fillWidth: true
                TabButton {
                    text: "Repo"
                }
                TabButton {
                    text: "Installed"
                }
                TabButton {
                    text: "Downloading"
                }
            }
            ColoredSVG {
                source: "qrc:/images/rbutton.svg"
                Layout.preferredWidth: 60
                Layout.preferredHeight: 40
                Layout.alignment: Qt.AlignVCenter
                color: Qt.lighter(Material.primary, 1.7)

            }
        }


        StackLayout {
            width: parent.width
            currentIndex: bar.currentIndex
            AppListTab { 
                model: fullfiltermodel
            }
            AppListTab { 
                model: installedfiltermodel
            }
            AppListTab { 
                model: downloadfiltermodel
            }
        }

    }

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

}
    TopLevelMenu {
        id:toplevelmenu
    }

    InstallMenu {
        id:installmenu
    }

    NotificationManager {
        id:notificationmanager
    }

}
