import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.0
import QtQuick.Controls.Material 2.14

            Rectangle{
                property string source: ""
                property int desiredwidth
                property bool snapToSize: false
                property bool scale: true
                Layout.alignment: Qt.AlignTop
                Layout.margins: 10
                Layout.preferredWidth: desiredwidth ? desiredwidth : parent.Layout.maximumWidth-20
                Layout.preferredHeight: desiredwidth ? (desiredwidth-20) * 720 / 1280 : (parent.Layout.maximumWidth-20) * 720 / 1280
                width: desiredwidth ? desiredwidth : parent.Layout.maximumWidth-20
                height: desiredwidth ? (desiredwidth) * 720 / 1280 : (parent.Layout.maximumWidth-20) * 720 / 1280
                color:"transparent"
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
                    if (snapToSize){
                        this.parent.Layout.preferredHeight = app_preview.paintedHeight
                        this.parent.height = app_preview.paintedHeight
                    }
                }
                onPaintedWidthChanged: {
                    console.log('Painted Width: ' + app_preview.paintedWidth)
                    if (snapToSize){
                        this.parent.Layout.preferredWidth = app_preview.paintedWidth
                        this.parent.width = app_preview.paintedWidth
                    }
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
                fillMode: parent.scale ? Image.PreserveAspectFit : Image.Pad
                source: parent.source
                asynchronous: true
                // visible:false
            }


MyBusyIndicator {
    id: control
    anchors.fill: parent
    anchors.centerIn: parent
    running: app_preview.progress != 1 && app_preview.source != ""
}

            }