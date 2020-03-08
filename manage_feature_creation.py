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

# Initialize Qt resources from file resources.py

from PyQt4.QtCore import (
    QObject,
    QDate,
    pyqtSignal,
    QCoreApplication, QThread
)

from PyQt4.QtGui import (
    QMessageBox,
    QAction,
    QIcon,
    QDialogButtonBox,
    QPixmap,
    QLabel, QColor
)

from qgis.core import (
    QgsExpressionContextUtils,
    QgsMapLayerRegistry,
    QgsMessageLog, QgsFeature, QgsGeometry,
    QgsApplication, QgsCoordinateTransform, QgsCoordinateReferenceSystem,
    #QgsQtLocationConnection,
    QgsGPSDetector,
    QgsGPSConnection, QgsGPSInformation, QgsGPSConnectionRegistry,
    QgsProject,
    QgsPoint
    #QgsPointXY
)

import os, time

from qgis.gui import *

from .mapTools import CreateRestrictionTool
#from TOMsUtils import *

from .fieldRestrictionTypeUtilsClass import FieldRestrictionTypeUtilsMixin

import functools

"""

# https://www.opengis.ch/2016/09/07/using-threads-in-qgis-python-plugins/
# https://snorfalorpagus.net/blog/2013/12/07/multithreading-in-qgis-python-plugins/

# Initialize Qt resources from file resources.py
from .resources import *

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
    QDockWidget
)

from qgis.core import (
    QgsExpressionContextUtils,
    QgsProject,
    QgsMessageLog,
    QgsFeature,
    QgsGeometry,
    QgsApplication, QgsCoordinateTransform, QgsCoordinateReferenceSystem,
    QgsGpsDetector, QgsGpsConnection, QgsGpsInformation, QgsPoint, QgsPointXY
)

from qgis.gui import (
    QgsVertexMarker
)

import os, time

#from qgis.gui import *

# from .CadNodeTool.TOMsNodeTool import TOMsNodeTool

from .mapTools import CreateRestrictionTool
#from TOMsUtils import *


from .fieldRestrictionTypeUtilsClass import FieldRestrictionTypeUtilsMixin


import functools
"""

class captureGPSFeatures(FieldRestrictionTypeUtilsMixin):

    def __init__(self, iface, featuresWithGPSToolbar):

        QgsMessageLog.logMessage("In captureGPSFeatures::init", tag="TOMs panel")

        # Save reference to the QGIS interface
        self.iface = iface
        self.canvas = self.iface.mapCanvas()

        self.featuresWithGPSToolbar = featuresWithGPSToolbar
        self.gpsMapTool = False

        self.dest_crs = self.canvas.mapSettings().destinationCrs()

        QgsMessageLog.logMessage("In captureGPSFeatures::init project CRS is " + self.dest_crs.description(), tag="TOMs panel")
        self.transformation = QgsCoordinateTransform(QgsCoordinateReferenceSystem("EPSG:4326"), self.dest_crs)

        # This will set up the items on the toolbar
        # Create actions

        self.actionCreateRestriction = QAction(QIcon(":/plugins/featureswithgps/resources/mActionAddTrack.svg"),
                               QCoreApplication.translate("MyPlugin", "Create Restriction"),
                               self.iface.mainWindow())
        self.actionCreateRestriction.setCheckable(True)


        self.actionAddGPSLocation = QAction(QIcon(":/plugins/featureswithgps/resources/greendot3.png"),
                               QCoreApplication.translate("MyPlugin", "Add vertex"),
                               self.iface.mainWindow())
        self.actionAddGPSLocation.setCheckable(True)

        # Add actions to the toolbar

        self.featuresWithGPSToolbar.addAction(self.actionCreateRestriction)
        self.featuresWithGPSToolbar.addAction(self.actionAddGPSLocation)

        # Connect action signals to slots

        self.actionCreateRestriction.triggered.connect(self.doCreateRestriction)
        self.actionAddGPSLocation.triggered.connect(self.doAddGPSLocation)

        self.actionCreateRestriction.setEnabled(False)
        self.actionAddGPSLocation.setEnabled(False)

    def enableFeaturesWithGPSToolbarItems(self):

        QgsMessageLog.logMessage("In enablefeaturesWithGPSToolbarItems", tag="TOMs panel")

        #self.gps_thread.gpsActivated.connect(functools.partial(self.gpsStarted))
        #self.gps_thread.gpsDeactivated.connect(functools.partial(self.gpsStopped))

        self.gps_thread = GPS_Thread(self.dest_crs)
        thread = QThread()
        self.gps_thread.moveToThread(thread)
        self.gps_thread.gpsActivated.connect(self.gpsStarted)
        self.gps_thread.gpsPosition.connect(self.gpsPositionProvided)
        self.gps_thread.gpsDeactivated.connect(functools.partial(self.gpsStopped))
        self.gps_thread.gpsError.connect(self.gpsErrorEncountered)
        #self.gps_thread.progress.connect(progressBar.setValue)
        thread.started.connect(self.gps_thread.startGPS)
        #thread.finished.connect(functools.partial(self.gpsStopped, thread))
        thread.start()
        self.thread = thread

        """if self.gps_connection:
            QgsMessageLog.logMessage("In enableFeaturesWithGPSToolbarItems - GPS connection found ",
                                     tag="TOMs panel")

            reply = QMessageBox.information(None, "Error",
                                            "Connection found",
                                            QMessageBox.Ok)

            self.actionCreateRestriction.setEnabled(True)
            self.actionAddGPSLocation.setEnabled(True)"""


    def disableFeaturesWithGPSToolbarItems(self):

        QgsMessageLog.logMessage("In disablefeaturesWithGPSToolbarItems", tag="TOMs panel")

        self.gps_thread.endGPS()


    def doCreateRestriction(self):

        QgsMessageLog.logMessage("In doCreateRestriction", tag="TOMs panel")

        self.mapTool = None

        currLayer = self.iface.activeLayer()

        if self.actionCreateRestriction.isChecked():

            QgsMessageLog.logMessage("In doCreateRestriction - tool activated", tag="TOMs panel")

            self.iface.setActiveLayer(currLayer)

            self.mapTool = CreateRestrictionTool(self.iface, currLayer)

            self.mapTool.setAction(self.actionCreateRestriction)
            self.iface.mapCanvas().setMapTool(self.mapTool)
            self.gpsMapTool = True

        else:

            QgsMessageLog.logMessage("In doCreateRestriction - tool deactivated", tag="TOMs panel")

            self.iface.mapCanvas().unsetMapTool(self.mapTool)
            self.mapTool = None
            self.actionCreateRestriction.setChecked(False)
            self.gpsMapTool = False

    def doAddGPSLocation(self):

        QgsMessageLog.logMessage("In doAddGPSLocation", tag="TOMs panel")

        if self.gpsMapTool:

            status = self.mapTool.addPointFromGPS(self.curr_gps_location, self.curr_gps_info)

        else:

            reply = QMessageBox.information(self.iface.mainWindow(), "Information", "You need to activate the tool first ...",
                                            QMessageBox.Ok)

    #@pyqtSlot(QgsGpsConnection)
    def gpsStarted(self, connection):
        QgsMessageLog.logMessage("In enableTools - GPS connection found ",
                                     tag="TOMs panel")

        self.gpsConnection = connection

        # marker
        self.marker = QgsVertexMarker(self.canvas)
        self.marker.setColor(QColor(255, 0, 0))  # (R,G,B)
        self.marker.setIconSize(10)
        self.marker.setIconType(QgsVertexMarker.ICON_CIRCLE)
        self.marker.setPenWidth(3)

        """reply = QMessageBox.information(None, "Error",
                                            "Connection found",
                                            QMessageBox.Ok)"""

        self.actionCreateRestriction.setEnabled(True)
        self.actionAddGPSLocation.setEnabled(True)

    #@pyqtSlot()
    def gpsStopped(self):
        QgsMessageLog.logMessage("In enableTools - GPS connection stopped ",
                                     tag="TOMs panel")

        self.gps_thread.deleteLater()
        self.thread.quit()
        self.thread.wait()
        self.thread.deleteLater()

        QgsMessageLog.logMessage("In enableTools - GPS connection stopped. Thread removed ... ",
                                     tag="TOMs panel")
        if self.canvas is not None:
            self.canvas.scene().removeItem(self.marker)

        self.actionCreateRestriction.setEnabled(False)
        self.actionAddGPSLocation.setEnabled(False)

    #@pyqtSlot()
    #def gpsPositionProvided(self):
    def gpsPositionProvided(self, mapPointXY, gpsInfo):
        """reply = QMessageBox.information(None, "Information",
                                            "Position provided",
                                            QMessageBox.Ok)"""
        QgsMessageLog.logMessage("In enableTools - ******** initial GPS location provided " + mapPointXY.wellKnownText(),
                                     tag="TOMs panel")

        self.curr_gps_location = mapPointXY
        self.curr_gps_info = gpsInfo

        wgs84_pointXY = QgsPoint(gpsInfo.longitude, gpsInfo.latitude)
        wgs84_point = QgsPoint(wgs84_pointXY)
        # wgs84_point.transform(self.transformation)
        new_mapPointXY = self.transformation.transform(wgs84_point)
        # x = wgs84_point.x()
        # y = wgs84_point.y()
        # mapPointXY = QgsPoint(x, y)

        QgsMessageLog.logMessage("In enableTools - ******** transformed GPS location provided " + str(gpsInfo.longitude) + ":" + str(gpsInfo.latitude) + "; " + new_mapPointXY.wellKnownText(),
                                     tag="TOMs panel")

        if gpsInfo.pdop >= 1:  # gps ok
            self.marker.setColor(QColor(0, 200, 0))
        else:
            self.marker.setColor(QColor(255, 0, 0))
        self.marker.setCenter(mapPointXY)
        self.marker.show()
        self.canvas.setCenter(mapPointXY)

        # TODO: populate message bar with details about satellites, etc


    #@pyqtSlot(Exception, str)
    def gpsErrorEncountered(self, e):
        QgsMessageLog.logMessage("In enableTools - GPS connection has error ",
                                     tag="TOMs panel")
        self.actionCreateRestriction.setEnabled(False)
        self.actionAddGPSLocation.setEnabled(False)

class GPS_Thread(QObject):

    #https://gis.stackexchange.com/questions/307209/accessing-gps-via-pyqgis

    gpsActivated = pyqtSignal(QgsGPSConnection)
    """ signal will be emitted when gps is activated"""
    gpsDeactivated = pyqtSignal()
    gpsError = pyqtSignal(Exception)
    gpsPosition = pyqtSignal(object, object)

    def __init__(self, dest_crs):
        #QThread.__init__(self)
        #self.iface=iface
        #self.prj=QgsProject().instance()
        #self.connectionRegistry = QgsApplication.gpsConnectionRegistry()
        self.connectionRegistry = QgsGPSConnectionRegistry().instance()
        #self.canvas = self.iface.mapCanvas()
        super(GPS_Thread, self).__init__()
        try:
            self.gps_active = False

            # set up transformation
            self.dest_crs = dest_crs
            self.transformation = QgsCoordinateTransform(QgsCoordinateReferenceSystem("EPSG:4326"), self.dest_crs)

            #self.marker = None
            #gps

            self.gpsCon = None

            QgsMessageLog.logMessage("In GPS_Thread - initialised ... ",
                                     tag="TOMs panel")
        except Exception as e:
            QgsMessageLog.logMessage(("In GPS - exception: " + str(e)), tag="TOMs panel")
            self.gpsError.emit(e)

    def startGPS(self):

        try:
            QgsMessageLog.logMessage("In GPS_Thread - running ... ",
                                     tag="TOMs panel")
            self.gpsCon = None
            self.port = "COM6"  # TODO: Add menu to select port
            self.gpsDetector = QgsGPSDetector(self.port)
            self.gpsDetector.detected[QgsGPSConnection].connect(self.connection_succeed)
            self.gpsDetector.detectionFailed.connect(self.connection_failed)

            self.gpsDetector.advance()

        except Exception as e:
            QgsMessageLog.logMessage(("In GPS - exception: " + str(e)),
                                     tag="TOMs panel")
            self.gpsError.emit(e)

    def endGPS(self):
        try:
            QgsMessageLog.logMessage(("In GPS - GPS deactivated ...."),
                                     tag="TOMs panel")
            """if self.gpsCon is not None:
                self.gpsCon.close()"""
            """if self.canvas is not None:
                self.canvas.scene().removeItem(self.marker)"""
            self.gps_active = False
            """self.connectionRegistry.unregisterConnection(self.gpsCon)
            self.gpsDeactivated.emit()"""

        except Exception as e:
            QgsMessageLog.logMessage(("In GPS - exception: " + str(e)),
                                     tag="TOMs panel")
            self.gpsError.emit(e)

    def connection_succeed(self, connection):
        try:
            QgsMessageLog.logMessage(("In GPS - GPS connected ...."),
                                     tag="TOMs panel")
            self.gps_active = True
            self.gpsCon = connection

            self.gpsCon.stateChanged.connect(self.status_changed)

            self.connectionRegistry.registerConnection(connection)
            #marker
            """self.marker = QgsVertexMarker(self.canvas)
            self.marker.setColor(QColor(255, 0, 0))  # (R,G,B)
            self.marker.setIconSize(10)
            self.marker.setIconType(QgsVertexMarker.ICON_CIRCLE)
            self.marker.setPenWidth(3)"""

            self.gpsActivated.emit(connection)

        except Exception as e:
            QgsMessageLog.logMessage(("In GPS - exception: " + str(e)),
                                     tag="TOMs panel")
            self.gpsError.emit(e)

    def connection_failed(self):
        if not self.gps_active:
            QgsMessageLog.logMessage(("In GPS - GPS connection failed ...."),
                                     tag="TOMs panel")
        self.endGPS()

    def status_changed(self,gpsInfo):
        try:
            if self.gps_active:
                if self.gpsCon.status() == 3: #data received
                    """QgsMessageLog.logMessage(("In GPS - fixMode:" + str(gpsInfo.fixMode)),
                                             tag="TOMs panel")
                    QgsMessageLog.logMessage(("In GPS - pdop:" + str(gpsInfo.pdop)),
                                             tag="TOMs panel")
                    QgsMessageLog.logMessage(("In GPS - satellitesUsed:" + str(gpsInfo.satellitesUsed)),
                                             tag="TOMs panel")
                    QgsMessageLog.logMessage(("In GPS - longitude:" + str(gpsInfo.longitude)),
                                             tag="TOMs panel")
                    QgsMessageLog.logMessage(("In GPS - latitude:" + str(gpsInfo.latitude)),
                                             tag="TOMs panel")
                    QgsMessageLog.logMessage(("In GPS - ====="),
                                             tag="TOMs panel")"""
                    wgs84_pointXY = QgsPoint(gpsInfo.longitude, gpsInfo.latitude)
                    wgs84_point = QgsPoint(wgs84_pointXY)
                    #wgs84_point.transform(self.transformation)
                    mapPointXY = self.transformation.transform(wgs84_point)
                    #x = wgs84_point.x()
                    #y = wgs84_point.y()
                    #mapPointXY = QgsPoint(x, y)
                    self.gpsPosition.emit(mapPointXY, gpsInfo)
                    time.sleep(1)

                    QgsMessageLog.logMessage(("In GPS - location:" + mapPointXY.wellKnownText()),
                                             tag="TOMs panel")
                    """if gpsInfo.pdop >= 1:  # gps ok
                        self.marker.setColor(QColor(0, 200, 0))
                    else:
                        self.marker.setColor(QColor(255, 0, 0))
                    self.marker.setCenter(mapPointXY)
                    self.marker.show()
                    self.canvas.setCenter(mapPointXY)"""

            else:
                if self.gpsCon is not None:
                    self.gpsCon.close()
                self.connectionRegistry.unregisterConnection(self.gpsCon)
                self.gpsDeactivated.emit()

        except Exception as e:
            QgsMessageLog.logMessage(("In GPS - exception: " + str(e)),
                                     tag="TOMs panel")
            self.gpsError.emit(e)


    def getLocationFromGPS(self):
        QgsMessageLog.logMessage(
            "In CreateFeatureWithGPSTool - addPointFromGPS",
            tag="TOMs panel")
        # assume that GPS is connected and get current co-ords ...
        GPSInfo = self.gpsCon.currentGPSInformation()
        lon = GPSInfo.longitude
        lat = GPSInfo.latitude
        QgsMessageLog.logMessage(
            "In CreateFeatureWithGPSTool:addPointFromGPS - lat: " + str(lat) + " lon: " + str(lon),
            tag="TOMs panel")
        # ** need to be able to convert from lat/long to Point
        gpsPt = self.transformation.transform(QgsPoint(lon,lat))

        #self.gpsPosition.emit(gpsPt)

        # opportunity to add details about GPS point to another table

        return gpsPt
