from PySide2.QtCore import QThread,QCoreApplication,QObject, Signal, Slot, QSortFilterProxyModel, QAbstractListModel, QModelIndex, Qt, QByteArray, Property
from typing import List, Union
from AppEntry import AppEntry
from dbpinstaller.dbpinstaller.installer import InstallInfo
from dbpinstaller.dbpinstaller.dbpd import LocalPackage

class AppListFilterModel(QSortFilterProxyModel):

    filterUpdated = Signal()
    dataReset = Signal()

    def __init__(self, appList, installedFilter = False, updateableFilter = False, downloadingFilter = False):
        super().__init__()
        assert isinstance(appList, ListModel)
        self.setSortCaseSensitivity(Qt.CaseInsensitive)
        self.appList = appList
        self.setSourceModel(self.appList)
        self.setFilterRole(int(ListModel.NameRole))
        self.setSortRole(int(ListModel.TimestampRole))
        self.appList.dataAdded.connect(self.addedData)
        self.appList.dataReset.connect(self.resetData)
        self._installedFilter = installedFilter
        self._updateableFilter = updateableFilter
        self._downloadingFilter = downloadingFilter

    @Slot(str)
    def setFilterString(self, string: str):
        self.setFilterCaseSensitivity(Qt.CaseInsensitive)
        self.setFilterFixedString(string)
        self.filterUpdated.emit()

    @Slot(bool)
    def setUpdateableSort(self, checked: bool):
        if checked:
            self.setSortRole(int(ListModel.UpdateableRole))
            self.sort(0, Qt.DescendingOrder)
        else:
            self.setSortRole(int(ListModel.TimestampRole))
            self.sort(0, Qt.DescendingOrder)
        self.filterUpdated.emit()

    @Slot(bool)
    def setInstalledFilter(self, checked: bool):
        self._installedFilter = checked
        self.invalidateFilter()
        self.filterUpdated.emit()
       
    @Slot(bool)
    def setUpdateableFilter(self, checked: bool):
        self._updateableFilter = checked
        self.invalidateFilter()
        self.filterUpdated.emit() 

    @Slot(bool)
    def setDownloadingFilter(self, checked: bool):
        self._downloadingFilter = checked
        self.invalidateFilter()
        self.filterUpdated.emit() 

    @Slot()
    def addedData(self):
        self.filterUpdated.emit()
        self.sort(0, Qt.DescendingOrder)
    
    @Slot()
    def resetData(self):
        self.dataReset.emit()
    
    def filterAcceptsRow(self, source_row:int, source_parent:QModelIndex) -> bool:
        index= self.appList.index(source_row, 0, source_parent)

        updateable = bool(self.appList.data(index=index,role = ListModel.UpdateableRole))
        installed = bool(self.appList.data(index=index,role = ListModel.InstalledRole))
        downloading = bool(self.appList.data(index=index,role = ListModel.DownloadRole))

        return (((not self._updateableFilter) or updateable) and
            ((not self._installedFilter) or installed) and
            ((not self._downloadingFilter) or downloading) and
            super().filterAcceptsRow( source_row, source_parent))


class ListModel(QAbstractListModel):

    NameRole = Qt.UserRole + 1
    IdRole = Qt.UserRole + 2
    TimestampRole = Qt.UserRole + 3
    RawDataRole = Qt.UserRole + 4
    UpdateableRole = Qt.UserRole + 5
    InstalledRole = Qt.UserRole + 6
    DownloadRole = Qt.UserRole + 7
    dataStore: list[AppEntry] = []
    dataMap: dict = {}
    dataAdded = Signal()
    dataReset = Signal()

    def __init__(self):
        super().__init__()
        self._downloadPercent = ""

    def read_downloadPercent(self):
        return self._downloadPercent

    downloadPercent_changed = Signal()
    def write_downloadPercent(self, percent: str):
        self._downloadPercent = percent
        self.downloadPercent_changed.emit()
    downloadPercent=Property(str, read_downloadPercent, write_downloadPercent, notify=downloadPercent_changed)

    def setData(self, index: QModelIndex, value, role: int = Qt.EditRole):
        self.dataStore[index.row()] = value
        self.dataMap[value.id] = index.row()

    def addDataRow(self, unit: AppEntry):
        self.beginInsertRows(QModelIndex(), self.rowCount(), self.rowCount())
        self.dataStore.append(unit)
        self.dataMap[unit.package_id] = len(self.dataStore) - 1
        self.endInsertRows()
        self.dataAdded.emit()

    def addData(self, input: Union[AppEntry, list[AppEntry]]):
        if isinstance(input, AppEntry):
            self.addDataRow(input)
        elif input == None or len(input) == 0 :
            return
        else:
            for unit in input:
                self.addDataRow(unit)
    
    @Slot(object)
    def resetDataSlot(self, values: list[AppEntry]):
        self.beginRemoveRows(QModelIndex(), 0, self.rowCount()-1)
        self.dataStore = []
        self.dataMap = {}
        self.endRemoveRows()
        self.addData(values)
        self.dataReset.emit()


    @Slot()
    def clearDataSlot(self):
        self.beginRemoveRows(QModelIndex(), 0, self.rowCount()-1)
        self.dataStore = []
        self.dataMap = {}
        self.endRemoveRows()

    def rowCount(self, parent: QModelIndex = QModelIndex()):
        return len(self.dataStore)

    def data(self, index: QModelIndex, role: int = Qt.DisplayRole):
        if (index.row() < 0 or index.row() >= len(self.dataStore)):
            return None

        if (role == self.NameRole):
            return self.dataStore[index.row()].name
        if (role == self.IdRole):
            return self.dataStore[index.row()].id
        if (role == self.TimestampRole):
            return self.dataStore[index.row()].timestamp
        if (role == self.RawDataRole):
            return self.dataStore[index.row()]
        if (role == self.UpdateableRole):
            return self.dataStore[index.row()].updateAvailable
        if (role == self.InstalledRole):
            return self.dataStore[index.row()].installedLocation
        if (role == self.DownloadRole):
            return self.dataStore[index.row()].downloadPercent
            
        return None

    def roleNames(self):
        roles = {}
        roles[self.NameRole] = QByteArray(b"name")
        roles[self.IdRole] = QByteArray(b"id")
        roles[self.TimestampRole] = QByteArray(b"timestamp")
        roles[self.RawDataRole] = QByteArray(b"rawdata")
        roles[self.UpdateableRole] = QByteArray(b"updateable")
        roles[self.InstalledRole] = QByteArray(b"installed")
        roles[self.DownloadRole] = QByteArray(b"download")
        return roles        

    @Slot()
    def resetDownloadStatus(self, app_id: str):
        row = self.dataMap[app_id]
        self.dataStore[row].downloadLog = ""
        self.dataStore[row].downloadPercent = None
        index=self.index(row, 0)
        self.dataChanged.emit(index,index,ListModel.UpdateableRole)

    
    @Slot()
    def setLocalAppStatus(self, installed_list: list[LocalPackage], update_list: list[InstallInfo]):
        #FIXME this is inefficient
        row = 0
        while row < len(self.dataStore):
            app = self.dataStore[row]
            if app.updateAvailable or app.installedDevice:
                app.updateAvailable = False
                app.installedDevice = ''
                index=self.index(row, 0)
                self.dataChanged.emit(index,index,ListModel.UpdateableRole)
            row += 1
        for installed in installed_list:
            row = self.dataMap[installed.id]
            self.dataStore[row].installedLocation = installed.path
            self.dataStore[row].installedDevice = installed.device
            index=self.index(row, 0)
            self.dataChanged.emit(index,index,ListModel.UpdateableRole)
        for update in update_list:
            row = self.dataMap[update.id]
            self.dataStore[row].updateAvailable = True
            self.dataStore[row].installedDevice = update.device
            index=self.index(row, 0)
            self.dataChanged.emit(index,index,ListModel.UpdateableRole)

    @Slot()
    def updateDownloadPercent(self, app_id: str, chunk_number: int, chunk_size: int, total_size: int):
        row = self.dataMap[app_id]
        if self.dataStore[row].loggedChunks < chunk_number and self.dataStore[row].loggedChunks + 10 > chunk_number:
            # don't log every chunk to the UI or it will stall
            return
        if total_size < 0:
        # size unknown
            downloadAmount = int(chunk_number * chunk_size)
            self.dataStore[row].downloadLog += f"Download: {app_id} {downloadAmount}\n"
            self.dataStore[row].downloadPercent = f"{downloadAmount}"
        elif chunk_number * chunk_size >= total_size:
        #download complete
            self.dataStore[row].downloadLog += f"Download complete: {app_id}%\n"
            self.dataStore[row].downloadPercent = ""
        else:
            percentage = int(round((chunk_number * chunk_size) / total_size, 2) * 100)
            self.dataStore[row].downloadLog += f"Download: {app_id} {percentage}%\n"
            self.dataStore[row].downloadPercent = f"{percentage}%"
        self.dataStore[row].loggedChunks = chunk_number
        index=self.index(row, 0)
        self.dataChanged.emit(index,index,ListModel.DownloadRole)
