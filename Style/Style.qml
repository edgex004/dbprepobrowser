pragma Singleton
import QtQuick 2.15

QtObject {
    readonly  property int padding: 10
    readonly  property int popup_margin: 40
    readonly  property int corner_radius: 10
    readonly  property color bg_color: Qt.lighter("#6bdce4", 0.8)
    readonly  property color selected_bg_color: Qt.lighter("#6bdce4", 0.4)
    readonly  property color text_color: "green"
    readonly  property int bodyTextSize: 18
    readonly  property int titleTextSize: 30
    readonly  property string fontFamily: "Roboto"
}

