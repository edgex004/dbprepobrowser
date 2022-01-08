from PySide2.QtCore import QCoreApplication, QObject, Signal, Slot, QSortFilterProxyModel, QAbstractListModel, QModelIndex, Qt, QByteArray
from pathlib import Path
import urllib3
from types import FunctionType
from AppEntry import AppEntry
from ProcessRunnable import ProcessRunnable
from typing import List, Union

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
    ini_store = Path('.')
    sources = ['opensource', 'proprietary', 'needdata']
    base_appFile = "_apps.ini"
    base_packagesFile = "_packages.ini"
    readmeChanged = Signal(str, arguments=['msg'])
    detailsRefreshed = Signal(str, arguments=['msg'])
    repoRefreshed = Signal(object)
    repoRefreshFailed = Signal()
    downloadProgress = Signal(str,int,int,int, arguments=['name', 'chunk_number', 'chunk_size', 'total_size'])
    cacheUpdateProgress = Signal(str,int,int, arguments=['url', 'sources_processed', 'total_sources'])
    installedMd5sumMismatch = Signal(str,str, arguments=['package_id', 'path'])
    packageExistsSkip = Signal(str,str, arguments=['package_id', 'path'])
    writeError = Signal(str, arguments=['path'])
    readError = Signal(str, arguments=['path'])


    def __init__(self):
        super().__init__()


    def change_readme(self):
        self.readmeChanged.emit("New Readme")

    def refresh_details(self):
        self.detailsRefreshed.emit("New Details")

    @Slot(str)
    def update_details(self, string):
        print(string)    

    def send_ini_names(self) -> list[AppEntry]:
        ret = []
        for source in self.sources:
            appFile = self.ini_store / (source + self.base_appFile)
            packagesFile = self.ini_store / (source + self.base_packagesFile)

            import configparser
            app_config = configparser.ConfigParser()
            app_config.read(appFile)
            packages_config = configparser.ConfigParser()
            packages_config.read(packagesFile)
            sections = app_config.sections()
            for section in sections:
                try:
                    app_section_entry = app_config[section]
                except KeyError as e:
                    print(f'{section} is missing or incomplete: {e}')
                try:
                    ret.append(AppEntry(source,app_section_entry, packages_config[app_section_entry["Package"]]))
                except KeyError as e:
                    print(f'{section} packages entry is missing or incomplete: {e}')
                    ret.append(AppEntry(source,app_section_entry, None))



        self.repoRefreshed.emit( ret )
        move_to_main_thread( ret )

    @Slot()
    def refresh(self):
        file_list = []
        for source in self.sources:
            file_list.append((self.baseUrl + f'/repo/dists/dbprepo/{source}/Packages', self.ini_store / (source + self.base_packagesFile)))
            file_list.append((self.baseUrl + f'/repo/dists/dbprepo/{source}/Apps', self.ini_store / (source + self.base_appFile)))
        callback = lambda result : self.send_ini_names() if result else self.repoRefreshFailed.emit()
        download_threaded(file_list, callback)
        print("Download thread started.")


from dbpinstaller.dbpinstaller.delegate import VoidInstallerDelegate


class RepoDelegate(VoidInstallerDelegate):
    """
    A delegate to connect dbpinstaller to the qt ui.
    """
    def __init__(self):
        super().__init__()
        self.repo_qt = RepoQt()
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


