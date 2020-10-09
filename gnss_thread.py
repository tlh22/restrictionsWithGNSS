# -*- coding: latin1 -*-
#-----------------------------------------------------------
# Licensed under the terms of GNU GPL 2
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#---------------------------------------------------------------------
# Tim Hancock 2017

# https://www.opengis.ch/2016/09/07/using-threads-in-qgis-python-plugins/
# https://snorfalorpagus.net/blog/2013/12/07/multithreading-in-qgis-python-plugins/

from qgis.PyQt.QtCore import (
    QObject,
    QDate,
    pyqtSignal,
    QCoreApplication, pyqtSlot, QThread
)

from qgis.PyQt.QtGui import (
    QIcon,
    QPixmap, QColor
)

from qgis.PyQt.QtWidgets import (
    QMessageBox,
    QAction,
    QDialogButtonBox,
    QLabel,
    QDockWidget, QComboBox, QActionGroup
)

from qgis.core import (
    Qgis,
    QgsExpressionContextUtils,
    QgsProject,
    QgsMessageLog,
    QgsFeature,
    QgsGeometry,
    QgsApplication, QgsCoordinateTransform, QgsCoordinateReferenceSystem,
    QgsGpsDetector, QgsGpsConnection, QgsGpsInformation, QgsPoint, QgsPointXY,
    QgsDataSourceUri
)

from qgis.gui import (
    QgsVertexMarker,
    QgsMapToolEmitPoint
)

from TOMs.core.TOMsMessageLog import TOMsMessageLog
import os, time

class GPS_Thread(QObject):

    #https://gis.stackexchange.com/questions/307209/accessing-gps-via-pyqgis

    gpsActivated = pyqtSignal(QgsGpsConnection)
    """ signal will be emitted when gps is activated"""
    gpsDeactivated = pyqtSignal()
    gpsError = pyqtSignal(Exception)
    gpsPosition = pyqtSignal(object, object)

    def __init__(self, dest_crs, gpsPort):
        self.prj=QgsProject().instance()
        self.connectionRegistry = QgsApplication.gpsConnectionRegistry()
        super(GPS_Thread, self).__init__()
        try:
            self.gps_active = False
            # set up transformation
            self.dest_crs = self.prj.crs()
            self.transformation = QgsCoordinateTransform(QgsCoordinateReferenceSystem("EPSG:4326"), self.dest_crs,
                                                         QgsProject.instance())
            self.gpsCon = None
            TOMsMessageLog.logMessage("In GPS_Thread.__init__ - initialised ... ",
                                     level=Qgis.Info)
            self.retry_attempts = 0
        except Exception as e:
            TOMsMessageLog.logMessage(("In GPS_Thread.__init__ - exception: " + str(e)), level=Qgis.Warning)
            self.gpsError.emit(e)

        self.gpsPort = gpsPort

    def startGPS(self):

        try:
            TOMsMessageLog.logMessage("In GPS_Thread.startGPS - running ... ",
                                     level=Qgis.Info)
            self.gpsCon = None
            #self.port = "COM3"  # TODO: Add menu to select port
            self.gpsDetector = QgsGpsDetector(self.gpsPort)
            self.gpsDetector.detected[QgsGpsConnection].connect(self.connection_succeed)
            self.gpsDetector.detectionFailed.connect(self.connection_failed)

            self.gpsDetector.advance()

        except Exception as e:
            TOMsMessageLog.logMessage(("In GPS_Thread.startGPS - exception: " + str(e)),
                                     level=Qgis.Warning)
            self.gpsError.emit(e)

    def endGPS(self):
        TOMsMessageLog.logMessage(("In GPS_Thread.endGPS ...."),
                                  level=Qgis.Warning)
        self.gps_active = False

        # shutdown the receiver
        if self.gpsCon is not None:
            self.gpsCon.close()
        TOMsMessageLog.logMessage(("In GPS_Thread.status_changed - deactivating gnss ... "),
                                  level=Qgis.Warning)
        self.connectionRegistry.unregisterConnection(self.gpsCon)
        self.gpsDeactivated.emit()

    def connection_succeed(self, connection):
        try:
            TOMsMessageLog.logMessage(("In GPS_Thread.connection_succeed - GPS connected ...."),
                                     level=Qgis.Warning)
            self.gps_active = True
            self.gpsCon = connection
            self.connectionRegistry.registerConnection(connection)
            self.gpsActivated.emit(connection)

            self.gpsCon.stateChanged.connect(self.status_changed)

        except Exception as e:
            TOMsMessageLog.logMessage(("In GPS_Thread.connection_succeed - exception: " + str(e)),
                                     level=Qgis.Warning)
            self.gpsError.emit(e)

            """while self.gps_active:
            TOMsMessageLog.logMessage(
                "In GPS_Thread:connection_succeed: checking status ... {}".format(self.attempts),
                level=Qgis.Warning)
            time.sleep(1.0)
            self.attempts = self.attempts + 1
            if self.attempts > 5:
                TOMsMessageLog.logMessage(
                    ("In GPS_Thread:status_changed: problem receiving gnss position ... exiting ... "),
                    level=Qgis.Warning)
                self.endGPS()"""

    def connection_failed(self):
        TOMsMessageLog.logMessage(("In GPS_Thread.connection_failed - GPS connection failed ...."),
                                  level=Qgis.Warning)
        self.endGPS()

    def status_changed(self,gpsInfo):
        TOMsMessageLog.logMessage(("In GPS_Thread.status_changed ...."),
                                  level=Qgis.Info)
        if self.gps_active:
            try:
                #self.retry_attempts = self.retry_attempts + 1
                if self.gpsCon.status() == 3: #data received
                    """TOMsMessageLog.logMessage(("In GPS - fixMode:" + str(gpsInfo.fixMode)),
                                             level=Qgis.Info)
                    TOMsMessageLog.logMessage(("In GPS - pdop:" + str(gpsInfo.pdop)),
                                             level=Qgis.Info)
                    TOMsMessageLog.logMessage(("In GPS - satellitesUsed:" + str(gpsInfo.satellitesUsed)),
                                             level=Qgis.Info)
                    TOMsMessageLog.logMessage(("In GPS - longitude:" + str(gpsInfo.longitude)),
                                             level=Qgis.Info)
                    TOMsMessageLog.logMessage(("In GPS - latitude:" + str(gpsInfo.latitude)),
                                             level=Qgis.Info)
                    TOMsMessageLog.logMessage(("In GPS - ====="),
                                             level=Qgis.Info)"""
                    wgs84_pointXY = QgsPointXY(gpsInfo.longitude, gpsInfo.latitude)
                    wgs84_point = QgsPoint(wgs84_pointXY)
                    wgs84_point.transform(self.transformation)
                    x = wgs84_point.x()
                    y = wgs84_point.y()
                    mapPointXY = QgsPointXY(x, y)
                    self.gpsPosition.emit(mapPointXY, gpsInfo)
                    time.sleep(1)

                    TOMsMessageLog.logMessage(("In GPS - location:" + mapPointXY.asWkt()),
                                             level=Qgis.Info)
                    self.attempts = 0

                    """else:
                    TOMsMessageLog.logMessage(("In GPS_Thread:status_changed: problem receiving gnss position ... "),
                                              level=Qgis.Info)
                    if self.retry_attempts > 5:
                        TOMsMessageLog.logMessage(("In GPS_Thread:status_changed: problem receiving gnss position ... exiting ... "),
                                                  level=Qgis.Info)
                        self.gps_active = False"""

            except Exception as e:
                TOMsMessageLog.logMessage(("In GPS_Thread.status_changed - exception: " + str(e)),
                                         level=Qgis.Warning)
                self.gpsError.emit(e)
            return

    def getLocationFromGPS(self):
        TOMsMessageLog.logMessage(
            "In CreateFeatureWithGPSTool - addPointFromGPS",
            level=Qgis.Info)
        # assume that GPS is connected and get current co-ords ...
        GPSInfo = self.gpsCon.currentGPSInformation()
        lon = GPSInfo.longitude
        lat = GPSInfo.latitude
        TOMsMessageLog.logMessage(
            "In CreateFeatureWithGPSTool:addPointFromGPS - lat: " + str(lat) + " lon: " + str(lon),
            level=Qgis.Info)
        # ** need to be able to convert from lat/long to Point
        gpsPt = self.transformation.transform(QgsPointXY(lon,lat))

        #self.gpsPosition.emit(gpsPt)

        # opportunity to add details about GPS point to another table

        return gpsPt
