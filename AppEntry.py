from PySide2.QtCore import QObject, Property, Signal
from configparser import SectionProxy
from typing import List, Union

baseUrl = "https://pyra-handheld.com"


class AppEntry(QObject):

    def __init__(self, source: str, apps_entry: SectionProxy, packages_entry: Union[SectionProxy, None], parent=None):
        QObject.__init__(self, parent)
        self._source = source
        self._id = apps_entry.name
        self._package = apps_entry["Package"]
        self._name = apps_entry["Name"]
        self._description = apps_entry["Description"]
        self._icon = baseUrl + apps_entry["Icon"] if apps_entry["Icon"] else ""
        self._timestamp = apps_entry["Timestamp"]
        self._screenshot = baseUrl + apps_entry["Screenshoot"] if apps_entry["Screenshoot"] else ""
        self._screenshotSmall = baseUrl + apps_entry["ScreenshootSmall"] if apps_entry["ScreenshootSmall"] else ""
        self._likes = apps_entry["Likes"]
        self._downloads = apps_entry["Downloads"]
        self._version = packages_entry["Version"] if packages_entry else "unknown"
        self._maintainer = packages_entry["Maintainer"] if packages_entry else "This guy \"Not Sure\""


    def read_source(self):
        return self._source

    def read_id(self):
        return self._id

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

    source_changed = Signal()
    source=Property(str, read_source, notify=source_changed)

    id_changed = Signal()
    id=Property(str, read_id, notify=id_changed)

    package_changed = Signal()
    package=Property(str, read_package, notify=package_changed)

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
    likes=Property(str, read_likes, notify=likes_changed)

    downloads_changed = Signal()
    downloads=Property(str, read_downloads, notify=downloads_changed)

    version_changed = Signal()
    version=Property(str, read_version, notify=version_changed)

    maintainer_changed = Signal()
    maintainer=Property(str, read_maintainer, notify=maintainer_changed)