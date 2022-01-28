import QtQuick 2.0
import QtQuick.Layouts 1.0
import "../../Style"
import QtQml.Models 2.15
import "../../helpers/logging.js" as LoggingFunctions


BaseMenu {
    id: installmenu
    model: repo.mount_names
    property var app
    instructions: "Select an install location for " + app.name + "."
    signal customOpen(var id)

    function doCustomOpen(target) {
        app = target
    }

    Component.onCompleted: {
        this.onSelected.connect(this.select)
        this.onCustomOpen.connect(doCustomOpen)
        this.onCustomOpen.connect(this.open)
    }
    onVisibleChanged: {
        if (visible){
            repo.find_mount_names()
        }
    }
    function select(name)
    {
        console.log("selected " + name)
        repo.install(app.package_id, name)
        installmenu.close()
    }
    onModelChanged: {
        console.log("Change model to: ")
        LoggingFunctions.listProperty(repo.mount_names)
    }

}


