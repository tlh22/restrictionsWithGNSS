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
    QDockWidget, QComboBox, QActionGroup, QApplication
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
from .gnss_thread import GPS_Thread
import os, time
import functools

class gnss_tool(QObject):
    gnssStarted = pyqtSignal()
    gnssStopped = pyqtSignal()

    def __init__(self, iface, params):
        super().__init__()
        TOMsMessageLog.logMessage("In gnss_tool::init", level=Qgis.Info)


        # Save reference to the QGIS interface
        self.iface = iface
        self.params = params
        self.canvas = self.iface.mapCanvas()
        self.prj = QgsProject().instance()
        self.dest_crs = self.prj.crs()
        TOMsMessageLog.logMessage("In gnss_tool::init project CRS is " + self.dest_crs.description(),
                                  level=Qgis.Warning)
        self.transformation = QgsCoordinateTransform(QgsCoordinateReferenceSystem("EPSG:4326"), self.dest_crs,
                                                     self.prj)

        self.lastCentre = QgsPointXY(0, 0)

        self.setRoamDistance()
        self.setPort()

    def setPort(self):
        # Now check to see if the port is set. If not assume that just normal tools
        try:
            self.gpsPort = self.params.setParam("gpsPort")
        except Exception as e:
            TOMsMessageLog.logMessage("In enableFeaturesWithGPSToolbarItems:init: gpsPort issue: {}".format(e),
                                      level=Qgis.Warning)
            self.gpsPort = None

        TOMsMessageLog.logMessage("In gnss_tool: GPS port is: {}".format(self.gpsPort), level=Qgis.Info)

    def setRoamDistance(self):
        try:
            self.roamDistance = float(self.params.setParam("roamDistance"))
        except Exception as e:
            TOMsMessageLog.logMessage("In enableFeaturesWithGPSToolbarItems:init: roamDistance issue: {}".format(e),
                                      level=Qgis.Warning)
            self.roamDistance = 5.0

        TOMsMessageLog.logMessage("In gnss_tool: roamDistance is: {}".format(self.roamDistance), level=Qgis.Info)

    def start_gnss(self):

        TOMsMessageLog.logMessage("In gnss_tool:start_gnss - GPS port is specified ",
                                  level=Qgis.Info)

        if self.gpsPort:
            self.gpsAvailable = True
            self.gpsConnection = None
            self.curr_gps_location = None
            self.curr_gps_info = None

            self.gps_thread = GPS_Thread(self.dest_crs, self.gpsPort)

            thread = QThread()
            self.gps_thread.moveToThread(thread)
            self.gps_thread.gpsActivated.connect(self.gpsStarted)
            self.gps_thread.gpsPosition.connect(self.gpsPositionProvided)
            self.gps_thread.gpsDeactivated.connect(self.gpsStopped)
            #self.gps_thread.gpsError.connect(self.gpsErrorEncountered)

            #objThread = QThread()
            #obj = SomeObject()
            #obj.moveToThread(objThread)

            #self.gps_thread.gpsDeactivated.connect(thread.quit)
            #obj.finished.connect(objThread.quit)

            #self.gps_thread.started.connect(self.startGPS)
            #objThread.started.connect(obj.long_running)

            #thread.finished.connect(self.gpsStopped)
            #objThread.finished.connect(app.exit)

            #thread.start()
            #objThread.start()



            # self.gps_thread.progress.connect(progressBar.setValue)
            thread.started.connect(self.gps_thread.startGPS)
            # thread.finished.connect(functools.partial(self.gpsStopped, thread))
            thread.start()
            self.thread = thread

            TOMsMessageLog.logMessage("In enableFeaturesWithGPSToolbarItems - attempting connection ",
                                      level=Qgis.Info)

            #time.sleep(1.0)

    def stop_gnss(self):
        #self.gps_thread.endGPS()
        self.gpsStopped()

    # @pyqtSlot(QgsGpsConnection)
    def gpsStarted(self, connection):
        TOMsMessageLog.logMessage("In enableTools - GPS connection found ",
                                  level=Qgis.Info)

        self.gpsConnection = connection

        # marker
        self.marker = QgsVertexMarker(self.canvas)
        self.marker.setColor(QColor(255, 0, 0))  # (R,G,B)
        self.marker.setIconSize(10)
        self.marker.setIconType(QgsVertexMarker.ICON_CIRCLE)
        self.marker.setPenWidth(3)

        #self.enableGnssToolbarItem()
        reply = QMessageBox.information(None, "Information",
                                        "Connection found",
                                        QMessageBox.Ok)

        self.gnssStarted.emit()

    # @pyqtSlot()
    def gpsStopped(self):
        TOMsMessageLog.logMessage("In enableTools - GPS connection stopped ",
                                  level=Qgis.Warning)

        self.gps_thread.deleteLater()
        self.thread.quit()
        self.thread.wait()
        self.thread.deleteLater()





        if self.gpsConnection:
            if self.canvas is not None:
                self.marker.hide()
                self.canvas.scene().removeItem(self.marker)

        self.gpsConnection = None
        self.gnssStopped.emit()

        #QApplication.processEvents()


    # @pyqtSlot()
    def gpsPositionProvided(self, mapPointXY, gpsInfo):
        """reply = QMessageBox.information(None, "Information",
                                            "Position provided",
                                            QMessageBox.Ok)"""
        TOMsMessageLog.logMessage("In enableTools - ******** initial GPS location provided " + mapPointXY.asWkt(),
                                  level=Qgis.Info)

        self.curr_gps_location = mapPointXY
        self.curr_gps_info = gpsInfo

        wgs84_pointXY = QgsPointXY(gpsInfo.longitude, gpsInfo.latitude)
        wgs84_point = QgsPoint(wgs84_pointXY)
        wgs84_point.transform(self.transformation)
        x = wgs84_point.x()
        y = wgs84_point.y()
        new_mapPointXY = QgsPointXY(x, y)

        TOMsMessageLog.logMessage(
            "In enableTools - ******** transformed GPS location provided " + str(gpsInfo.longitude) + ":" + str(
                gpsInfo.latitude) + "; " + new_mapPointXY.asWkt(),
            level=Qgis.Info)

        if gpsInfo.pdop >= 1:  # gps ok
            self.marker.setColor(QColor(0, 200, 0))
        else:
            self.marker.setColor(QColor(255, 0, 0))
        self.marker.setCenter(mapPointXY)
        self.marker.show()
        # self.canvas.setCenter(mapPointXY)

        """TOMsMessageLog.logMessage("In enableTools: distance from last fix: {}".format(self.lastCentre.distance(mapPointXY)),
                                     level=Qgis.Info)"""
        if self.lastCentre.distance(mapPointXY) > self.roamDistance:
            self.lastCentre = mapPointXY
            self.canvas.setCenter(mapPointXY)
            TOMsMessageLog.logMessage(
                "In enableTools: distance from last fix: {}".format(self.lastCentre.distance(mapPointXY)),
                level=Qgis.Warning)
            self.canvas.refresh()

        # TODO: populate message bar with details about satellites, etc

    def curr_gnss_position(self):
        if self.gpsConnection:
            return self.curr_gps_location, self.curr_gps_info
        else:
            return None, None

    # @pyqtSlot(Exception, str)
    def gpsErrorEncountered(self, e):
        TOMsMessageLog.logMessage("In enableTools - GPS connection has error ",
                                  level=Qgis.Info)
        QMessageBox.information(self.iface.mainWindow(), "ERROR", ("Error encountered with GNSS. Closing tools ..."))

        self.gnssStopped.emit()

