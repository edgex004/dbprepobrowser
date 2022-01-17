from PySide2.QtCore import QThread,QCoreApplication,QObject, Signal, Slot, QSortFilterProxyModel, QAbstractListModel, QModelIndex, Qt, QByteArray
from typing import List, Union
from AppEntry import AppEntry


class StringListModel(QAbstractListModel):

    DataEntryRole = Qt.UserRole + 1
    dataStore: list[str] = []
    dataAdded = Signal()

    def __init__(self):
        super().__init__()

    def setData(self, index: QModelIndex, value, role: int = Qt.EditRole):
        self.dataStore[index.row()] = value

    def addDataRow(self, unit: str):
        self.beginInsertRows(QModelIndex(), self.rowCount(), self.rowCount())
        self.dataStore.append(unit)
        self.endInsertRows()
        self.dataAdded.emit()

    def addData(self, input: Union[str, list[str]]):
        if isinstance(input, str):
            self.addDataRow(input)
        elif input == None or len(input) == 0 :
            return
        else:
            for unit in input:
                self.addDataRow(unit)
    
    @Slot(object)
    def resetDataSlot(self, values: list[str]=[]):
        self.beginRemoveRows(QModelIndex(), 0, self.rowCount()-1)
        self.dataStore = []
        self.endRemoveRows()
        self.addData(values)
    
    @Slot()
    def clearDataSlot(self):
        self.beginRemoveRows(QModelIndex(), 0, self.rowCount()-1)
        self.dataStore = []
        self.endRemoveRows()

    def rowCount(self, parent: QModelIndex = QModelIndex()):
        return len(self.dataStore)

    def data(self, index: QModelIndex, role: int = Qt.DisplayRole):
        if (index.row() < 0 or index.row() >= len(self.dataStore)):
            return None

        if (role == self.DataEntryRole):
            print(f'Image grabbing from {index.row()} {self.dataStore[index.row()]}')
            return self.dataStore[index.row()]

        return None

    def roleNames(self):
        roles = {}
        roles[self.DataEntryRole] = QByteArray(b"dataEntry")
        return roles