import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtQml.Models 2.1
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import "../Style"

Item {
    id: applisttab
    property var dbp_highlighted: QtObject {
        property string app_id: ""
        property string package_id: ""
        property string name: ""
        property string description: ""
        property string icon: ""
        property string timestamp: ""
        property string screenshot: ""
        property string screenshotSmall: ""
        property int likes
        property int downloads
        property string version: ""
        property string maintainer: ""
        property string details: ""
        property string readme: ""
        property string downloadPercent: ""
        property string downloadLog: ""
        property string installedLocation: ""
        property string installedDevice: ""
        property bool updateAvailable
    }

    property var model

    StackLayout {
        id: stack
        anchors.fill: parent
        currentIndex: 0

        AppList { }
        AppDetail { }
    }

}
