import QtQuick 1.1
import com.nokia.meego 1.0
import "uiconstants.js" as UI
import "functions.js" as F

Page {
    orientationLock: PageOrientation.LockPortrait


    Column {
        spacing: 10
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.fill: parent
        anchors.topMargin: 16
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        id: compassColumn

        Row {
            InfoLabel {
                name: "Distance"
                value: gps.targetDistanceValid ? F.formatDistance(gps.targetDistance, settings) : "-"
                width: compassColumn.width/2.0
            }
            Column {
                width: compassColumn.width/2.0
                Label {
                    id: t0
                    font.pixelSize: 20
                    color: UI.COLOR_INFOLABEL
                    font.weight: Font.Bold
                    text: "Accuracy"
                    anchors.right: parent.right
                }

                Label {
                    id: t1
                    text: gps.lastGoodFix.valid ? ("± " + F.formatDistance(gps.lastGoodFix.error, settings)) : "-"
                    font.pixelSize: UI.FONT_DEFAULT
                    font.weight: Font.Light
                    anchors.right: parent.right
                }
            }
            anchors.left: parent.left
            anchors.right: parent.right
        }

        Image {
            id: compassImage
            source: theme.inverted ? "../data/windrose-night.svg" : "../data/windrose.svg"
            transform: [Rotation {
                    id: azCompass
                    origin.x: compassImage.width/2
                    origin.y: compassImage.height/2
                    angle: -compass.azimuth
                }/*,
                Rotation {
                    origin.x: compassImage.width/2
                    origin.y: compassImage.height/2
                    axis {x: 0; y: 0; z: 1}
                    angle: accelerometer.x
                }
                ,
                Rotation {
                    origin.x: compassImage.width/2
                    origin.y: compassImage.height/2
                    axis {x: 0; y: 1; z: 0}
                    angle: -accelerometer.x
                },
                Rotation {
                    origin.x: compassImage.width/2
                    origin.y: compassImage.height/2
                    axis {x: 1; y: 0; z: 0}
                    angle: -accelerometer.y
                }*/]
            //anchors.fill: parent
            anchors.topMargin: -32
            anchors.horizontalCenter: parent.horizontalCenter
            smooth: true
            width: compassColumn.width * 0.9
            fillMode: Image.PreserveAspectFit
            z: 2
            /*
            Image {
                property int angle: 90
                property int outerMargin: 15
                id: sunImage
                source: "image://theme/icon-m-weather-sunny"
                x: compassImage.width/2 - width/2
                y: sunImage.outerMargin
                z: -1
                transform: Rotation {
                   origin.y: compassImage.height/2 - sunImage.outerMargin
                   origin.x: sunImage.width/2
                   angle: sunImage.angle
               }
            }*/
            Image {
                property int angle: gps.targetBearing || 0
                property int outerMargin: 50
                visible: (gps.targetValid && gps.lastGoodFix.valid)
                id: arrowImage
                source: "../data/arrow_target.svg"
                width: (compassImage.paintedWidth / compassImage.sourceSize.width)*sourceSize.width
                fillMode: Image.PreserveAspectFit
                x: compassImage.width/2 - width/2
                y: arrowImage.outerMargin
                z: 3
                transform: Rotation {
                    origin.y: compassImage.height/2 - arrowImage.outerMargin
                    origin.x: arrowImage.width/2
                    angle: arrowImage.angle
                }
            }
        }


        Row {
            InfoLabel {
                name: "Altitude"
                value: gps.lastGoodFix.altitudeValid ? F.formatDistance(gps.lastGoodFix.altitude, settings) : "-"
                width: compassColumn.width/3.0
            }
            InfoLabel {
                name: "Bearing"
                value: F.formatBearing(compass.azimuth)
                width: compassColumn.width/3
            }
            InfoLabel {
                name: "Comp. Accuracy"
                value: Math.floor(compass.calibration * 100) + "%"
                width: compassColumn.width/3
            }
        }

        InfoLabel {
            name: gps.data.valid ? "Current Position" : "Last Known Position"
            value: gps.data.valid
                   ? F.formatCoordinate(gps.data.lat, gps.data.lon, settings)
                   : (gps.lastGoodFix.valid ? F.formatCoordinate(gps.lastGoodFix.lat, gps.lastGoodFix.lon, settings) : "...there is none.")
            width: compassColumn.width
        }

        Row {
            InfoLabel {
                id: currentTarget
                name: "Current Target"
                value: gps.targetValid ? F.formatCoordinate(gps.target.lat, gps.target.lon, settings) : "not set"
                width: compassColumn.width - changeTargetButton.width
            }
            Button {
                id: changeTargetButton
                width: compassColumn.width/6
                anchors.bottom: currentTarget.bottom
                iconSource: "image://theme/icon-m-toolbar-edit" + (theme.inverted ? "-white" : "")
                property variant coordinateSelectorDialog: null
                onClicked: {
                    if (coordinateSelectorDialog == null) {
                        var component = Qt.createComponent("CoordinateSelector.qml");
                        if (component.status == Component.Ready) {
                            coordinateSelectorDialog = component.createObject(tabCompass);                
                            coordinateSelectorDialog.accepted.connect(function() {
                                                                          var res = coordinateSelectorDialog.getValue();
                                                                          controller.setTarget(res[0], res[1])
                                                                      })
                        }
                    }
                    if (gps.targetValid) {
                        coordinateSelectorDialog.setValue(gps.target.lat, gps.target.lon);
                    } else if (gps.lastGoodFix.valid) {
                        coordinateSelectorDialog.setValue(gps.lastGoodFix.lat, gps.lastGoodFix.lon);
                    }
                    coordinateSelectorDialog.open()
                }
            }
        }

    }
    
    function openMenu() {
        menu.open();
    }
    
    Menu {
        id: menu
        visualParent: parent

        MenuLayout {
            MenuItem { text: "Unset Target"; onClicked: { controller.setAsTarget(null); } }
            MenuItem { text: "Settings"; onClicked: { showSettings(); } }
        }
    }
}
