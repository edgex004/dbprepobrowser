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
    debFileMissing = Signal()
    dependancyConflict = Signal()
    downloadProgress = Signal(str,int,int,int, arguments=['name', 'chunk_number', 'chunk_size', 'total_size'])
    downloadStatus = Signal(str, str, int, arguments=['name', 'status', 'force_percent'])
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
        self._deb_to_install = StringListModel()
        self._missing_deb = StringListModel()
        self._dbp_to_install = StringListModel()
        self._apt_log = ""
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
        
    def read_deb_to_install(self):
        return self._deb_to_install

    def write_deb_to_install(self, packages: StringListModel):
        self._deb_to_install.resetDataSlot(packages)
        self.deb_to_install_changed.emit()

    deb_to_install_changed = Signal()
    deb_to_install = Property(QObject, read_deb_to_install, write_deb_to_install, notify=deb_to_install_changed)
    
    def read_missing_deb(self):
        return self._missing_deb

    def write_missing_deb(self, packages: StringListModel):
        self._missing_deb.resetDataSlot(packages)
        self.missing_deb_changed.emit()

    missing_deb_changed = Signal()
    missing_deb = Property(QObject, read_missing_deb, write_missing_deb, notify=missing_deb_changed)


    def read_dbp_to_install(self):
        return self._dbp_to_install

    def write_dbp_to_install(self, packages: StringListModel):
        self._dbp_to_install.resetDataSlot(packages)
        self.dbp_to_install_changed.emit()

    dbp_to_install_changed = Signal()
    dbp_to_install = Property(QObject, read_dbp_to_install, write_dbp_to_install, notify=dbp_to_install_changed)

    @Slot(str)
    def parse_package(self, package_id: str):
        self.dbp_to_install, self.deb_to_install, self.missing_deb = self._delegate.installer.parse_packages([package_id])

    def read_apt_log(self):
        print(f"Reading apt log: {self._apt_log}")
        print(f"Reading apt log: {self._apt_log}")
        return self._apt_log

    def append_apt_log(self, log_entry: str):
        print("Writing apt log")
        self._apt_log += f"{log_entry}\n"
        self.apt_log_changed.emit(self._apt_log)

    apt_log_changed = Signal(str)
    apt_log=Property(QObject, read_apt_log, notify=apt_log_changed)

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
        print(f"Installed length {len(installed_list)} and string is '{installed_list[0].id}'")
        if len(installed_list) > 0 and installed_list[0].id == '!':
            print("Resetting the installed list.")
            installed_list = []
        import pprint
        pp = pprint.PrettyPrinter(indent=4)

        print("Installed:")
        pp.pprint(installed_list)

        for installed in installed_list:
            print(installed.id)
            print(installed.path)
            print(installed.device)
            row = dataMap[installed.id]
            ret[row].installedLocation = installed.path
            ret[row].installedDevice = installed.device

        print("Updateable:")
        pp.pprint(update_list)

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
        if len(installed_list) > 0 and installed_list[0].id == '!':
            installed_list = []
        print("Installed:")
        for installed in installed_list:
            print(installed.id)
        print("Updateable:")
        for update in update_list:
            print(update.id)
        self.localRefresh.emit(installed_list, update_list)

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
        cancel = Event()
        dbp_to_install, deb_to_install, missing_deb = self._delegate.installer.parse_packages([package])
        for dbp_id in dbp_to_install:
            if dbp_id in self._cancel_map.keys():
                print(f"{dbp_id} is being downloaded by another thread. Skip.")
                self.dependancyConflict.emit()
                return
        for dbp_id in dbp_to_install:
            self.downloadStatus.emit(dbp_id, "\u2193 Depends", 0)
            self._cancel_map[dbp_id] = cancel
        self._delegate.installer.download(info,cancel_event=self._cancel_map[package])
        for dbp_id in dbp_to_install:
            self.downloadProgress.emit(dbp_id, 0, 0, 0)
            self._cancel_map.pop(dbp_id)
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
#        from time import sleep
        os.remove(installed_path)
#        sleep(5)
        self.localRefreshRequired.emit()

    @Slot(str)
    def cancel(self, package: str):
        event = self._cancel_map.get(package)
        if event:
            event.set()

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

    def on_installing_debs(self, packages, done):
        if not done:
            self.repo_qt.append_apt_log(f"Installing deb: {packages}")
        else:
            self.repo_qt.append_apt_log(f"Deb install complete.")
            
    def on_deb_not_found(self, package_names):
        for package_name in package_names:
            self.repo_qt.append_apt_log(f"Could not find deb: {package_name}")
        self.repo_qt.debFileMissing.emit()
