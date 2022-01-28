from PySide2.QtCore import QObject, Property, Signal
from configparser import SectionProxy
from typing import List, Union
from dbpinstaller.dbpinstaller.installer import InstallInfo
from dbpinstaller.dbpinstaller.repocache import Package, App

baseUrl = "https://pyra-handheld.com"


class AppEntry(QObject):

    def __init__(self, apps_entry: App, packages_entry: Package, parent=None):
        QObject.__init__(self, parent)
        # if apps_entry.package_id == 'dbpInstaller_sebt3':
        #     import pprint
        #     pp = pprint.PrettyPrinter(indent=4)
        #     print('App:')
        #     pp.pprint(apps_entry)
        #     print('Package:')
        #     pp.pprint(packages_entry)
        self._app_id = apps_entry.id
        self._package = apps_entry.package_id
        self._name = apps_entry.name
        self._description = apps_entry.description
        self._icon = apps_entry.icon if apps_entry.icon else ""
        self._timestamp = str(apps_entry.last_updated)
        self._screenshot = baseUrl + apps_entry.screenshot if apps_entry.screenshot else ""
        self._screenshotSmall = baseUrl + apps_entry.screenshot_small if apps_entry.screenshot_small else ""
        self._likes = apps_entry.likes
        self._downloads = apps_entry.downloads
        self._version = packages_entry.version if packages_entry else "unknown"
        self._maintainer = packages_entry.maintainer if packages_entry else "This guy \"Not Sure\""
        self._details = packages_entry.details_url if packages_entry else "unknown"
        self._readme = packages_entry.readme_url if packages_entry else "unknown"
        self._size = packages_entry.size if packages_entry else "unknown"
        self.loggedChunks = 0
        self._downloadPercent = ""
        self._downloadLog = "Not tried downloading yet."
        self._installedLocation = ""
        self._installedDevice = ""
        self._updateAvailable = False

    def read_app_id(self):
        return self._app_id

    def read_package(self):
        return self._package

    def read_name(self):
        return self._name

    def read_description(self):
        return self._description

    def read_icon(self):
        return self._icon

    def read_timestamp(self):
        return self._timestamp

    def read_screenshot(self):
        return self._screenshot

    def read_screenshotSmall(self):
        return self._screenshotSmall

    def read_likes(self):
        return self._likes

    def read_downloads(self):
        return self._downloads

    def read_version(self):
        return self._version

    def read_maintainer(self):
        return self._maintainer

    def read_details(self):
        return self._details

    def read_readme(self):
        return self._readme

    def read_downloadPercent(self):
        return self._downloadPercent

    def read_downloadLog(self):
        return self._downloadLog

    def read_installedLocation(self):
        return self._installedLocation
    
    def read_installedDevice(self):
        return self._installedDevice

    def read_updateAvailable(self):
        return self._updateAvailable

    app_id_changed = Signal()
    app_id=Property(str, read_app_id, notify=app_id_changed)

    package_changed = Signal()
    package_id=Property(str, read_package, notify=package_changed)

    name_changed = Signal()
    name=Property(str, read_name, notify=name_changed)

    description_changed = Signal()
    description=Property(str, read_description, notify=description_changed)

    icon_changed = Signal()
    icon=Property(str, read_icon, notify=icon_changed)

    timestamp_changed = Signal()
    timestamp=Property(str, read_timestamp, notify=timestamp_changed)

    screenshot_changed = Signal()
    screenshot=Property(str, read_screenshot, notify=screenshot_changed)

    screenshotSmall_changed = Signal()
    screenshotSmall=Property(str, read_screenshotSmall, notify=screenshotSmall_changed)

    likes_changed = Signal()
    likes=Property(int, read_likes, notify=likes_changed)

    downloads_changed = Signal()
    downloads=Property(int, read_downloads, notify=downloads_changed)

    version_changed = Signal()
    version=Property(str, read_version, notify=version_changed)

    maintainer_changed = Signal()
    maintainer=Property(str, read_maintainer, notify=maintainer_changed)

    details_changed = Signal()
    details=Property(str, read_details, notify=details_changed)

    readme_changed = Signal()
    readme=Property(str, read_readme, notify=readme_changed)

    downloadPercent_changed = Signal()
    def write_downloadPercent(self, percent: str):
        self._downloadPercent = percent
        self.downloadPercent_changed.emit()
    downloadPercent=Property(str, read_downloadPercent, write_downloadPercent, notify=downloadPercent_changed)

    downloadLog_changed = Signal()
    def write_downloadLog(self, log: str):
        self._downloadLog = log
        self.downloadLog_changed.emit()
    downloadLog=Property(str, read_downloadLog, write_downloadLog, notify=downloadLog_changed)

    installedLocation_changed = Signal()
    def write_installedLocation(self, location: str):
        self._installedLocation = location
        self.installedLocation_changed.emit()
    installedLocation=Property(str, read_installedLocation, write_installedLocation, notify=installedLocation_changed)

    installedDevice_changed = Signal()
    def write_installedDevice(self, location: str):
        self._installedDevice = location
        self.installedDevice_changed.emit()
    installedDevice=Property(str, read_installedDevice, write_installedDevice, notify=installedDevice_changed)

    updateAvailable_changed = Signal()
    def write_updateAvailable(self, available: bool):
        self._updateAvailable = available
        self.updateAvailable_changed.emit()
    updateAvailable=Property(bool, read_updateAvailable, write_updateAvailable, notify=updateAvailable_changed)
