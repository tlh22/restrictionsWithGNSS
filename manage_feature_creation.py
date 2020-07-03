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
    QDockWidget, QComboBox
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

import os, time

#from qgis.gui import *

# from .CadNodeTool.TOMsNodeTool import TOMsNodeTool
from TOMs.core.TOMsMessageLog import TOMsMessageLog
from .mapTools import CreateRestrictionTool, CreatePointTool
#from TOMsUtils import *

from .fieldRestrictionTypeUtilsClass import FieldRestrictionTypeUtilsMixin, gpsLayers, gpsParams
from .SelectTool import GeometryInfoMapTool, RemoveRestrictionTool
from .formManager import mtrForm


import functools

class captureGPSFeatures(FieldRestrictionTypeUtilsMixin):

    def __init__(self, iface, featuresWithGPSToolbar):

        TOMsMessageLog.logMessage("In captureGPSFeatures::init", level=Qgis.Info)

        FieldRestrictionTypeUtilsMixin.__init__(self, iface)

        # Save reference to the QGIS interface
        self.iface = iface
        self.canvas = self.iface.mapCanvas()

        self.featuresWithGPSToolbar = featuresWithGPSToolbar
        self.gpsMapTool = False
        self.marker = None

        # This will set up the items on the toolbar
        # Create actions

        self.actionCreateRestriction = QAction(QIcon(":/plugins/featureswithgps/resources/mActionAddTrack.svg"),
                               QCoreApplication.translate("MyPlugin", "Create Restriction"),
                               self.iface.mainWindow())
        self.actionCreateRestriction.setCheckable(True)


        self.actionAddGPSLocation = QAction(QIcon(":/plugins/featureswithgps/resources/greendot3.png"),
                               QCoreApplication.translate("MyPlugin", "Add vertex"),
                               self.iface.mainWindow())
        #self.actionAddGPSLocation.setCheckable(True)

        self.actionRemoveRestriction = QAction(QIcon(":plugins/featureswithgps/resources/mActionDeleteTrack.svg"),
                                        QCoreApplication.translate("MyPlugin", "Remove Restriction"),
                                        self.iface.mainWindow())
        self.actionRemoveRestriction.setCheckable(True)

        self.actionRestrictionDetails = QAction(QIcon(":/plugins/featureswithgps/resources/mActionGetInfo.svg"),
                                         QCoreApplication.translate("MyPlugin", "Get Restriction Details"),
                                         self.iface.mainWindow())
        self.actionRestrictionDetails.setCheckable(True)

        self.actionCreateSign = QAction(QIcon(":/plugins/featureswithgps/resources/mActionSetEndPoint.svg"),
                                                    QCoreApplication.translate("MyPlugin", "Create sign"),
                                                    self.iface.mainWindow())
        self.actionCreateSign.setCheckable(True)

        self.actionCreateMTR = QAction(QIcon(":/plugins/featureswithgps/resources/UK_traffic_sign_606F.svg"),
                                                    QCoreApplication.translate("MyPlugin", "Create moving traffic restriction"),
                                                    self.iface.mainWindow())
        self.actionCreateMTR.setCheckable(True)

        # Add actions to the toolbar

        self.featuresWithGPSToolbar.addAction(self.actionCreateRestriction)
        self.featuresWithGPSToolbar.addAction(self.actionAddGPSLocation)
        self.featuresWithGPSToolbar.addAction(self.actionRestrictionDetails)
        self.featuresWithGPSToolbar.addAction(self.actionRemoveRestriction)
        self.featuresWithGPSToolbar.addAction(self.actionCreateSign)
        #self.featuresWithGPSToolbar.addAction(self.actionCreateMTR)
        # Connect action signals to slots

        self.actionCreateRestriction.triggered.connect(self.doCreateRestriction)
        self.actionAddGPSLocation.triggered.connect(self.doAddGPSLocation)
        self.actionRestrictionDetails.triggered.connect(self.doRestrictionDetails)
        self.actionRemoveRestriction.triggered.connect(self.doRemoveRestriction)
        self.actionCreateSign.triggered.connect(self.doCreateSign)
        #self.actionCreateMTR.triggered.connect(self.doCreateMTR)

        self.actionCreateRestriction.setEnabled(False)
        self.actionAddGPSLocation.setEnabled(False)
        self.actionRestrictionDetails.setEnabled(False)
        self.actionRemoveRestriction.setEnabled(False)
        self.actionCreateSign.setEnabled(False)
        #self.actionCreateMTR.setEnabled(False)

        self.identifyMapTool = GeometryInfoMapTool(self.iface)
        self.identifyMapTool.setAction(self.actionRestrictionDetails)
        #self.identifyMapTool.notifyFeatureFound.connect(self.showRestrictionDetails)

        self.removeRestrictionMapTool = GeometryInfoMapTool(self.iface)
        self.removeRestrictionMapTool.setAction(self.actionRemoveRestriction)

        self.mapTool = None

    def enableFeaturesWithGPSToolbarItems(self):

        TOMsMessageLog.logMessage("In enablefeaturesWithGPSToolbarItems", level=Qgis.Info)
        self.gpsAvailable = False
        self.closeTOMs = False
        #self.closeCaptureGPSFeatures = False

        #self.gps_thread.gpsActivated.connect(functools.partial(self.gpsStarted))
        #self.gps_thread.gpsDeactivated.connect(functools.partial(self.gpsStopped))

        self.tableNames = gpsLayers(self.iface)
        self.params = gpsParams()

        self.tableNames.TOMsLayersNotFound.connect(self.setCloseTOMsFlag)
        #self.tableNames.gpsLayersNotFound.connect(self.setCloseCaptureGPSFeaturesFlag)
        self.params.TOMsParamsNotFound.connect(self.setCloseCaptureGPSFeaturesFlag)

        self.prj = QgsProject().instance()
        self.dest_crs = self.prj.crs()
        TOMsMessageLog.logMessage("In captureGPSFeatures::init project CRS is " + self.dest_crs.description(),
                                 level=Qgis.Info)
        self.transformation = QgsCoordinateTransform(QgsCoordinateReferenceSystem("EPSG:4326"), self.dest_crs,
                                                     self.prj)

        self.tableNames.getLayers()
        self.params.getParams()

        if self.closeTOMs:
            QMessageBox.information(self.iface.mainWindow(), "ERROR", ("Unable to start editing tool ..."))
            #self.actionProposalsPanel.setChecked(False)
            return   # TODO: allow function to continue without GPS enabled ...

        # Now check to see if the port is set. If not assume that just normal tools

        gpsPort = self.params.setParam("gpsPort")
        TOMsMessageLog.logMessage("In enableFeaturesWithGPSToolbarItems: GPS port is: {}".format(gpsPort), level=Qgis.Info)
        self.gpsConnection = None

        if gpsPort:
            self.gpsAvailable = True

        if self.gpsAvailable == True:
            self.curr_gps_location = None
            self.curr_gps_info = None

            TOMsMessageLog.logMessage("In enableFeaturesWithGPSToolbarItems - GPS port is specified ",
                                     level=Qgis.Info)
            self.gps_thread = GPS_Thread(self.dest_crs, gpsPort)
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

            TOMsMessageLog.logMessage("In enableFeaturesWithGPSToolbarItems - attempting connection ",
                                     level=Qgis.Info)

            time.sleep(1.0)

            if self.gpsConnection:
                TOMsMessageLog.logMessage("In enableFeaturesWithGPSToolbarItems - GPS connection found ",
                                         level=Qgis.Info)

                reply = QMessageBox.information(None, "Information",
                                                "Connection found",
                                                QMessageBox.Ok)

                #self.actionCreateRestriction.setEnabled(True)
                #self.actionAddGPSLocation.setEnabled(True)

            else:
                reply = QMessageBox.information(None, "Error",
                                        "Connection NOT found",
                                        QMessageBox.Ok)

        self.enableToolbarItems()

        self.createMapToolDict = {}
        #self.detailsMapToolDict = {}
        #self.deleteMapToolDict = {}

    def enableToolbarItems(self):
        self.actionCreateRestriction.setEnabled(True)
        self.actionRestrictionDetails.setEnabled(True)
        self.actionRemoveRestriction.setEnabled(True)
        self.actionCreateSign.setEnabled(True)
        self.actionCreateMTR.setEnabled(True)

        if self.gpsConnection:
            self.actionAddGPSLocation.setEnabled(True)

        self.currMapTool = None
        #self.iface.currentLayerChanged.connect(self.changeCurrLayer)
        #self.canvas.mapToolSet.connect(self.changeMapTool2)
        self.theCurrentMapTool = None

    def disableToolbarItems(self):

        self.actionCreateRestriction.setEnabled(False)
        self.actionRestrictionDetails.setEnabled(False)
        self.actionRemoveRestriction.setEnabled(False)
        self.actionCreateSign.setEnabled(False)
        self.actionCreateMTR.setEnabled(False)

        if self.gpsConnection:
            self.actionAddGPSLocation.setEnabled(False)

    def setCloseTOMsFlag(self):
        self.closeTOMs = True

    def setCloseCaptureGPSFeaturesFlag(self):
        self.closeCaptureGPSFeatures = True
        self.gpsAvailable = True

    def disableFeaturesWithGPSToolbarItems(self):

        TOMsMessageLog.logMessage("In disablefeaturesWithGPSToolbarItems", level=Qgis.Info)
        #if not self.closeCaptureGPSFeatures:
        if self.gpsConnection and not self.closeTOMs:
            self.gps_thread.endGPS()

        self.disableToolbarItems()

        # TODO: Need to delete any tools ...
        self.createMapToolDict = {}

        try:
            self.iface.currentLayerChanged.disconnect(self.changeCurrLayer)
        except Exception as e:
            TOMsMessageLog.logMessage(
                "In disableFeaturesWithGPSToolbarItems. Issue with disconnects for currentLayerChanged {}".format(e),
                level=Qgis.Warning)

        try:
            self.canvas.mapToolSet.disconnect(self.changeMapTool)
        except Exception as e:
            TOMsMessageLog.logMessage(
                "In disableFeaturesWithGPSToolbarItems. Issue with disconnects for mapToolSet {}".format(
                    e),
                level=Qgis.Warning)

        try:
            self.createRestrictionMapTool.deactivated.disconnect(self.deactivatedMessage)
        except Exception as e:
            TOMsMessageLog.logMessage(
                "In disableFeaturesWithGPSToolbarItems. Issue with deactivated for mapToolSet {}".format(
                    e),
                level=Qgis.Warning)

        # TODO: want to stop any editting ...

    def doCreateRestriction(self):

        TOMsMessageLog.logMessage("In doCreateRestriction", level=Qgis.Warning)

        self.currLayer = self.iface.activeLayer()

        if not self.currLayer:
            reply = QMessageBox.information(self.iface.mainWindow(), "Information", "Please choose a layer ...",
                                            QMessageBox.Ok)
            return

        # TODO: Check that this is a restriction layer

        if self.actionCreateRestriction.isChecked():

            TOMsMessageLog.logMessage("In doCreateRestriction - tool activated", level=Qgis.Warning)
            TOMsMessageLog.logMessage(
                "In doCreateRestriction: current map tool {}".format(type(self.iface.mapCanvas().mapTool()).__name__),
                level=Qgis.Warning)

            """theCurrentMapTool = self.iface.mapCanvas().mapTool()
            if self.isGnssTool(theCurrentMapTool):
                # make sure all the other tools are not active
                if self.actionRestrictionDetails.isChecked():
                    self.actionRestrictionDetails.setChecked(False)

                if self.actionRemoveRestriction.isChecked():
                    self.actionRemoveRestriction.setChecked(False)
            else:
                # make sure the change tool signal is not connected
                try:
                    self.canvas.mapToolSet.disconnect(self.changeMapTool2)
                    #self.createRestrictionMapTool.deactivated.disconnect(self.deactivatedMessage)
                except Exception as e:
                    TOMsMessageLog.logMessage(
                        "In doCreateRestriction. Issue with extra disconnects {}".format(e),
                        level=Qgis.Warning)"""

            self.createRestrictionMapTool = self.createMapToolDict.get(self.currLayer)

            if not self.createRestrictionMapTool:
                self.createRestrictionMapTool = CreateRestrictionTool(self.iface, self.currLayer)
                self.createMapToolDict[self.currLayer] = self.createRestrictionMapTool

            #self.createRestrictionMapTool.setAction(self.actionCreateRestriction)
            #self.iface.mapCanvas().mapTool().deactivate()  # use this to clear any activated tools ??
            self.iface.mapCanvas().setMapTool(self.createRestrictionMapTool)
            TOMsMessageLog.logMessage(                "In doCreateRestriction. Here 1",                 level=Qgis.Warning)
            """if not self.createRestrictionMapTool.isActive():
                self.createRestrictionMapTool.activate()"""
            TOMsMessageLog.logMessage(                "In doCreateRestriction. Here 2",                 level=Qgis.Warning)

            #self.gpsMapTool = True

            """if not self.currMapTool:
                reply = QMessageBox.information(None, "Information",
                                                "Setting current Map tool", QMessageBox.Ok)
                self.currMapTool = self.canvas.mapTool()
                self.currentlySelectedLayer = self.iface.activeLayer()
            else:
                self.iface.activeLayer().editingStopped.connect(self.reinstateMapTool)
                #pass"""

            #self.iface.activeLayer().editingStopped.connect(self.reinstateMapTool)
            self.iface.currentLayerChanged.connect(self.changeCurrLayer)
            self.canvas.mapToolSet.connect(self.changeMapTool)

            TOMsMessageLog.logMessage(                "In doCreateRestriction. Here 2B",                 level=Qgis.Warning)
            #self.createRestrictionMapTool.deactivated.connect(self.deactivatedMessage)

            if not self.createRestrictionMapTool.isCapturing():
                if self.currLayer.isEditable() == True:
                    if self.currLayer.commitChanges() == False:
                        reply = QMessageBox.information(None, "Information",
                                                        "Problem committing changes" + str(self.currLayer.commitErrors()),
                                                        QMessageBox.Ok)
                    else:
                        TOMsMessageLog.logMessage("In doCreateRestriction: changes committed", level=Qgis.Info)

                if self.currLayer.readOnly() == True:
                    TOMsMessageLog.logMessage("In doCreateRestriction - Not able to start transaction ...",
                                             level=Qgis.Info)
                else:
                    if self.currLayer.startEditing() == False:
                        reply = QMessageBox.information(None, "Information",
                                                        "Could not start transaction on " + self.currLayer.name(),
                                                        QMessageBox.Ok)
                        return
            TOMsMessageLog.logMessage(                "In doCreateRestriction. Here 3",                 level=Qgis.Warning)
        else:

            TOMsMessageLog.logMessage("In doCreateRestriction - tool deactivated", level=Qgis.Info)

            if self.createRestrictionMapTool:
                self.iface.mapCanvas().unsetMapTool(self.createRestrictionMapTool)

                # disconnect signals ...
                #if self.currentlySelectedLayer == self.iface.activeLayer():
                try:
                    self.iface.currentLayerChanged.disconnect(self.changeCurrLayer)
                except Exception as e:
                    TOMsMessageLog.logMessage(
                        "In doCreateRestriction. Issue with currentLayerChanged disconnect {}".format(e),
                        level=Qgis.Warning)

                """try:
                    self.iface.activeLayer().editingStopped.disconnect(self.reinstateMapTool)
                except Exception as e:
                    TOMsMessageLog.logMessage(
                        "In doCreateRestriction. Issue with editingStopped disconnect {}".format(e),
                        level=Qgis.Warning)"""

                try:
                    self.canvas.mapToolSet.disconnect(self.changeMapTool)
                    #self.createRestrictionMapTool.deactivated.disconnect(self.deactivatedMessage)
                except Exception as e:
                    TOMsMessageLog.logMessage(
                        "In doCreateRestriction. Issue with extra disconnects {}".format(e),
                        level=Qgis.Warning)

                    #self.createRestrictionMapTool = None

            self.currMapTool = None
            self.currentlySelectedLayer = None

            self.actionCreateRestriction.setChecked(False)

            # TODO: stop editting on layers??

            #self.gpsMapTool = False
        TOMsMessageLog.logMessage(                "In doCreateRestriction. Here 4",                 level=Qgis.Warning)

    def isGnssTool(self, mapTool):

        if (isinstance(mapTool, CreateRestrictionTool) or
           isinstance(mapTool, GeometryInfoMapTool) or
           isinstance(mapTool, RemoveRestrictionTool)):
            return True

        return False

    def deactivatedMessage(self):
        try:
            self.createRestrictionMapTool.deactivated.disconnect(self.deactivatedMessage)
        except Exception as e:
            reply = QMessageBox.information(None, "Information", "In deactivatedMessage. Tool: {}. Issue with disconnects {}".format(self.canvas.mapTool().toolName(), e), QMessageBox.Ok)
            return

        #currMapTool = self.canvas.mapTool()
        reply = QMessageBox.information(None, "Information",
                                        "Tool deactivated {}".format(self.canvas.mapTool().toolName()),
                                        QMessageBox.Ok)

    def changeMapTool2(self):

        if self.theCurrentMapTool:
            self.theCurrentMapTool.action().toggle()

        self.theCurrentMapTool = self.iface.mapCanvas().mapTool()
        TOMsMessageLog.logMessage(
            "In changeMapTool2. tool reset", level=Qgis.Warning)
        print('tool unset')

    def changeCurrLayer2(self):

        if self.theCurrentMapTool:
            self.theCurrentMapTool.action().trigger()

        TOMsMessageLog.logMessage(
            "In changeLayer2. tool triggered", level=Qgis.Warning)
        print('layer changed')

    def changeMapTool(self, newMapTool, oldMapTool):
        # not sure it is required

        try:
            oldMapToolName = oldMapTool.toolName()
        except Exception as e:
            TOMsMessageLog.logMessage(
                "In changeMapTool. Issue with getting old map name {}".format(e), level=Qgis.Warning)
            oldMapToolName = 'Not known'

        try:
            newMapToolName = newMapTool.toolName()
        except Exception as e:
            TOMsMessageLog.logMessage(
                "In changeMapTool. Issue with getting new map name {}".format(e),
                level=Qgis.Warning)
            newMapToolName = 'Not known'

        TOMsMessageLog.logMessage("In changeMapTool: {} replacing {}".format(newMapToolName, oldMapToolName), level=Qgis.Info)
        """reply = QMessageBox.information(None, "Information",
                                        "In changeMapTool: {} replacing {}".format(newMapToolName, oldMapToolName),
                                        QMessageBox.Ok)"""

        self.canvas.mapToolSet.disconnect(self.changeMapTool)

        incomingTool = False
        outgoingTool = False
        # check to see if we are changing from/to ane of the plugin tools
        if (isinstance(newMapTool, CreateRestrictionTool) or
           isinstance(newMapTool, GeometryInfoMapTool) or
           isinstance(newMapTool, RemoveRestrictionTool)):
           """reply = QMessageBox.information(None, "Information",
                                           "In changeMapTool: incoming map tool is gps tool".format(newMapToolName, oldMapToolName),
                                           QMessageBox.Ok)"""
           incomingTool = True

        if (isinstance(oldMapTool, CreateRestrictionTool) or
           isinstance(oldMapTool, GeometryInfoMapTool) or
           isinstance(oldMapTool, RemoveRestrictionTool)):
           """reply = QMessageBox.information(None, "Information",
                                           "In changeMapTool: incoming map tool is gps tool".format(newMapToolName, oldMapToolName),
                                           QMessageBox.Ok)"""
           outgoingTool = True

        TOMsMessageLog.logMessage("In changeMapTool: outgoing {} incoming {}".format(outgoingTool, incomingTool), level=Qgis.Warning)
        TOMsMessageLog.logMessage("In changeMapTool classes: outgoing {} incoming {}".format(type(oldMapTool).__name__, type(newMapTool).__name__), level=Qgis.Warning)

        TOMsMessageLog.logMessage("In changeMapTool classes: current {}".format(type(type(self.iface.mapCanvas().mapTool()).__name__)),
                                  level=Qgis.Warning)
        #self.iface.mapCanvas().mapTool().deactivate()  # use this to clear any activated tools ??

        if outgoingTool and not incomingTool:
            # need to remove any signals
            try:
                self.iface.currentLayerChanged.disconnect(self.changeCurrLayer)
            except Exception as e:
                TOMsMessageLog.logMessage(
                    "In changeMapTool. Issue with getting disconnection currentLayerChanged {}".format(e),
                    level=Qgis.Warning)

            if self.actionCreateRestriction.isChecked():
                self.actionCreateRestriction.setChecked(False)

            if self.actionRestrictionDetails.isChecked():
                self.actionRestrictionDetails.setChecked(False)

            if self.actionRemoveRestriction.isChecked():
                self.actionRemoveRestriction.setChecked(False)

        elif incomingTool:
            # make sure that correct action is checked  ** TODO: Need to check which action is checked - and not recheck it  ** uncheck triggers change in tool
            if self.actionCreateRestriction.isChecked():
                self.actionCreateRestriction.setChecked(False)

            if self.actionRestrictionDetails.isChecked():
                self.actionRestrictionDetails.setChecked(False)

            if self.actionRemoveRestriction.isChecked():
                self.actionRemoveRestriction.setChecked(False)

            if (isinstance(newMapTool, CreateRestrictionTool)):
                self.actionCreateRestriction.setChecked(True)
            if (isinstance(newMapTool, GeometryInfoMapTool)):
                self.actionRestrictionDetails.setChecked(True)
            if (isinstance(newMapTool, RemoveRestrictionTool)):
                self.actionRemoveRestriction.setChecked(True)



    def changeCurrLayer(self, newLayer):
        TOMsMessageLog.logMessage("In changeCurrLayer - newLayer: " + str(newLayer.name()),
                                 level=Qgis.Warning)
        self.iface.currentLayerChanged.disconnect(self.changeCurrLayer)
        if self.actionCreateRestriction.isChecked():
            # TODO: Check whether or not it has been switched to an allowable layer
            #self.createRestrictionMapTool.deactivate()
            #self.iface.mapCanvas().unsetMapTool(self.createRestrictionMapTool)
            self.doCreateRestriction()

        if self.actionRestrictionDetails.isChecked():
            """try:
                self.showRestrictionMapTool.notifyFeatureFound.disconnect(self.showRestrictionDetails)
            except Exception as e:
                TOMsMessageLog.logMessage(
                    "In doCreateRestriction. Issue with notifyFeatureFound disconnect {}".format(e),
                    level=Qgis.Warning)"""
            self.doRestrictionDetails()

        if self.actionRemoveRestriction.isChecked():
            #self.actionRemoveRestriction.deactivate()
            #self.actionRemoveRestriction.notifyFeatureFound.disconnect(self.showRestrictionDetails)
            #self.iface.mapCanvas().unsetMapTool(self.actionRemoveRestriction)
            self.doRemoveRestriction()

    """def createRestrictionStarted(self):
        self.createProcessStarted = True

    def createRestrictionMapToolDeactivated(self, inProcess):
        TOMsMessageLog.logMessage("In createRestrictionMapToolDeactivated - currMapTool " + str(inProcess), level=Qgis.Info)
        self.interrupted = inProcess"""

    """def reinstateMapTool(self):
        TOMsMessageLog.logMessage("In reinstateMapTool ... ", level=Qgis.Info)

        self.iface.setActiveLayer(self.currLayer)
        self.mapTool = self.createMapToolDict.get(self.currLayer)

        #self.iface.mapCanvas().unsetMapTool(self.mapTool)
        #self.actionCreateSign.setChecked(False)
        #if self.currCreateRestrictionTool:
        self.iface.mapCanvas().setMapTool(self.mapTool)"""

    def doAddGPSLocation(self):

        TOMsMessageLog.logMessage("In doAddGPSLocation", level=Qgis.Info)

        if self.gpsMapTool:  # TODO check where this is set ...

            if self.curr_gps_location:
                try:
                    status = self.createRestrictionMapTool.addPointFromGPS(self.curr_gps_location, self.curr_gps_info)
                except Exception as e:
                    TOMsMessageLog.logMessage("In doAddGPSLocation: Problem adding gnss location: {}".format(e), level=Qgis.Warning)
                    reply = QMessageBox.information(self.iface.mainWindow(), "Error",
                                                    "Problem adding gnss location ... ",
                                                    QMessageBox.Ok)
            else:
                reply = QMessageBox.information(self.iface.mainWindow(), "Information",
                                                "No position found ...",
                                                QMessageBox.Ok)
        else:

            reply = QMessageBox.information(self.iface.mainWindow(), "Information", "You need to activate the tool first ...",
                                            QMessageBox.Ok)

    def doRestrictionDetails(self):
        """ Select point and then display details. Assume that there is only one of these map tools in existence at any one time ??
        """
        TOMsMessageLog.logMessage("In doRestrictionDetails", level=Qgis.Info)

        # TODO: Check whether or not there is a create maptool available. If so, stop this and finish using that/those tools

        #self.mapTool = None
        #self.currLayer = self.iface.activeLayer()

        if not self.iface.activeLayer():
            reply = QMessageBox.information(self.iface.mainWindow(), "Information", "Please choose a layer ...",
                                            QMessageBox.Ok)
            return

        if self.actionRestrictionDetails.isChecked():

            TOMsMessageLog.logMessage("In doRestrictionDetails - tool activated", level=Qgis.Info)

            self.showRestrictionMapTool = GeometryInfoMapTool(self.iface)
            self.iface.mapCanvas().setMapTool(self.showRestrictionMapTool)

            #self.showRestrictionMapTool.notifyFeatureFound.connect(self.showRestrictionDetails)
            self.iface.currentLayerChanged.connect(self.changeCurrLayer)
            self.canvas.mapToolSet.connect(self.changeMapTool)

            #self.identifyMapTool.deactivated.connect(self.deactivatedMessage)

        else:

            TOMsMessageLog.logMessage("In doRestrictionDetails - tool deactivated", level=Qgis.Info)

            if self.showRestrictionMapTool:
                #self.showRestrictionMapTool.notifyFeatureFound.disconnect(self.showRestrictionDetails)
                self.canvas.mapToolSet.disconnect(self.changeMapTool)
                self.iface.currentLayerChanged.disconnect(self.changeCurrLayer)
                self.iface.mapCanvas().unsetMapTool(self.showRestrictionMapTool)
                self.showRestrictionMapTool.deactivate()

            self.actionRestrictionDetails.setChecked(False)

    def deactivateAction(self, currAction):
        # is this needed??
        TOMsMessageLog.logMessage("In deactivateAction: ", level=Qgis.Info)
        try:
            currAction.setChecked(False)
            if currAction == self.actionRestrictionDetails:
                self.mapTool.deactivated.disconnect(functools.partial(self.deactivateAction, self.actionRestrictionDetails))
            elif currAction == self.actionRemoveRestriction:
                self.mapTool.deactivated.disconnect(functools.partial(self.deactivateAction, self.actionRemoveRestriction))
        except Exception as e:
            TOMsMessageLog.logMessage("In deactivateAction: {}".format(e), level=Qgis.Warning)

    #@pyqtSlot(str)
    def showRestrictionDetails(self, closestLayer, closestFeature):

        TOMsMessageLog.logMessage(
            "In showRestrictionDetails ... Layer: " + str(closestLayer.name()),
            level=Qgis.Info)

        #self.showRestrictionMapTool.notifyFeatureFound.disconnect(self.showRestrictionDetails)

        # TODO: could improve ... basically check to see if transaction in progress ...
        if closestLayer.isEditable() == True:
            if closestLayer.commitChanges() == False:
                reply = QMessageBox.information(None, "Information",
                                                "Problem committing changes" + str(closestLayer.commitErrors()),
                                                QMessageBox.Ok)
            else:
                TOMsMessageLog.logMessage("In showRestrictionDetails: changes committed", level=Qgis.Info)

        if self.iface.activeLayer().readOnly() == True:
            TOMsMessageLog.logMessage("In showSignDetails - Not able to start transaction ...",
                                     level=Qgis.Info)
        else:
            if self.iface.activeLayer().startEditing() == False:
                reply = QMessageBox.information(None, "Information",
                                                "Could not start transaction on " + self.currLayer.name(),
                                                QMessageBox.Ok)
                return

        self.dialog = self.iface.getFeatureForm(closestLayer, closestFeature)
        #self.TOMsUtils.setupRestrictionDialog(self.dialog, closestLayer, closestFeature)
        self.setupFieldRestrictionDialog(self.dialog, closestLayer, closestFeature)

        self.dialog.show()

    def doRemoveRestriction(self):

        TOMsMessageLog.logMessage("In doRemoveRestriction", level=Qgis.Info)

        self.currLayer = self.iface.activeLayer()

        if not self.currLayer:
            reply = QMessageBox.information(self.iface.mainWindow(), "Information", "Please choose a layer ...",
                                            QMessageBox.Ok)
            return

        if self.currLayer.readOnly() == True:
            """reply = QMessageBox.information(None, "Information",
                                            "Could not start transaction on " + self.currLayer.name(), QMessageBox.Ok)"""
            TOMsMessageLog.logMessage("In doRemoveRestriction - Not able to start transaction ...", level=Qgis.Info)
            self.actionRemoveRestriction.setChecked(False)
            return

        if self.actionRemoveRestriction.isChecked():

            TOMsMessageLog.logMessage("In doRemoveRestriction - tool activated", level=Qgis.Warning)

            """self.mapTool = self.deleteMapToolDict.get(self.currLayer)

            if not self.mapTool:
                self.mapTool = RemoveRestrictionTool(self.iface)
                self.deleteMapToolDict[self.currLayer] =  self.mapTool"""

            self.mapTool = RemoveRestrictionTool(self.iface)
            #self.removeRestrictionMapTool.setAction(self.actionRemoveRestriction)
            self.iface.mapCanvas().setMapTool(self.removeRestrictionMapTool)
            #self.gpsMapTool = True
            #self.removeRestrictionMapTool.deactivated.connect(functools.partial(self.deactivateAction, self.actionRemoveRestriction))
            self.iface.currentLayerChanged.connect(self.changeCurrLayer)
            self.canvas.mapToolSet.connect(self.changeMapTool)

            self.removeRestrictionMapTool.notifyFeatureFound.connect(self.removeRestriction)

        else:

            TOMsMessageLog.logMessage("In doRemoveRestriction - tool deactivated", level=Qgis.Info)

            self.removeRestrictionMapTool.notifyFeatureFound.disconnect(self.removeRestriction)

            self.canvas.mapToolSet.disconnect(self.changeMapTool)
            #self.iface.currentLayerChanged.disconnect(self.changeCurrLayer)

            self.iface.mapCanvas().unsetMapTool(self.removeRestrictionMapTool)
            self.removeRestrictionMapTool.deactivate()
            #self.mapTool = None
            self.actionRemoveRestriction.setChecked(False)

    #@pyqtSlot(str)
    def removeRestriction(self, closestLayer, closestFeature):

        TOMsMessageLog.logMessage(
            "In removeRestriction ... Layer: " + str(closestLayer.name()),
            level=Qgis.Info)

        if closestLayer.isEditable() == True:
            if closestLayer.commitChanges() == False:
                reply = QMessageBox.information(None, "Information",
                                                "Problem committing changes" + str(closestLayer.commitErrors()),
                                                QMessageBox.Ok)
            else:
                TOMsMessageLog.logMessage("In removeRestriction: changes committed", level=Qgis.Info)

        if self.currLayer.startEditing() == False:
            reply = QMessageBox.information(None, "Information",
                                            "Could not start transaction on " + self.currLayer.name(),
                                            QMessageBox.Ok)
            return

        # TODO: Sort out this for UPDATE
        # self.setDefaultRestrictionDetails(closestFeature, closestLayer)

        closestLayer.deleteFeature(closestFeature.id())

        if closestLayer.commitChanges() == False:
            reply = QMessageBox.information(None, "Information",
                                            "Problem committing changes" + str(closestLayer.commitErrors()),
                                            QMessageBox.Ok)
        else:
            TOMsMessageLog.logMessage("In removeRestriction: changes committed", level=Qgis.Info)

    def doCreateSign(self):

        TOMsMessageLog.logMessage("In doCreateSign", level=Qgis.Info)

        if self.actionCreateSign.isChecked():

            self.currMapTool = self.canvas.mapTool()
            self.currentlySelectedLayer = self.iface.activeLayer()
            self.signsLayer = self.tableNames.setLayer("Signs")

            """if self.currMapTool:
                toolText = self.currMapTool.action().text()
                TOMsMessageLog.logMessage("In doCreateSign - currMapTool [" + toolText + "]", level=Qgis.Info)

                if toolText == 'Create Restriction':
                    self.currentlySelectedLayer = self.iface.activeLayer()
                else:
                    self.currentlySelectedLayer = self.signsLayer"""

            #self.createRestrictionMapTool = None
            self.iface.setActiveLayer(self.signsLayer)
            self.createPointMapTool = CreatePointTool(self.iface, self.signsLayer)
            #self.createRestrictionMapTool = self.createMapToolDict.get(self.signsLayer)

            """if not self.createRestrictionMapTool:
                self.createRestrictionMapTool = CreatePointTool(self.iface, self.signsLayer)"""
                #self.createMapToolDict[self.signsLayer] = self.createRestrictionMapTool
                #self.doCreateRestriction()

            TOMsMessageLog.logMessage("In doCreateSign - tool activated", level=Qgis.Info)

            #self.func1 = functools.partial(self.reinstateMapTool, self.signsLayer)
            #self.iface.activeLayer().editingStopped.connect(self.reinstateMapTool)
            self.signsLayer.editingStopped.connect(self.reinstateMapTool)

            self.actionCreateSign.setChecked(False)

            #self.createRestrictionMapTool.setAction(self.actionCreateSign)
            self.iface.mapCanvas().setMapTool(self.createPointMapTool)


    def doCreateMTR(self):

        TOMsMessageLog.logMessage("In doCreateMTR", level=Qgis.Info)

        if self.actionCreateMTR.isChecked():

            TOMsMessageLog.logMessage("In doCreateMTR - tool activated", level=Qgis.Info)

            # Open MTR form ...

            try:
                self.thisMtrForm
            except AttributeError:
                self.thisMtrForm = mtrForm(self.iface)

            #res = mtrFormFactory.prepareForm(self.iface, self.dbConn, self.dialog)
            #self.mtrTypeCB = self.dialog.findChild(QComboBox, "cmb_MTR_list")
            #self.mtrTypeCB.activated[str].connect(self.onLocalChanged)
            #self.currDialog.findChild(QComboBox, "cmb_MTR_list").activated[str].connect(self.onChanged)


            """ Need to setup dialog:
                a. create drop down
                b. link structure of form to different options from drop down, e.g., Access Restriction needs ?? attributes and one point, Turn Restriction needs ?? attributes and two points
                c. link getPoint actions to buttons
            """
            status = self.thisMtrForm.show()
            # Run the dialog event loop
            result = self.thisMtrForm.exec_()
            #

        else:

            TOMsMessageLog.logMessage("In doCreateMTR - tool deactivated", level=Qgis.Info)

            #self.iface.mapCanvas().unsetMapTool(self.mapTool)
            #self.mapTool = None
            self.actionCreateMTR.setChecked(False)
            self.gpsMapTool = False

    def onLocalChanged(self, text):
        TOMsMessageLog.logMessage(
            "In generateFirstStageForm::selectionchange.  " + text, level=Qgis.Info)
        res = mtrFormFactory.prepareForm(self.iface, self.dbConn, self.dialog, text)

    def reinstateMapTool(self):

        TOMsMessageLog.logMessage("In reinstateMapTool ... ", level=Qgis.Info)
        self.iface.activeLayer().editingStopped.disconnect(self.reinstateMapTool)

        if self.currMapTool:
            #TOMsMessageLog.logMessage("In reinstateMapTool ... " + self.currMapTool.toolName(), level=Qgis.Info)

            # tear down the current mapTool details
            #self.iface.activeLayer().editingStopped.disconnect(self.reinstateMapTool)
            """try:
                self.iface.currentLayerChanged.disconnect(self.changeCurrLayer)
                self.canvas.mapToolSet.disconnect(self.changeMapTool)
            except Exception as e:
                TOMsMessageLog.logMessage("In reinstateMapTool. Issue with disconnects {}".format(e) + self.currMapTool.toolName(), level=Qgis.Warning)"""

            #self.createRestrictionMapTool.deactivate()
            #self.actionCreateSign.setChecked(False)

            TOMsMessageLog.logMessage(
                "In reinstateMapTool. layer to be reinstated {} using tool {}".format(self.currentlySelectedLayer.name(), self.currMapTool.toolName()),
                level=Qgis.Warning)
            # now reinstate
            if self.currentlySelectedLayer:
                self.iface.setActiveLayer(self.currentlySelectedLayer)
                #self.currentlySelectedLayer = None
            #self.iface.currentLayerChanged.connect(self.changeCurrLayer)
            #self.canvas.mapToolSet.connect(self.changeMapTool)

            #self.iface.mapCanvas().unsetMapTool(self.createRestrictionMapTool)

            self.iface.mapCanvas().setMapTool(self.currMapTool)
            #self.currMapTool = None



    #@pyqtSlot(QgsGpsConnection)
    def gpsStarted(self, connection):
        TOMsMessageLog.logMessage("In enableTools - GPS connection found ",
                                     level=Qgis.Warning)

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

        """self.actionCreateRestriction.setEnabled(True)
        self.actionAddGPSLocation.setEnabled(True)
        self.actionRestrictionDetails.setEnabled(True)
        self.actionRemoveRestriction.setEnabled(True)
        self.actionCreateSign.setEnabled(True)"""

        self.enableToolbarItems()

    #@pyqtSlot()
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

        """self.actionCreateRestriction.setEnabled(False)
        self.actionAddGPSLocation.setEnabled(False)
        self.actionRestrictionDetails.setEnabled(False)
        self.actionRemoveRestriction.setEnabled(False)"""

        #self.disableToolbarItems()

    #@pyqtSlot()
    #def gpsPositionProvided(self):
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

        TOMsMessageLog.logMessage("In enableTools - ******** transformed GPS location provided " + str(gpsInfo.longitude) + ":" + str(gpsInfo.latitude) + "; " + new_mapPointXY.asWkt(),
                                     level=Qgis.Info)

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
        TOMsMessageLog.logMessage("In enableTools - GPS connection has error ",
                                     level=Qgis.Info)
        """self.actionCreateRestriction.setEnabled(False)
        self.actionAddGPSLocation.setEnabled(False)"""
        self.disableToolbarItems()

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
            TOMsMessageLog.logMessage("In GPS_Thread - initialised ... ",
                                     level=Qgis.Info)
        except Exception as e:
            TOMsMessageLog.logMessage(("In GPS - exception: " + str(e)), level=Qgis.Warning)
            self.gpsError.emit(e)

        self.gpsPort = gpsPort

    def startGPS(self):

        try:
            TOMsMessageLog.logMessage("In GPS_Thread - running ... ",
                                     level=Qgis.Info)
            self.gpsCon = None
            #self.port = "COM3"  # TODO: Add menu to select port
            self.gpsDetector = QgsGpsDetector(self.gpsPort)
            self.gpsDetector.detected[QgsGpsConnection].connect(self.connection_succeed)
            self.gpsDetector.detectionFailed.connect(self.connection_failed)

            self.gpsDetector.advance()

        except Exception as e:
            TOMsMessageLog.logMessage(("In GPS - exception: " + str(e)),
                                     level=Qgis.Warning)
            self.gpsError.emit(e)

    def endGPS(self):
        try:
            TOMsMessageLog.logMessage(("In GPS - GPS deactivated ...."),
                                     level=Qgis.Info)
            self.gps_active = False

        except Exception as e:
            TOMsMessageLog.logMessage(("In GPS - exception: " + str(e)),
                                     level=Qgis.Warning)
            self.gpsError.emit(e)

    def connection_succeed(self, connection):
        try:
            TOMsMessageLog.logMessage(("In GPS - GPS connected ...."),
                                     level=Qgis.Info)
            self.gps_active = True
            self.gpsCon = connection

            self.gpsCon.stateChanged.connect(self.status_changed)

            self.connectionRegistry.registerConnection(connection)
            self.gpsActivated.emit(connection)

        except Exception as e:
            TOMsMessageLog.logMessage(("In GPS - exception: " + str(e)),
                                     level=Qgis.Warning)
            self.gpsError.emit(e)

    def connection_failed(self):
        if not self.gps_active:
            TOMsMessageLog.logMessage(("In GPS - GPS connection failed ...."),
                                     level=Qgis.Warning)
            self.endGPS()
            self.gpsDeactivated.emit()

    def status_changed(self,gpsInfo):
        if self.gps_active:
            try:
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

                else:
                    self.gps_active = False

            except Exception as e:
                TOMsMessageLog.logMessage(("In GPS - exception: " + str(e)),
                                         level=Qgis.Warning)
                self.gpsError.emit(e)
            return

        # shutdown the receiver
        if self.gpsCon is not None:
            self.gpsCon.close()
        self.connectionRegistry.unregisterConnection(self.gpsCon)
        self.gpsDeactivated.emit()

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
