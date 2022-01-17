import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtQml.Models 2.1
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import "../Style"

Item {
    id: applisttab


    StackLayout {
        id: stack
        anchors.fill: parent
        currentIndex: 0

        AppList { }
        AppDetail { }
    }

}
