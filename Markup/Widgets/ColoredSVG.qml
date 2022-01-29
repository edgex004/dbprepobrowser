import QtGraphicalEffects 1.15
import QtQuick 2.14
import QtQuick.Controls.Material 2.14


Item {
    property string source
    property string color: Material.foreground
    Image {
        id: svg
        source: parent.source
        antialiasing: true
        visible: false
    }
    ColorOverlay {
        anchors.fill: parent
        source: svg
        color: parent.color
        antialiasing: true
        visible: parent.visible
    }
}