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

import os, time

#from qgis.gui import *

# from .CadNodeTool.TOMsNodeTool import TOMsNodeTool
from TOMs.core.TOMsMessageLog import TOMsMessageLog
from TOMs.search_bar import searchBar
from .mapTools import CreateRestrictionTool, CreatePointTool
from .gnss_thread import GPS_Thread
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

        self.gnssToolGroup = QActionGroup(featuresWithGPSToolbar)
        self.actionCreateRestriction = QAction(QIcon(":/plugins/featureswithgps/resources/mActionAddTrack.svg"),
                               QCoreApplication.translate("MyPlugin", "Create Restriction"),
                               self.iface.mainWindow())
        self.actionCreateRestriction.setCheckable(True)

        self.actionAddGPSLocation = QAction(QIcon(":/plugins/featureswithgps/resources/greendot3.png"),
                               QCoreApplication.translate("MyPlugin", "Add vertex from gnss"),
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
        self.gnssToolGroup.addAction(self.actionRestrictionDetails)

        self.actionCreateSign = QAction(QIcon(":/plugins/featureswithgps/resources/mActionSetEndPoint.svg"),
                                                    QCoreApplication.translate("MyPlugin", "Create sign from gnss"),
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
        #self.featuresWithGPSToolbar.addAction(self.actionRemoveRestriction)
        self.featuresWithGPSToolbar.addAction(self.actionCreateSign)
        #self.featuresWithGPSToolbar.addAction(self.actionCreateMTR)

        self.gnssToolGroup.addAction(self.actionCreateRestriction)
        #self.gnssToolGroup.addAction(self.actionAddGPSLocation)
        #self.gnssToolGroup.addAction(self.actionRemoveRestriction)
        self.gnssToolGroup.addAction(self.actionRestrictionDetails)
        #self.gnssToolGroup.addAction(self.actionCreateSign)
        #self.gnssToolGroup.addAction(self.actionCreateMTR)
        self.gnssToolGroup.setExclusive(True)
        self.gnssToolGroup.triggered.connect(self.onGroupTriggered)

        # Connect action signals to slots

        self.actionCreateRestriction.triggered.connect(self.doCreateRestriction)
        self.actionAddGPSLocation.triggered.connect(self.doAddGPSLocation)
        self.actionRestrictionDetails.triggered.connect(self.doRestrictionDetails)
        #self.actionRemoveRestriction.triggered.connect(self.doRemoveRestriction)
        self.actionCreateSign.triggered.connect(self.doCreateSign)
        #self.actionCreateMTR.triggered.connect(self.doCreateMTR)

        self.actionCreateRestriction.setEnabled(False)
        self.actionAddGPSLocation.setEnabled(False)
        self.actionRestrictionDetails.setEnabled(False)
        #self.actionRemoveRestriction.setEnabled(False)
        self.actionCreateSign.setEnabled(False)
        #self.actionCreateMTR.setEnabled(False)

        self.searchBar = searchBar(self.iface, self.featuresWithGPSToolbar)
        self.searchBar.disableSearchBar()

        self.mapTool = None
        self.currGnssAction = None

    def enableFeaturesWithGPSToolbarItems(self):

        TOMsMessageLog.logMessage("In enablefeaturesWithGPSToolbarItems", level=Qgis.Warning)
        self.gpsAvailable = False
        self.closeTOMs = False

        self.tableNames = gpsLayers(self.iface)
        self.params = gpsParams()

        self.tableNames.TOMsLayersNotFound.connect(self.setCloseTOMsFlag)
        #self.tableNames.gpsLayersNotFound.connect(self.setCloseCaptureGPSFeaturesFlag)
        self.params.TOMsParamsNotFound.connect(self.setCloseCaptureGPSFeaturesFlag)

        self.prj = QgsProject().instance()
        self.dest_crs = self.prj.crs()
        TOMsMessageLog.logMessage("In captureGPSFeatures::init project CRS is " + self.dest_crs.description(),
                                 level=Qgis.Warning)
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
        TOMsMessageLog.logMessage("In enableFeaturesWithGPSToolbarItems: GPS port is: {}".format(gpsPort), level=Qgis.Warning)
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

            try:
                self.roamDistance = float(self.params.setParam("roamDistance"))
            except Exception as e:
                TOMsMessageLog.logMessage("In enableFeaturesWithGPSToolbarItems:init: roamDistance issue: {}".format(e), level=Qgis.Warning)
                self.roamDistance = 5.0

        self.enableToolbarItems()

        self.createMapToolDict = {}

    def enableToolbarItems(self):
        TOMsMessageLog.logMessage("In enableToolbarItems", level=Qgis.Warning)
        self.actionCreateRestriction.setEnabled(True)
        self.actionRestrictionDetails.setEnabled(True)
        #self.actionRemoveRestriction.setEnabled(True)
        #self.actionCreateSign.setEnabled(True)
        #self.actionCreateMTR.setEnabled(True)

        self.searchBar.enableSearchBar()

        self.currMapTool = None
        self.theCurrentMapTool = None

        self.iface.currentLayerChanged.connect(self.changeCurrLayer2)
        self.canvas.mapToolSet.connect(self.changeMapTool2)
        self.canvas.extentsChanged.connect(self.changeExtents)

    def enableGnssToolbarItem(self):
        if self.gpsConnection:
            self.actionAddGPSLocation.setEnabled(True)
            self.actionCreateSign.setEnabled(True)
            self.lastCentre = QgsPointXY(0,0)

    def disableGnssToolbarItem(self):
        self.actionAddGPSLocation.setEnabled(False)
        self.actionCreateSign.setEnabled(False)

    def disableToolbarItems(self):

        self.actionCreateRestriction.setEnabled(False)
        self.actionRestrictionDetails.setEnabled(False)
        self.actionRemoveRestriction.setEnabled(False)
        self.actionCreateSign.setEnabled(False)
        self.actionCreateMTR.setEnabled(False)

        self.searchBar.disableSearchBar()

        """if self.gpsConnection:
            self.actionAddGPSLocation.setEnabled(False)"""

    def setCloseTOMsFlag(self):
        self.closeTOMs = True
        QMessageBox.information(self.iface.mainWindow(), "ERROR", ("Now closing TOMs ..."))

    def disableFeaturesWithGPSToolbarItems(self):

        TOMsMessageLog.logMessage("In disablefeaturesWithGPSToolbarItems", level=Qgis.Warning)
        if self.gpsConnection and not self.closeTOMs:
            self.gps_thread.endGPS()

        self.disableToolbarItems()

        # TODO: Need to delete any tools ...
        for layer, mapTool in self.createMapToolDict.items  ():
            status = layer.rollBack()
            """if layer.rollBack() == False:
                reply = QMessageBox.information(None, "Information",
                                                "Problem rolling back changes" + str(self.currLayer.commitErrors()),
                                                QMessageBox.Ok)"""
            del mapTool

        self.createMapToolDict = {}

        try:
            self.iface.currentLayerChanged.disconnect(self.changeCurrLayer2)
        except Exception as e:
            TOMsMessageLog.logMessage(
                "In disableFeaturesWithGPSToolbarItems. Issue with disconnects for currentLayerChanged {}".format(e),
                level=Qgis.Warning)

        try:
            self.canvas.mapToolSet.disconnect(self.changeMapTool2)
        except Exception as e:
            TOMsMessageLog.logMessage(
                "In disableFeaturesWithGPSToolbarItems. Issue with disconnects for mapToolSet {}".format(
                    e),
                level=Qgis.Warning)

        try:
            self.canvas.extentsChanged.disconnect(self.changeExtents)
        except Exception as e:
            TOMsMessageLog.logMessage(
                "In disableFeaturesWithGPSToolbarItems. Issue with disconnects for extentsChanged {}".format(
                    e),
                level=Qgis.Warning)

        self.tableNames.removePathFromLayerForms()

    def setCloseCaptureGPSFeaturesFlag(self):
        self.closeCaptureGPSFeatures = True
        self.gpsAvailable = True

    def onGroupTriggered(self, action):
        # hold the current action
        self.currGnssAction = action
        TOMsMessageLog.logMessage("In onGroupTriggered: curr action is {}".format(action.text()), level=Qgis.Info)

    """ 
        Using signals for ChangeTool and ChangeLayer to manage the tools - with the following functions
    """
    def isGnssTool(self, mapTool):

        if (isinstance(mapTool, CreateRestrictionTool) or
           isinstance(mapTool, GeometryInfoMapTool) or
           isinstance(mapTool, RemoveRestrictionTool)):
            return True

        return False

    def changeMapTool2(self):
        TOMsMessageLog.logMessage(
            "In changeMapTool2 ...", level=Qgis.Info)

        currMapTool = self.iface.mapCanvas().mapTool()

        if not self.isGnssTool(currMapTool):
            TOMsMessageLog.logMessage(
                "In changeMapTool2. Unchecking action ...", level=Qgis.Info)
            if self.currGnssAction:
                self.currGnssAction.setChecked(False)
        else:
            TOMsMessageLog.logMessage(
            "In changeMapTool2. No action for gnssTools.", level=Qgis.Info)

        TOMsMessageLog.logMessage(
            "In changeMapTool2. finished.", level=Qgis.Info)
        #print('tool unset')

    def changeCurrLayer2(self):
        TOMsMessageLog.logMessage("In changeLayer2 ... ", level=Qgis.Info)

        currMapTool = self.iface.mapCanvas().mapTool()

        try:
            self.currGnssAction.setChecked(False)
        except Exception as e:
            None

        """if self.isGnssTool(currMapTool):
            TOMsMessageLog.logMessage("In changeLayer2. Action triggered ... ", level=Qgis.Info)
            self.currGnssAction.trigger()  # assumption is that there is an action associated with the tool
        else:
            TOMsMessageLog.logMessage(
            "In changeLayer2. No action for currentMapTool.", level=Qgis.Info)"""

        TOMsMessageLog.logMessage(
            "In changeLayer2. finished.", level=Qgis.Info)
        print('layer changed')


    def doCreateRestriction(self):

        TOMsMessageLog.logMessage("In doCreateRestriction", level=Qgis.Info)

        self.currLayer = self.iface.activeLayer()
        if not self.currLayer:
            reply = QMessageBox.information(self.iface.mainWindow(), "Information", "Please choose a layer ...",
                                            QMessageBox.Ok)
            return

        # TODO: Check that this is a restriction layer

        if self.actionCreateRestriction.isChecked():

            TOMsMessageLog.logMessage("In doCreateRestriction - tool activated", level=Qgis.Info)
            TOMsMessageLog.logMessage(
                "In doCreateRestriction: current map tool {}".format(type(self.iface.mapCanvas().mapTool()).__name__),
                level=Qgis.Info)

            self.createRestrictionMapTool = self.createMapToolDict.get(self.currLayer)

            if not self.createRestrictionMapTool:
                TOMsMessageLog.logMessage("In doCreateRestriction. creating new map tool", level=Qgis.Info)
                self.createRestrictionMapTool = CreateRestrictionTool(self.iface, self.currLayer)
                self.createMapToolDict[self.currLayer] = self.createRestrictionMapTool

            TOMsMessageLog.logMessage("In doCreateRestriction. Here 1", level=Qgis.Info)

            self.iface.mapCanvas().setMapTool(self.createRestrictionMapTool)

            TOMsMessageLog.logMessage("In doCreateRestriction. Here 2", level=Qgis.Info)

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

            TOMsMessageLog.logMessage("In doCreateRestriction. Here 3", level=Qgis.Info)

        else:

            TOMsMessageLog.logMessage("In doCreateRestriction - tool deactivated", level=Qgis.Info)

            if self.createRestrictionMapTool:
                self.iface.mapCanvas().unsetMapTool(self.createRestrictionMapTool)

            self.currMapTool = None
            self.currentlySelectedLayer = None

            self.actionCreateRestriction.setChecked(False)

            # TODO: stop editting on layers??

        TOMsMessageLog.logMessage("In doCreateRestriction. Here 4", level=Qgis.Info)



    # -- end of tools for signals

    def changeExtents(self):
        TOMsMessageLog.logMessage("In changeExtents ... ", level=Qgis.Info)

    def doAddGPSLocation(self):

        # need to have a addPointFromGPS function within each tool

        TOMsMessageLog.logMessage("In doAddGPSLocation", level=Qgis.Info)

        if self.gpsConnection:

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
        """
            Select point and then display details. Assume that there is only one of these map tools in existence at any one time ??
        """
        TOMsMessageLog.logMessage("In doRestrictionDetails", level=Qgis.Info)

        # TODO: Check whether or not there is a create maptool available. If so, stop this and finish using that/those tools

        if not self.iface.activeLayer():
            reply = QMessageBox.information(self.iface.mainWindow(), "Information", "Please choose a layer ...",
                                            QMessageBox.Ok)
            return

        if self.actionRestrictionDetails.isChecked():

            TOMsMessageLog.logMessage("In doRestrictionDetails - tool activated", level=Qgis.Warning)

            self.showRestrictionMapTool = GeometryInfoMapTool(self.iface)
            self.iface.mapCanvas().setMapTool(self.showRestrictionMapTool)
            self.showRestrictionMapTool.notifyFeatureFound.connect(self.showRestrictionDetails)

        else:

            TOMsMessageLog.logMessage("In doRestrictionDetails - tool deactivated", level=Qgis.Warning)

            if self.showRestrictionMapTool:
                self.iface.mapCanvas().unsetMapTool(self.showRestrictionMapTool)

            self.actionRestrictionDetails.setChecked(False)

    #@pyqtSlot(str)
    def showRestrictionDetails(self, closestLayer, closestFeature):

        TOMsMessageLog.logMessage(
            "In showRestrictionDetails ... Layer: " + str(closestLayer.name()),
            level=Qgis.Info)

        self.showRestrictionMapTool.notifyFeatureFound.disconnect(self.showRestrictionDetails)

        # TODO: could improve ... basically check to see if transaction in progress ...
        if closestLayer.isEditable() == True:
            reply = QMessageBox.question(None, "Information",
                                            "There is a transaction in progress on this layer. This action will rollback back any changes. Do you want to continue?",
                                            QMessageBox.Yes, QMessageBox.No)
            if reply == QMessageBox.No:
                return
            if closestLayer.commitChanges() == False:
                reply = QMessageBox.information(None, "Information",
                                                "Problem committing changes" + str(closestLayer.commitErrors()),
                                                QMessageBox.Ok)
            else:
                TOMsMessageLog.logMessage("In showRestrictionDetails: changes committed", level=Qgis.Info)

        """if self.iface.activeLayer().readOnly() == True:
            TOMsMessageLog.logMessage("In showSignDetails - Not able to start transaction ...",
                                     level=Qgis.Info)
        else:
            if self.iface.activeLayer().startEditing() == False:
                reply = QMessageBox.information(None, "Information",
                                                "Could not start transaction on " + self.currLayer.name(),
                                                QMessageBox.Ok)
                return"""

        self.dialog = self.iface.getFeatureForm(closestLayer, closestFeature)
        #self.TOMsUtils.setupRestrictionDialog(self.dialog, closestLayer, closestFeature)
        self.setupFieldRestrictionDialog(self.dialog, closestLayer, closestFeature)

        self.dialog.show()

    """
        Decided that it is best to use the QGIS select/delete tools to manage removals. So these functions are not used
    """
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
            #self.iface.currentLayerChanged.connect(self.changeCurrLayer)
            #self.canvas.mapToolSet.connect(self.changeMapTool)

            self.removeRestrictionMapTool.notifyFeatureFound.connect(self.removeRestriction)

        else:

            TOMsMessageLog.logMessage("In doRemoveRestriction - tool deactivated", level=Qgis.Warning)

            self.removeRestrictionMapTool.notifyFeatureFound.disconnect(self.removeRestriction)

            #self.canvas.mapToolSet.disconnect(self.changeMapTool)
            #self.iface.currentLayerChanged.disconnect(self.changeCurrLayer)

            self.iface.mapCanvas().unsetMapTool(self.removeRestrictionMapTool)
            #self.removeRestrictionMapTool.deactivate()
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

    """
        This is a tool for adding a point feature. currently only used for signs, but could be used for any point
    """
    def doCreateSign(self):

        TOMsMessageLog.logMessage("In doCreateSign", level=Qgis.Info)

        if self.actionCreateSign.isChecked():

            self.currMapTool = self.canvas.mapTool()
            self.currentlySelectedLayer = self.iface.activeLayer()
            self.signsLayer = self.tableNames.setLayer("Signs")

            self.iface.setActiveLayer(self.signsLayer)

            self.createPointMapTool = CreatePointTool(self.iface, self.signsLayer)

            TOMsMessageLog.logMessage("In doCreateSign - tool activated", level=Qgis.Info)

            self.signsLayer.editingStopped.connect(self.reinstateMapTool)

            self.actionCreateSign.setChecked(False)

            self.iface.mapCanvas().setMapTool(self.createPointMapTool)

            """ add the point from the gnss """
            try:
                status = self.canvas.mapTool().addPointFromGPS(self.curr_gps_location, self.curr_gps_info)
            except Exception as e:
                TOMsMessageLog.logMessage("In doCreateSign: Problem adding gnss location: {}".format(e),
                                          level=Qgis.Warning)
                reply = QMessageBox.information(self.iface.mainWindow(), "Error",
                                                "Problem adding gnss location ... ",
                                                QMessageBox.Ok)

    """
        Not currently used, but want to develop ...
    """
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

    """
        Used with the createSign tool to reinstate the last used maptool, i.e., to allow the interupt of feature creation
    """

    def reinstateMapTool(self):

        TOMsMessageLog.logMessage("In reinstateMapTool ... ", level=Qgis.Info)
        self.iface.activeLayer().editingStopped.disconnect(self.reinstateMapTool)

        if self.currMapTool:

            TOMsMessageLog.logMessage(
                "In reinstateMapTool. layer to be reinstated {} using tool {}".format(self.currentlySelectedLayer.name(), self.currMapTool.toolName()),
                level=Qgis.Warning)
            # now reinstate
            if self.currentlySelectedLayer:
                self.iface.setActiveLayer(self.currentlySelectedLayer)

            self.iface.mapCanvas().setMapTool(self.currMapTool)

    #@pyqtSlot(QgsGpsConnection)
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

        self.enableGnssToolbarItem()
        reply = QMessageBox.information(None, "Information",
                                            "Connection found",
                                            QMessageBox.Ok)

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
        self.disableGnssToolbarItem()

    #@pyqtSlot()
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
        #self.canvas.setCenter(mapPointXY)

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

    #@pyqtSlot(Exception, str)
    def gpsErrorEncountered(self, e):
        TOMsMessageLog.logMessage("In enableTools - GPS connection has error {}".format(e),
                                     level=Qgis.Warning)
        """self.actionCreateRestriction.setEnabled(False)
        self.actionAddGPSLocation.setEnabled(False)"""
        self.disableGnssToolbarItem()

