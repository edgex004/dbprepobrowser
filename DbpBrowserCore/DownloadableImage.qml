import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.0
import QtQuick.Controls.Material 2.14

            Item{
                property string source: ""
                Layout.alignment: Qt.AlignTop
                Layout.margins: 10
                Layout.preferredWidth: parent.Layout.maximumWidth-20
                Layout.preferredHeight: (parent.Layout.maximumWidth-20) * 720 / 1280

                Image {
                id: app_preview
//                Layout.fillHeight: true
//                Layout.fillWidth: true


                // Layout.alignment: Qt.AlignTop
                // Layout.margins: 10
                // Layout.preferredWidth: parent.Layout.maximumWidth-20
                // Layout.preferredHeight: (parent.Layout.maximumWidth-20) * 720 / 1280
                anchors.fill: parent

                onPaintedHeightChanged: {
                    console.log('Painted Height: ' + app_preview.paintedHeight)

                    Layout.preferredHeight = app_preview.paintedHeight
                }
                onStatusChanged:{

                    console.log('Status changed to ' + app_preview.status)
                    console.log('Ready status: ' + Image.Ready)
//                     Layout.preferredHeight = paintedHeight
//                     Layout.alignment = Qt.AlignTop
//                if (app_preview.status == Image.Loaded) {
//                                     console.log('Status changed')

//                                     Layout.preferredHeight = paintedHeight
//                                     Layout.alignment = Qt.AlignTop

//                                 }
                }
//                width:  parent.maximumWidth - 20
                fillMode: Image.PreserveAspectFit
                source: parent.source
                asynchronous: true
            }


MyBusyIndicator {
    id: control
    anchors.fill: parent
    anchors.centerIn: parent
    running: app_preview.progress != 1 && app_preview.source != ""
}

            }