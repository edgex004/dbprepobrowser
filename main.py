# This Python file uses the following encoding: utf-8
import os
from pathlib import Path
import sys

from PySide2.QtGui import QGuiApplication
from PySide2.QtQml import QQmlApplicationEngine
from Backend.RepoInterface import RepoDelegate
from Backend.AppListModel import AppListFilterModel, ListModel
from PySide2.QtQuickControls2 import QQuickStyle
from Backend.StringListModel import StringListModel
from dbpinstaller.dbpinstaller import installer

import style_rc

if __name__ == "__main__":

    app = QGuiApplication(sys.argv)

    QQuickStyle.setStyle("Material")
    repoDelegate = RepoDelegate()

    appListModel = ListModel()
    fullfiltermodel = AppListFilterModel(appListModel)
    installedfiltermodel = AppListFilterModel(appListModel, installedFilter=True)
    installedfiltermodel.setUpdateableSort(True)
    downloadfiltermodel = AppListFilterModel(appListModel, downloadingFilter=True)
    repoDelegate.repo_qt.repoRefreshed.connect(appListModel.resetDataSlot)
    repoDelegate.repo_qt.localRefresh.connect(appListModel.setLocalAppStatus)
    repoDelegate.repo_qt.downloadProgress.connect(appListModel.updateDownloadPercent)
    repoDelegate.repo_qt.downloadStatus.connect(appListModel.updateDownloadStatus)

    screenshotList = StringListModel()
    repoDelegate.repo_qt.detailsRefreshed.connect(screenshotList.resetDataSlot)

    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("repo", repoDelegate.repo_qt)
    engine.rootContext().setContextProperty("fullfiltermodel", fullfiltermodel)
    engine.rootContext().setContextProperty("installedfiltermodel", installedfiltermodel)
    engine.rootContext().setContextProperty("downloadfiltermodel", downloadfiltermodel)
    engine.rootContext().setContextProperty("screenshotList", screenshotList)

    engine.load(os.fspath(Path(__file__).resolve().parent / "main.qml"))


    repoDelegate.repo_qt.refresh()

    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec_())
