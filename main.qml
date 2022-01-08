/****************************************************************************
**
** Copyright (C)2016 The Qt Company Ltd.
** Contact: https: //www.qt.io/licensing/
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE: BSD$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https: //www.qt.io/terms-conditions. For further
** information use the contact form at https: //www.qt.io/contact-us.
**
** BSD License Usage
** Alternatively, you may use this file under the terms of the BSD license
** as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
** * Redistributions of source code must retain the above copyright
** notice, this list of conditions and the following disclaimer.
** * Redistributions in binary form must reproduce the above copyright
** notice, this list of conditions and the following disclaimer in
** the documentation and/or other materials provided with the
** distribution.
** * Neither the name of The Qt Company Ltd nor the names of its
** contributors may be used to endorse or promote products derived
** from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION)HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE)ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

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
    property var dbp_highlighted: { }
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

ColumnLayout{
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
    AppListTab{}
    Item {
        id: discoverTab
    }
    Item {
        id: activityTab
    }
}

}

        // AppListTab{}


TopLevelMenu {
    id: topmenu
    visible: false
}

}
