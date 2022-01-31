import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtQml.Models 2.1
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import QtGamepad 1.15
import "Markup"
import "Markup/Menus"
import "Markup/Dialogs"
import "Markup/Widgets"
import "Script/logging.js" as LoggingFunctions



ApplicationWindow {
    id: mainWindow

    visible: true
    visibility: "FullScreen"
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
        buttonAKey: Qt.Key_Return
        buttonBKey: Qt.Key_Delete
        buttonYKey: Qt.Key_PageDown
        buttonXKey: Qt.Key_PageUp
        buttonStartKey: Qt.Key_Escape
        buttonSelectKey: Qt.Key_Escape
        buttonL1Key: Qt.Key_Back
        buttonR1Key: Qt.Key_Forward
        onButtonAKeyChanged: {
            console.log("button A changed")
        }
        onLeftKeyChanged: {
            console.log("button left changed")
        }
        // Component.onCompleted: {
        //     console.log("Controller support booted.")
        //     LoggingFunctions.listProperty(this)
        // }
    }
    StackLayout {
        id: top_stack
        signal gotoBase()
        signal gotoZoomPhoto()

        onGotoBase: {
            this.currentIndex = 0
        }
        onGotoZoomPhoto: {
            this.currentIndex = 1
        }
        width: mainWindow.width
        height: mainWindow.height


        ColumnLayout {
            RowLayout {
                Layout.fillWidth: true
                ColoredSVG {
                    source: "qrc:/Images/lbutton.svg"
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
                    source: "qrc:/Images/rbutton.svg"
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
                Keys.onPressed: {
                    if (event.key === Qt.Key_Back)
                    {
                        bar.currentIndex = bar.currentIndex > 1 ? bar.currentIndex - 1: 0;
                    }
                    else if (event.key === Qt.Key_Forward)
                    {
                        bar.currentIndex = bar.currentIndex < bar.count - 1 ? bar.currentIndex + 1: bar.count - 1;
                    }
                }
            }

        }

        StackLayout {
            anchors.fill: parent
            DownloadableImage {
                // Image {
                id: zoom_image
                // Layout.fillHeight: true
                // Layout.fillWidth: true
                Layout.preferredWidth: mainWindow.width
                Layout.preferredHeight: mainWindow.height
                x: 0
                y: 0
                desiredwidth: mainWindow.width
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

        }

    }
    TopLevelMenu {
        id: toplevelmenu
    }

    InstallMenu {
        id: installmenu
    }

    DialogManager {
        id: dialogManager
    }

}
