# -*- coding: utf-8 -*-
"""
/***************************************************************************
 movingTrafficSigns
                                 A QGIS plugin
 movingTrafficeSigns
                              -------------------
        begin                : 2019-05-08
        git sha              : $Format:%H$
        copyright            : (C) 2019 by TH
        email                : th@mhtc.co.uk
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
"""

#import resources
# Import the code for the dialog

import os.path

from qgis.PyQt.QtWidgets import (
    QMessageBox,
    QAction,
    QDialogButtonBox,
    QLabel,
    QDockWidget,
    QDialog,
    QLabel,
    QPushButton,
    QApplication,
    QMenu
)

from qgis.PyQt.QtGui import (
    QIcon,
    QPixmap,
    QImage
)


from qgis.PyQt.QtCore import (
    QObject,
    QThread,
    pyqtSignal,
    pyqtSlot,
    Qt,
    QSettings, QTranslator, qVersion, QCoreApplication,
    QDateTime
)

from qgis.core import (
    QgsMessageLog,
    QgsExpressionContextUtils,
    QgsWkbTypes,
    QgsMapLayer, Qgis, QgsRectangle,
    QgsFeatureRequest, QgsVectorLayer, QgsFeature,
    QgsProject
)
from qgis.gui import (
    QgsMapToolIdentify
)
#from qgis.core import *
#from qgis.gui import *
from TOMs.core.TOMsMessageLog import TOMsMessageLog
from .fieldRestrictionTypeUtilsClass import FieldRestrictionTypeUtilsMixin, gpsParams
from TOMs.restrictionTypeUtilsClass import TOMsLayers, TOMsConfigFile

#from .formUtils import demandFormUtils

#############################################################################

class GeometryInfoMapTool(FieldRestrictionTypeUtilsMixin, QgsMapToolIdentify):

    notifyFeatureFound = pyqtSignal(QgsVectorLayer, QgsFeature)

    def __init__(self, iface):
        QgsMapToolIdentify.__init__(self, iface.mapCanvas())
        self.iface = iface
        FieldRestrictionTypeUtilsMixin.__init__(self, iface)

        try:
            self.SIGN_TYPES = QgsProject.instance().mapLayersByName("SignTypes")[0]
            self.MHTC_CHECK_ISSUE_TYPES = QgsProject.instance().mapLayersByName("MHTC_CheckIssueTypes")[0]
        except:
            None   # if "Signs" is not present

    def canvasReleaseEvent(self, event):
        # Return point under cursor

        self.event = event

        closestFeature, closestLayer = self.findNearestFeatureAtC(event.pos())

        TOMsMessageLog.logMessage(("In Info - canvasReleaseEvent."), level=Qgis.Info)

        # Remove any current selection and add the new ones (if appropriate)

        if closestLayer == None:

            if self.iface.activeLayer():
                self.iface.activeLayer().removeSelection()

        else:

            TOMsMessageLog.logMessage(("In Info - canvasReleaseEvent. Feature selected from layer: " + closestLayer.name() + " id: " + str(
                    closestFeature.id())), level=Qgis.Info)

            if not closestLayer == self.iface.activeLayer():
                if self.iface.activeLayer():
                    self.iface.activeLayer().removeSelection()
                self.iface.setActiveLayer(closestLayer)

            if closestLayer.type() == QgsMapLayer.VectorLayer:
                TOMsMessageLog.logMessage(("In Info - canvasReleaseEvent. layer type " + str(closestLayer.type())),
                                         level=Qgis.Info)

            if closestLayer.geometryType() == QgsWkbTypes.PointGeometry:
                TOMsMessageLog.logMessage(("In Info - canvasReleaseEvent. point layer type "), level=Qgis.Info)

            if closestLayer.geometryType() == QgsWkbTypes.LineGeometry:
                TOMsMessageLog.logMessage(("In Info - canvasReleaseEvent. line layer type "), level=Qgis.Info)

            #self.notifyFeatureFound.emit(closestLayer, closestFeature)
            self.showRestrictionDetails(closestLayer, closestFeature)

            """TOMsMessageLog.logMessage(
                "In GeometryInfoMapTool - releaseEvent. currRestrictionLayer: " + str(closestLayer.name()),
                level=Qgis.Info)

            # TODO: Sort out this for UPDATE
            # self.setDefaultRestrictionDetails(closestFeature, closestLayer)
            dialog = self.iface.getFeatureForm(closestLayer, closestFeature)
            self.setupDemandDialog(dialog, closestLayer, closestFeature)  # connects signals, etc
            dialog.show()"""

        pass

    def transformCoordinates(self, screenPt):
        """ Convert a screen coordinate to map and layer coordinates.

            returns a (mapPt,layerPt) tuple.
        """
        return (self.toMapCoordinates(screenPt))

    def findNearestFeatureAtC(self, pos):
        #  def findFeatureAt(self, pos, excludeFeature=None):
        # http://www.lutraconsulting.co.uk/blog/2014/10/17/getting-started-writing-qgis-python-plugins/ - generates "closest feature" function

        """ Find the feature close to the given position.

            'pos' is the position to check, in canvas coordinates.

            if 'excludeFeature' is specified, we ignore this feature when
            finding the clicked-on feature.

            If no feature is close to the given coordinate, we return None.
        """
        mapPt = self.transformCoordinates(pos)
        tolerance = 1.0
        searchRect = QgsRectangle(mapPt.x() - tolerance,
                                  mapPt.y() - tolerance,
                                  mapPt.x() + tolerance,
                                  mapPt.y() + tolerance)

        request = QgsFeatureRequest()
        request.setFilterRect(searchRect)
        request.setFlags(QgsFeatureRequest.ExactIntersect)

        #self.RestrictionLayers = QgsMapLayerRegistry.instance().mapLayersByName("RestrictionLayers")[0]
        #self.currLayer = QgsMapLayerRegistry.instance().mapLayersByName("MovingTrafficSigns")[0]
        self.currLayer = self.iface.activeLayer()
        featureList = []
        layerList = []

        # Loop through all features in the layer to find the closest feature
        for f in self.currLayer.getFeatures(request):
            # Add any features that are found should be added to a list
            featureList.append(f)
            layerList.append(self.currLayer)

        TOMsMessageLog.logMessage("In findNearestFeatureAt: Considering layer: {}; nrFeatures: {}".format(self.currLayer.name(), len(featureList)), level=Qgis.Info)

        if len(featureList) == 0:
            return None, None
        elif len(featureList) == 1:
            return featureList[0], layerList[0]
        else:
            # set up a context menu
            TOMsMessageLog.logMessage("In findNearestFeatureAt: multiple features: " + str(len(featureList)),
                                     level=Qgis.Info)

            feature, layer = self.getFeatureDetails(featureList, layerList)
            # TODO: Need to pick up primary key(s)
            """TOMsMessageLog.logMessage("In findNearestFeatureAt: feature: " + str(feature.attribute('id')),
                                     level=Qgis.Info)"""

            return feature, layer

        pass

    def getFeatureDetails(self, featureList, layerList):
        TOMsMessageLog.logMessage("In getFeatureDetails", level=Qgis.Info)

        #self.featureList = featureList
        #self.layerList = layerList

        actionFeatureList = []
        # Creates the context menu and returns the selected feature and layer
        TOMsMessageLog.logMessage("In getFeatureDetails: nrFeatures: " + str(len(featureList)), level=Qgis.Info)

        self.actions = []
        self.menu = QMenu(self.iface.mapCanvas())

        for feature in featureList:

            #title = str(feature.id())

            # might be able to do same for each restriction/feature ...

            currGeometryID = str(feature.attribute('GeometryID'))
            if self.currLayer.name() == "Signs":
                # Need to get each of the signs ...
                for i in range (1,10):
                    field_index = self.currLayer.fields().indexFromName("SignType_{counter}".format(counter=i))
                    if field_index == -1:
                        break
                    if feature[field_index]:
                        title = "Sign: {RestrictionDescription} [{GeometryID}] ({CheckStatus})".format(RestrictionDescription=str(
                            self.getLookupDescription(self.SIGN_TYPES, feature[field_index])),
                             GeometryID=currGeometryID,
                             CheckStatus=str(self.getLookupDescription(self.MHTC_CHECK_ISSUE_TYPES, feature.attribute('MHTC_CheckIssueTypeID'))))

                        actionFeatureList.append(title)

            else:

                title = "[{GeometryID}]".format(GeometryID=currGeometryID)
                #featureList.append(title)

            TOMsMessageLog.logMessage("In featureContextMenu: adding: " + str(title), level=Qgis.Info)


            action = QAction(title, self.menu)
            self.actions.append(action)

            self.menu.addAction(action)

        TOMsMessageLog.logMessage("In getFeatureDetails: showing menu?", level=Qgis.Info)

        clicked_action = self.menu.exec_(self.iface.mapCanvas().mapToGlobal(self.event.pos()))
        TOMsMessageLog.logMessage(("In getFeatureDetails:clicked_action: " + str(clicked_action)), level=Qgis.Warning)

        if clicked_action is not None:

            TOMsMessageLog.logMessage(("In getFeatureDetails:clicked_action: " + str(clicked_action.text())),
                                     level=Qgis.Warning)
            idxList = self.getIdxFromGeometryID(clicked_action.text(), featureList)

            TOMsMessageLog.logMessage("In getFeatureDetails: idx = " + str(idxList), level=Qgis.Warning)

            if idxList >= 0:
                # TODO: need to be careful here so that we use primary key
                return featureList[idxList], layerList[idxList]

        TOMsMessageLog.logMessage(("In getFeatureDetails. No action found."), level=Qgis.Warning)

        return None, None


    def getIdxFromGeometryID(self, clicked_action_text, featureList):
        #
        TOMsMessageLog.logMessage("In getIdxFromGeometryID", level=Qgis.Info)

        selectedGeometryID = clicked_action_text[clicked_action_text.find('[') + 1:clicked_action_text.find(']')]
        idx = -1
        TOMsMessageLog.logMessage("In getFeatureDetails. id = {}".format(selectedGeometryID), level=Qgis.Warning)
        for idx in range(len(featureList)):
            if featureList[idx].attribute('GeometryID') == selectedGeometryID:
                return idx

        return idx

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

        status = self.iface.activeLayer().startEditing()

        dialog = self.iface.getFeatureForm(closestLayer, closestFeature)
        #self.TOMsUtils.setupRestrictionDialog(self.dialog, closestLayer, closestFeature)
        self.setupFieldRestrictionDialog(dialog, closestLayer, closestFeature)

        dialog.show()

class RemoveRestrictionTool(GeometryInfoMapTool):
    #notifyFeatureFound = QtCore.pyqtSignal(QgsVectorLayer, QgsFeature)

    def __init__(self, iface):
        GeometryInfoMapTool.__init__(self, iface)
        self.iface = iface

    def canvasReleaseEvent(self, event):  # TODO: need to rethink how this is done ....
        # Return point under cursor

        self.event = event

        closestFeature, closestLayer = self.findNearestFeatureAtC(event.pos())

        TOMsMessageLog.logMessage(("In Info - canvasReleaseEvent."), level=Qgis.Info)

        # Remove any current selection and add the new ones (if appropriate)

        if closestLayer == None:

            if self.iface.activeLayer():
                self.iface.activeLayer().removeSelection()

        else:

            TOMsMessageLog.logMessage(("In Info - canvasReleaseEvent. Feature selected from layer: " + closestLayer.name() + " id: " + str(
                    closestFeature.id())), level=Qgis.Info)

            if not closestLayer == self.iface.activeLayer():
                if self.iface.activeLayer():
                    self.iface.activeLayer().removeSelection()
                self.iface.setActiveLayer(closestLayer)

            if closestLayer.type() == QgsMapLayer.VectorLayer:
                TOMsMessageLog.logMessage(("In Info - canvasReleaseEvent. layer type " + str(closestLayer.type())),
                                         level=Qgis.Info)

            if closestLayer.geometryType() == QgsWkbTypes.PointGeometry:
                TOMsMessageLog.logMessage(("In Info - canvasReleaseEvent. point layer type "), level=Qgis.Info)

            if closestLayer.geometryType() == QgsWkbTypes.LineGeometry:
                TOMsMessageLog.logMessage(("In Info - canvasReleaseEvent. line layer type "), level=Qgis.Info)

            self.notifyFeatureFound.emit(closestLayer, closestFeature)
            #self.showRestrictionDetails(closestLayer, closestFeature)
