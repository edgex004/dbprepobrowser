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
                anchors.fill: parent

                onPaintedHeightChanged: {
                    if (snapToSize){
                        this.parent.Layout.preferredHeight = app_preview.paintedHeight
                        this.parent.height = app_preview.paintedHeight
                    }
                }
                onPaintedWidthChanged: {
                    if (snapToSize){
                        this.parent.Layout.preferredWidth = app_preview.paintedWidth
                        this.parent.width = app_preview.paintedWidth
                    }
                }
                fillMode: parent.scale ? Image.PreserveAspectFit : Image.Pad
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