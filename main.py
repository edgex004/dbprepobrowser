# This Python file uses the following encoding: utf-8
import os
from pathlib import Path
import sys

from PySide2.QtGui import QGuiApplication
from PySide2.QtQml import QQmlApplicationEngine
from RepoInterface import RepoDelegate
from AppListModel import AppListFilterModel
from PySide2.QtQuickControls2 import QQuickStyle

import style_rc

if __name__ == "__main__":

    app = QGuiApplication(sys.argv)

    QQuickStyle.setStyle("Material")
    repoDelegate = RepoDelegate()

    filtermodel = AppListFilterModel()
    repoDelegate.repo_qt.repoRefreshed.connect(filtermodel.appList.resetDataSlot)

    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("repo", repoDelegate.repo_qt)
    engine.rootContext().setContextProperty("filterModel", filtermodel)

    engine.load(os.fspath(Path(__file__).resolve().parent / "main.qml"))


    repoDelegate.repo_qt.refresh()

    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec_())
