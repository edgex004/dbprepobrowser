# This Python file uses the following encoding: utf-8
import os
from pathlib import Path
import sys

from PySide2.QtGui import QGuiApplication
from PySide2.QtQml import QQmlApplicationEngine
from RepoInterface import RepoDelegate
from AppListModel import AppListFilterModel, ListModel
from PySide2.QtQuickControls2 import QQuickStyle
from StringListModel import StringListModel

import style_rc

if __name__ == "__main__":

    app = QGuiApplication(sys.argv)

    QQuickStyle.setStyle("Material")
    repoDelegate = RepoDelegate()

    filtermodel = AppListFilterModel()
    # filtermodel.setSortRole(ListModel.NameRole)
    repoDelegate.repo_qt.repoRefreshed.connect(filtermodel.appList.resetDataSlot)


    screenshotList = StringListModel()
    repoDelegate.repo_qt.detailsRefreshed.connect(screenshotList.resetDataSlot)

    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("repo", repoDelegate.repo_qt)
    engine.rootContext().setContextProperty("filterModel", filtermodel)
    engine.rootContext().setContextProperty("screenshotList", screenshotList)

    engine.load(os.fspath(Path(__file__).resolve().parent / "main.qml"))


    # repoDelegate.repo_qt.refresh()

    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec_())
