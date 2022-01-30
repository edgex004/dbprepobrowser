import re
from PySide2.QtCore import QCoreApplication, QObject, Signal, Slot, Property
from pathlib import Path
import urllib3
from types import FunctionType
from Backend.AppEntry import AppEntry
from Backend.ProcessRunnable import ProcessRunnable
from typing import Union
import configparser
from Backend.StringListModel import StringListModel
from threading import Event

def download(url_file_list: list [(str, Path)], callback: FunctionType):
    http = urllib3.PoolManager()
    for entry in url_file_list:
        url = entry[0]
        file = entry[1]
        print(f'Download {url} to {file}')
        r = http.request('GET', url)
        if r.status == 200:
            with open(file, 'wb') as fp:
                fp.write(r.data)
        else:
            callback(False)
            return
    callback(True)

def download_threaded(url_file_list: list [(str, Path)], callback: FunctionType):
    t = ProcessRunnable(target=download, args=(url_file_list, callback))
    t.start()

def move_to_main_thread(targets: Union[QObject, list[QObject]]):
    def move(target:QObject):
        mainThread = QCoreApplication.instance().thread()
        target.moveToThread(mainThread)
    if type(targets) == QObject:
        move(targets)
    else:
        for target in targets:
            move(target)


class RepoQt(QObject):

    baseUrl = "https://pyra-handheld.com"
    ini_store = Path('./.cache/')
    sources = ['opensource', 'proprietary', 'needdata']
    base_appFile = "_apps.ini"
    base_packagesFile = "_packages.ini"
    details_file = 'details.ini'
    readme_file = 'readme.txt'
    readmeChanged = Signal(str, arguments=['msg'])
    detailsRefreshed = Signal(object)
    localRefresh = Signal(object, object)
    repoRefreshed = Signal(object)
    repoRefreshFailed = Signal()
    detailsRefreshFailed = Signal()
    mountSelectionMissing = Signal()
    downloadProgress = Signal(str,int,int,int, arguments=['name', 'chunk_number', 'chunk_size', 'total_size'])
    cacheUpdateProgress = Signal(str,int,int, arguments=['url', 'sources_processed', 'total_sources'])
    cacheUpdateComplete = Signal()
    localRefreshRequired = Signal()
    installedMd5sumMismatch = Signal(str,str, arguments=['package_id', 'path'])
    packageExistsSkip = Signal(str,str, arguments=['package_id', 'path'])
    writeError = Signal(str, arguments=['path'])
    readError = Signal(str, arguments=['path'])


    def __init__(self, delegate):
        super().__init__()
        self._mount_names = StringListModel()
        self._delegate = delegate
        self.cacheUpdateComplete.connect(self.send_cache_update)
        self.localRefreshRequired.connect(self.send_local_cache_update)
        self._cancel_map = {}
        import os
        if not os.path.isdir(self.ini_store):
            os.mkdir(self.ini_store)
        

    def read_mount_names(self):
        return self._mount_names
    
    mount_names_changed = Signal()
    mount_names=Property(QObject, read_mount_names, notify=mount_names_changed)

    @Slot()
    def find_mount_names(self):
        from dbpinstaller.dbpinstaller.mounts import find_mounts
        mounts = find_mounts()
        names = []
        for mount in mounts:
            if mount.name:
                names.append(mount.name)
            else:
                names.append(mount.path)
        self._mount_names = StringListModel()
        # self._mount_names.addData(["/media/fake1","/media/fake2","/media/fake3","/media/fake4"])
        self._mount_names.resetDataSlot(names)
        self.mount_names_changed.emit()


    def change_readme(self):
        file = self.ini_store / self.readme_file
        with open(file) as f:
            contents = f.read()
        self.readmeChanged.emit(contents)

    def refresh_details(self):
        self.detailsRefreshed.emit("New Details")

    def send_image_urls(self):
        file = self.ini_store / self.details_file
        details_config = configparser.ConfigParser()
        details_config.read(file)
        screenshots = details_config["screenshots"]
        sections = list(screenshots.keys())
        print("Image Sections: ")
        print(sections)
        ret = []
        for section in sections:
            if section.startswith("full"):
                ret.append(self.baseUrl + screenshots[section])

        self.detailsRefreshed.emit( ret )


    @Slot(str, str)
    def update_details(self, detail_url: str, readme_url: str):
        print("details update called")
        file_list = [(detail_url, self.ini_store / self.details_file)]
        callback = lambda result : self.send_image_urls() if result else self.detailsRefreshFailed.emit()
        download_threaded(file_list, callback)

        file_list2 = [(readme_url, self.ini_store / self.readme_file)]
        callback2 = lambda result : self.change_readme() if result else self.detailsRefreshFailed.emit()
        download_threaded(file_list2, callback2)



    @Slot()
    def send_cache_update(self):
        ret = []
        dataMap = {}
        app_list = self._delegate.installer.list_apps()
        for app_id in app_list:
            app = self._delegate.installer.get_app(app_id)
            package = self._delegate.installer.get_package(app.package_id)
            ret.append(AppEntry(app, package))
            dataMap[ret[-1].package_id] = len(ret) - 1


        installed_list = self._delegate.installer.list_installed()
        update_list = self._delegate.installer.update_info()

        for installed in installed_list:
            row = dataMap[installed.id]
            ret[row].installedLocation = installed.path
            ret[row].installedDevice = installed.device
        for update in update_list:
            row = dataMap[update.id]
            ret[row].updateAvailable = True
            ret[row].installedDevice = update.device

        self.repoRefreshed.emit( ret)
        # move_to_main_thread( ret )
        # self.refreshUpgradeable_async()

    def refresh_sync(self):
        self._delegate.installer.update()
        self.cacheUpdateComplete.emit()

    @Slot()
    def send_local_cache_update(self):
        installed_list = self._delegate.installer.list_installed()
        update_list = self._delegate.installer.update_info()

        self.localRefresh.emit( installed_list, update_list)

    def refresh_sync(self):
        self._delegate.installer.update()
        self.cacheUpdateComplete.emit()
    
    @Slot()
    def refresh(self):
        t = ProcessRunnable(target=self.refresh_sync, args=())
        t.start()


    def installAndAlert_sync(self, package, location, replace):
        from dbpinstaller.dbpinstaller.installer import InstallInfo
        info = InstallInfo(id=package, device=location, replace=replace)
        self._cancel_map[package] = Event()
        self._delegate.installer.download(info,cancel_event=self._cancel_map[package])
        self.downloadProgress.emit(package, 0, 0, 0)
        self.localRefreshRequired.emit()


    def install_async(self, package: str, mount_match: str, replace):
        print(f"Installing {package} to {mount_match}. Replace: {replace}")
        from dbpinstaller.dbpinstaller.mounts import find_mounts
        mounts = find_mounts()
        match = None
        for mount in mounts:
            if mount.name == mount_match or mount.path == mount_match:
                match = mount
                break
        if match == None:
            self.mountSelectionMissing.emit()
            return
        print(match)
        t = ProcessRunnable(target=self.installAndAlert_sync, args=(package, match, replace))
        t.start()
        # self._delegate.installer.download_app_to(app, match)

    @Slot(str,str)
    def install(self, package: str, mount_match: str):
        self.install_async(package, mount_match, False)
    
    @Slot(str,str)
    def upgrade(self, package: str, mount_match: str):
        self.install_async(package, mount_match, True)

    @Slot(str,str)
    def delete(self, package: str, installed_path: str):
        #package can be used to check dependencies and offer to remove them in the future.
        import os
        os.remove(installed_path)
        self.localRefreshRequired.emit()

    @Slot(str)
    def cancel(self, package: str):
        event = self._cancel_map.get(package)
        if event:
            event.set()
            self._cancel_map.pop(package)

from dbpinstaller.dbpinstaller.delegate import VoidInstallerDelegate


class RepoDelegate(VoidInstallerDelegate):
    """
    A delegate to connect dbpinstaller to the qt ui.
    """
    def __init__(self):
        super().__init__()
        self.repo_qt = RepoQt(delegate=self)
        from dbpinstaller.dbpinstaller import DbpInstaller
        self.installer = DbpInstaller(delegate=self)
        self.repo_qt.cacheUpdateComplete.emit()

    def on_download_progress(self, name, chunk_number, chunk_size, total_size):
        if total_size < 0:
            # size unknown
            print("Download: {} {}".format(name, chunk_number * chunk_size))
        else:
            percentage = round((chunk_number * chunk_size) / total_size, 2) * 100
            print("Download: {} {}%".format(name, percentage))
        self.repo_qt.downloadProgress.emit(name, chunk_number, chunk_size, total_size)


    def on_cache_update_progress(self, url, sources_processed, total_sources):
        percentage = round((sources_processed / total_sources), 2) * 100
        print("Cache update: {} {}%".format(url, percentage))
        # if sources_processed == total_sources:
        #     self.repo_qt.cacheUpdateComplete.emit()
        #     return
        self.repo_qt.cacheUpdateProgress.emit(url, sources_processed, total_sources)

    def on_installed_md5sum_mismatch(self, package_id, path):
        print("md5sum mismatch for '{}', reinstalling".format(package_id))
        self.repo_qt.installedMd5sumMismatch.emit(package_id, path)

    def on_package_exists_skip(self, package_id, path):
        print("Package {} already exists and should not be overwritten, skipping".format(package_id))
        self.repo_qt.packageExistsSkip.emit(package_id, path)

    def on_write_error(self, path):
        print("Write error: ", path)
        self.repo_qt.writeError.emit(path)

    def on_read_error(self, path):
        print("Read error: ", path)
        self.repo_qt.readError.emit(path)


