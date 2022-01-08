from PySide2.QtCore import QThread,QCoreApplication,QObject, Signal, Slot, QSortFilterProxyModel, QAbstractListModel, QModelIndex, Qt, QByteArray
from typing import List, Union
from AppEntry import AppEntry

class AppListFilterModel(QSortFilterProxyModel):

    filterUpdated = Signal()

    def __init__(self):
        super().__init__()
        self.setSortCaseSensitivity(Qt.CaseInsensitive)
        self.appList = ListModel()
        self.setSourceModel(self.appList)
        self.setFilterRole(int(ListModel.NameRole))
        self.setSortRole(int(ListModel.NameRole))
        self.appList.dataAdded.connect(self.addedData)

    @Slot(str)
    def setFilterString(self, string: str):
        self.setFilterCaseSensitivity(Qt.CaseInsensitive)
        self.setFilterFixedString(string)
        self.filterUpdated.emit()

    @Slot(bool)
    def setSortOrder(self, checked: bool):
        if checked:
            self.sort(0, Qt.DescendingOrder)
        else:
            self.sort(0, Qt.AscendingOrder)
        self.filterUpdated.emit()

    @Slot()
    def addedData(self):
        self.filterUpdated.emit()
    



class ListModel(QAbstractListModel):

    NameRole = Qt.UserRole + 1
    IdRole = Qt.UserRole + 2
    RawDataRole = Qt.UserRole + 3
    dataStore: list[AppEntry] = []
    dataAdded = Signal()

    def __init__(self):
        super().__init__()

    def setData(self, index: QModelIndex, value, role: int = Qt.EditRole):
        self.dataStore[index.row()] = value

    def addDataRow(self, unit: AppEntry):
        self.beginInsertRows(QModelIndex(), self.rowCount(), self.rowCount())
        self.dataStore.append(unit)
        self.endInsertRows()
        self.dataAdded.emit()

    def addData(self, input: Union[AppEntry, list[AppEntry]]):
        if isinstance(input, AppEntry):
            self.addDataRow(input)
        else:
            for unit in input:
                self.addDataRow(unit)
    
    @Slot(object)
    def resetDataSlot(self, values: list[AppEntry]):
        self.beginRemoveRows(QModelIndex(), 0, self.rowCount()-1)
        self.dataStore = []
        self.addData(values)

    def rowCount(self, parent: QModelIndex = QModelIndex()):
        return len(self.dataStore)

    def data(self, index: QModelIndex, role: int = Qt.DisplayRole):
        if (index.row() < 0 or index.row() >= len(self.dataStore)):
            return None

        if (role == self.NameRole):
            return self.dataStore[index.row()].name
        if (role == self.IdRole):
            return self.dataStore[index.row()].id
        if (role == self.RawDataRole):
            return self.dataStore[index.row()]

        return None

    def roleNames(self):
        roles = {}
        roles[self.NameRole] = QByteArray(b"name")
        roles[self.IdRole] = QByteArray(b"id")
        roles[self.RawDataRole] = QByteArray(b"rawdata")
        return roles