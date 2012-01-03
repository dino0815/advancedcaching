import QtQuick 1.1
import com.nokia.meego 1.0
import "uiconstants.js" as UI
import QtMobility.sensors 1.2
import QtMobility.location 1.1

PageStackWindow {
    //property variant controller
    property variant geocacheList: 0
    property variant currentGeocache: null
    property string downloadText: ""

    function setGeocacheList(map, l) {
        map.model = l
    }

    function showMessage (message) {
        banner.text = message
        banner.show()
        return;
    }

    Connections {
        target: controller
        onProgressChanged: {
            if (controller.progressVisible) {
                progressBanner.show()
            } else {
                progressBanner.hide()
            }
        }
    }

    function setCurrentGeocache(geocache) {
        currentGeocache = geocache;
        settings.lastSelectedGeocache = geocache.name;
    }

    id: rootWindow


    initialPage: MainPage {
        id: mainPage
    }


    ListModel {
        id: emptyList
    }

    InfoBanner {
        id: banner
    }

    ProgressBanner {
        id: progressBanner
        text: controller.progressMessage
        value: controller.progress
    }

    Compass {
        id: compass
        onReadingChanged: {azimuth = compass.reading.azimuth; calibration = compass.reading.calibrationLevel; }
        property real azimuth: 0
        property real calibration: 0
        active: true
        dataRate: 10
    }

    PositionSource {
        id: gpsSource
        active: true
        updateInterval: 1000
        onPositionChanged: {
            controller.positionChanged(position.latitudeValid, position.coordinate.latitude, position.coordinate.longitude, position.altitudeValid, position.coordinate.altitude, position.speedValid, position.speed, position.horizontalAccuracy, position.timestamp);
        }
    }

    function showDetailsPage(page) {
        mainPage.showDetailsPage(page)
    }

    CoordinateSelector {
        id: coordinateSelectorDialog
    }

    Component.onCompleted: {
        theme.inverted = settings.optionsNightViewMode;
    }

    Connections {
        target: settings
        onOptionsNightViewModeChanged: {
            theme.inverted = settings.optionsNightViewMode;
        }
    }
}
