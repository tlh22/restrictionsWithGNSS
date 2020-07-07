#-----------------------------------------------------------
# Licensed under the terms of GNU GPL 2
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#---------------------------------------------------------------------
# Tim Hancock 2017
#
""" mapTools.py

    # Taken from Erik Westra's book


    This module defines the various QgsMapTool subclasses used by the
    "ForestTrails" application.
"""

import math
import time

#from qgis.core import *
#from qgis.gui import *

from qgis.PyQt.QtGui import (
    QColor,
QMouseEvent
)
from qgis.PyQt.QtCore import (
    QSettings,
    QEvent,
    QPoint,
    Qt,
    QRect, QTimer, pyqtSignal, pyqtSlot, QDate
)

#from qgis.PyQt.QtCore import *
#from qgis.PyQt.QtGui import *
from qgis.PyQt.QtWidgets import QMenu, QAction, QDockWidget, QMessageBox, QToolTip

from qgis.core import (
    Qgis,
    QgsGeometry,
    QgsGeometryCollection,
    QgsCurve,
    QgsCurvePolygon,
    QgsMessageLog,
    QgsMultiCurve,
    QgsPoint,
    QgsPointXY,
    QgsPointLocator,
    QgsVertexId,
    QgsVectorLayer,
    QgsRectangle,
    QgsProject,
    QgsFeatureRequest,
    QgsTolerance,
    QgsSnappingUtils,
    QgsSnappingConfig,
    QgsWkbTypes, QgsMapLayer, QgsExpression, QgsExpressionContext, QgsExpressionContextUtils, QgsFeature, QgsTracer,
    QgsApplication, QgsGpsConnection, QgsCoordinateTransform, QgsCoordinateReferenceSystem
)
from qgis.gui import (
    QgsVertexMarker,
    QgsMapToolAdvancedDigitizing,
    QgsRubberBand,
    QgsMapMouseEvent,
    QgsMapToolIdentify, QgsMapToolCapture, QgsMapTool,
    QgsMapToolEmitPoint
)


from .fieldRestrictionTypeUtilsClass import FieldRestrictionTypeUtilsMixin
from TOMs.core.TOMsMessageLog import TOMsMessageLog

import functools

import uuid

#############################################################################

class MapToolMixin:
    """ Mixin class that defines various helper methods for a QgsMapTool.
    """
    def setLayer(self, layer):
        self.layer        = layer
        self.lastPlayTime = None

    def transformCoordinates(self, screenPt):
        """ Convert a screen coordinate to map and layer coordinates.

            returns a (mapPt,layerPt) tuple.
        """
        return (self.toMapCoordinates(screenPt))

    def calcTolerance(self, pos):
        """ Calculate the "tolerance" to use for a mouse-click.

            'pos' is a QPoint object representing the clicked-on point, in
            canvas coordinates.

            The tolerance is the number of map units away from the click
            position that a vertex or geometry can be and we still consider it
            to be a click on that vertex or geometry.
        """
        pt1 = QPoint(pos.x(), pos.y())
        pt2 = QPoint(pos.x() + 10, pos.y())

        mapPt1 = self.transformCoordinates(pt1)
        mapPt2 = self.transformCoordinates(pt2)
        tolerance = mapPt2.x() - mapPt1.x()

        return tolerance

    def findNearestFeatureAt(self, pos):
        #  def findFeatureAt(self, pos, excludeFeature=None):
        # http://www.lutraconsulting.co.uk/blog/2014/10/17/getting-started-writing-qgis-python-plugins/ - generates "closest feature" function

        """ Find the feature close to the given position.

            'pos' is the position to check, in canvas coordinates.

            if 'excludeFeature' is specified, we ignore this feature when
            finding the clicked-on feature.

            If no feature is close to the given coordinate, we return None.
        """
        mapPt = self.transformCoordinates(pos)
        #tolerance = self.calcTolerance(pos)
        tolerance = 0.5
        searchRect = QgsRectangle(mapPt.x() - tolerance,
                                  mapPt.y() - tolerance,
                                  mapPt.x() + tolerance,
                                  mapPt.y() + tolerance)

        request = QgsFeatureRequest()
        request.setFilterRect(searchRect)
        request.setFlags(QgsFeatureRequest.ExactIntersect)

        '''for feature in self.layer.getFeatures(request):
            if excludeFeature != None:
                if feature.id() == excludeFeature.id():
                    continue
            return feature '''

        self.RestrictionLayers = QgsProject.instance().mapLayersByName("RestrictionLayers")[0]

        #currLayer = self.TOMslayer  # need to loop through the layers and choose closest to click point
        #iface.setActiveLayer(currLayer)

        shortestDistance = float("inf")

        featureList = []
        layerList = []

        for layerDetails in self.RestrictionLayers.getFeatures():

            # Exclude consideration of CPZs
            if layerDetails.attribute("id") >= 6:  # CPZs
                continue

            self.currLayer = RestrictionTypeUtilsMixin.getRestrictionsLayer (layerDetails)

            # Loop through all features in the layer to find the closest feature
            for f in self.currLayer.getFeatures(request):
                # Add any features that are found should be added to a list
                featureList.append(f)
                layerList.append(self.currLayer)

                dist = f.geometry().distance(QgsGeometry.fromPointXY(mapPt))
                if dist < shortestDistance:
                    shortestDistance = dist
                    closestFeature = f
                    closestLayer = self.currLayer

        #QgsMessageLog.logMessage("In findNearestFeatureAt: shortestDistance: " + str(shortestDistance), level=Qgis.Info)
        TOMsMessageLog.logMessage("In findNearestFeatureAt: nrFeatures: " + str(len(featureList)), level=Qgis.Info)

        if shortestDistance < float("inf"):
            return closestFeature, closestLayer
        else:
            return None, None

        pass

    def findVertexAt(self, feature, pos):
        """ Find the vertex of the given feature close to the given position.

            'feature' is the QgsFeature to check, and 'pos' is the position to
            check, in canvas coordinates.

            We return the vertex number for the closest vertex, or None if no
            vertex is close enough to the given click position.
        """
        mapPt,layerPt = self.transformCoordinates(pos)
        tolerance     = self.calcTolerance(pos)

        vertexCoord,vertex,prevVertex,nextVertex,distSquared = \
            feature.geometry().closestVertex(layerPt)

        distance = math.sqrt(distSquared)
        if distance > tolerance:
            return None
        else:
            return vertex

    def snapToNearestVertex(self, pos, trackLayer, excludeFeature=None):
        """ Attempt to snap the given point to the nearest vertex.

            The parameters are as follows:

                'pos'

                    The click position, in canvas coordinates.

                'trackLayer'

                    The QgsVectorLayer which holds our track data.

                'excludeFeature'

                    If specified, this is a QgsFeature which will be excluded
                    from the check for nearby vertices.  This is used to
                    prevent snapping an object to itself.

            If the click position is close enough to a vertex in the track
            layer (excluding the given feature, if any), we return the
            coordinates of that vertex.  Otherwise, we return the click
            position itself in layer coordinates.  Either way, the returned
            point is in the map tool's layer's coordinates.
        """
        mapPt,layerPt = self.transformCoordinates(pos)
        feature = self.findFeatureAt(pos, excludeFeature)

        if feature == None:
            return layerPt

        vertex = self.findVertexAt(feature, pos)
        if vertex == None:
            return layerPt

        return feature.geometry().vertexAt(vertex)

#############################################################################


#############################################################################

class CreateRestrictionTool(FieldRestrictionTypeUtilsMixin, QgsMapToolCapture):
    # helpful link - http://apprize.info/python/qgis/7.html ??
    #deActivatedInProcess = pyqtSignal(bool)

    def __init__(self, iface, layer):

        TOMsMessageLog.logMessage(("In CreateRestrictionTool - init."), level=Qgis.Info)
        if layer.geometryType() == 0: # PointGeometry:
            captureMode = (CreateRestrictionTool.CapturePoint)
        elif layer.geometryType() == 1: # LineGeometry:
            captureMode = (CreateRestrictionTool.CaptureLine)
        elif layer.geometryType() == 2: # PolygonGeometry:
            captureMode = (CreateRestrictionTool.CapturePolygon)
        else:
            TOMsMessageLog.logMessage(("In CreateRestrictionTool - No geometry type found. EXITING ...."), level=Qgis.Info)
            return

        QgsMapToolCapture.__init__(self, iface.mapCanvas(), iface.cadDockWidget(), captureMode)
        FieldRestrictionTypeUtilsMixin.__init__(self, iface)

        # https: // qgis.org / api / classQgsMapToolCapture.html
        self.canvas = iface.mapCanvas()
        self.iface = iface
        self.layer = layer

        #self.inProcess = True

        """if self.layer.geometryType() == 0: # PointGeometry:
            self.captureMode = (CreateRestrictionTool.CapturePoint)
        elif self.layer.geometryType() == 1: # LineGeometry:
            self.captureMode(CreateRestrictionTool.CaptureLine)
        elif self.layer.geometryType() == 2: # PolygonGeometry:
            self.captureMode(CreateRestrictionTool.CapturePolygon)
        else:
            TOMsMessageLog.logMessage(("In CreateRestrictionTool - No geometry type found. EXITING ...."), level=Qgis.Info)
            return"""

        #self.dialog = dialog

        #advancedDigitizingPanel = self.iface.AdvancedDigitizingTools()

        self.setAutoSnapEnabled(True)

        """self.setAdvancedDigitizingAllowed(True)
        advancedDigitizingPanel = iface.mainWindow().findChild(QDockWidget, 'AdvancedDigitizingTools')
        if not advancedDigitizingPanel:
            QMessageBox.information(self.iface.mainWindow(), "ERROR",
                                    ("Advanced Digitising Panel is not present"))"""
        # TODO: Need to do something if this is not present

        #advancedDigitizingPanel.setVisible(True)
        #self.setupPanelTabs(self.iface, advancedDigitizingPanel)
        #QgsMapToolAdvancedDigitizing.activate(self)
        #self.iface.cadDockWidget().enable()

        #self.QgsWkbTypes = QgsWkbTypes()

        # I guess at this point, it is possible to set things like capture mode, snapping preferences, ... (not sure of all the elements that are required)
        # capture mode (... not sure if this has already been set? - or how to set it)

        TOMsMessageLog.logMessage("In CreateRestrictionTool - geometryType for " + str(self.layer.name()) + ": " + str(self.layer.geometryType()), level=Qgis.Info)

        TOMsMessageLog.logMessage(("In CreateRestrictionTool - mode set."), level=Qgis.Info)

        # Seems that this is important - or at least to create a point list that is used later to create Geometry
        self.sketchPoints = self.points()
        #self.setPoints(self.sketchPoints)  ... not sure when to use this ??

        # Set up rubber band. In current implementation, it is not showing feeback for "next" location

        self.rb = self.createRubberBand(QgsWkbTypes.LineGeometry)  # what about a polygon ??

        #self.currLayer = self.currentVectorLayer()
        self.currLayer = self.layer

        TOMsMessageLog.logMessage(("In CreateRestrictionTool - init. Curr layer is " + str(self.currLayer.name()) + "Incoming: " + str(self.layer)), level=Qgis.Info)

        # set up snapping configuration   *******************
        """
        TOMs_Layer = QgsMapLayerRegistry.instance().mapLayersByName("TOMs_Layer")[0]

        ConstructionLines = QgsMapLayerRegistry.instance().mapLayersByName("ConstructionLines")[0]

        snapping_layer1 = QgsSnappingUtils.LayerConfig(TOMs_Layer, QgsPointLocator.Vertex, 0.5,
                                                       QgsTolerance.LayerUnits)
        snapping_layer2 = QgsSnappingUtils.LayerConfig(RoadCasementLayer, QgsPointLocator.Vertex and QgsPointLocator.Edge, 0.5,
                                                       QgsTolerance.LayerUnits)
        snapping_layer3 = QgsSnappingUtils.LayerConfig(ConstructionLines, QgsPointLocator.Vertex and QgsPointLocator.Edge, 0.5,
                                                       QgsTolerance.LayerUnits)
        """
        #self.snappingConfig = QgsSnappingConfig()

        #self.snappingUtils.setLayers([snapping_layer1, snapping_layer2, snapping_layer3])

        #self.snappingConfig.setMode(QgsSnappingConfig.AdvancedConfiguration)

        # set up tracing configuration

        """self.TOMsTracer = QgsTracer()
        RoadCasementLayer = QgsProject.instance().mapLayersByName("RoadCasement")[0]
        traceLayersNames = [RoadCasementLayer]
        self.TOMsTracer.setLayers(traceLayersNames)

        # set an extent for the Tracer
        tracerExtent = iface.mapCanvas().extent()
        tolerance = 1000.0
        tracerExtent.setXMaximum(tracerExtent.xMaximum() + tolerance)
        tracerExtent.setYMaximum(tracerExtent.yMaximum() + tolerance)
        tracerExtent.setXMinimum(tracerExtent.xMinimum() - tolerance)
        tracerExtent.setYMinimum(tracerExtent.yMinimum() - tolerance)

        self.TOMsTracer.setExtent(tracerExtent)"""

        #self.TOMsTracer.setMaxFeatureCount(1000)
        self.lastPoint = None

        """if not self.layer.isEditable():
            if self.layer.startEditing() == False:
                reply = QMessageBox.information(None, "Information",
                                                "Could not start transaction on " + self.layer.name(),
                                                QMessageBox.Ok)"""

        # set up function to be called when capture is complete
        #self.onCreateRestriction = onCreateRestriction
        self.reset()

    def reset(self):
        #self.startPoint = self.endPoint = None
        self.rb.reset(True)

    def cadCanvasReleaseEvent(self, event):
        QgsMapToolCapture.cadCanvasReleaseEvent(self, event)
        TOMsMessageLog.logMessage(("In Create - cadCanvasReleaseEvent"), level=Qgis.Info)

        if event.button() == Qt.LeftButton:
            if not self.isCapturing():
                self.startCapturing()
            checkSnapping = event.isSnapped
            TOMsMessageLog.logMessage("In Create - cadCanvasReleaseEvent: checkSnapping = " + str(checkSnapping), level=Qgis.Info)

            #locator = self.snappingUtils.snapToMap(self.currPoint)

            # Now wanting to add point(s) to new shape. Take account of snapping and tracing
            self.currPoint = event.snapPoint()    #  1 is value of QgsMapMouseEvent.SnappingMode (not sure where this is defined)
            self.lastEvent = event
            # If this is the first point, add and k

            nrPoints = self.size()
            res = None

            if not self.lastPoint:

                self.result = self.addVertex(self.currPoint)
                TOMsMessageLog.logMessage("In Create - cadCanvasReleaseEvent: adding vertex 0 " + str(self.result), level=Qgis.Info)

            else:

                self.result = self.addVertex(self.currPoint)
                TOMsMessageLog.logMessage(("In CreateRestrictionTool - (adding shortest path) X:" + str(self.currPoint.x()) + " Y: " + str(self.currPoint.y())), level=Qgis.Info)

            self.lastPoint = self.currPoint

            TOMsMessageLog.logMessage(("In Create - cadCanvasReleaseEvent (AddVertex/Line) Result: " + str(self.result) + " X:" + str(self.currPoint.x()) + " Y:" + str(self.currPoint.y())), level=Qgis.Info)

        elif (event.button() == Qt.RightButton):
            # Stop capture when right button or escape key is pressed
            self.getPointsCaptured()

            # Need to think about the default action here if none of these buttons/keys are pressed.

        pass

    def keyPressEvent(self, event):
        if (event.key() == Qt.Key_Backspace) or (event.key() == Qt.Key_Delete) or (event.key() == Qt.Key_Escape):
            self.undo()
            pass
        if event.key() == Qt.Key_Return or event.key() == Qt.Key_Enter:
            pass
            # Need to think about the default action here if none of these buttons/keys are pressed. 

    def getPointsCaptured(self):
        TOMsMessageLog.logMessage(("In CreateRestrictionTool - getPointsCaptured"), level=Qgis.Info)

        # Check the number of points
        self.nrPoints = self.size()
        TOMsMessageLog.logMessage(("In CreateRestrictionTool - getPointsCaptured; Stopping: " + str(self.nrPoints)),
                                 level=Qgis.Info)

        self.sketchPoints = self.points()

        for point in self.sketchPoints:
            TOMsMessageLog.logMessage(("In CreateRestrictionTool - getPointsCaptured X:" + str(point.x()) + " Y: " + str(point.y())), level=Qgis.Info)

        # stop capture activity
        self.stopCapturing()

        if self.nrPoints > 0:

            # take points from the rubber band and copy them into the "feature"

            fields = self.layer.dataProvider().fields()
            feature = QgsFeature()
            feature.setFields(fields)

            TOMsMessageLog.logMessage(("In CreateRestrictionTool. getPointsCaptured, layerType: " + str(self.layer.geometryType())), level=Qgis.Info)

            if self.layer.geometryType() == 0:  # Point
                feature.setGeometry(QgsGeometry.fromPointXY(self.sketchPoints[0]))
            elif self.layer.geometryType() == 1:  # Line
                feature.setGeometry(QgsGeometry.fromPolylineXY(self.sketchPoints))
            elif self.layer.geometryType() == 2:  # Polygon
                feature.setGeometry(QgsGeometry.fromPolygonXY([self.sketchPoints]))
                #feature.setGeometry(QgsGeometry.fromPolygonXY(self.sketchPoints))
            else:
                TOMsMessageLog.logMessage(("In CreateRestrictionTool - no geometry type found"), level=Qgis.Info)
                return

            TOMsMessageLog.logMessage(("In Create - getPointsCaptured; geometry prepared; " + str(feature.geometry().asWkt())),
                                     level=Qgis.Info)

            if self.layer.name() == "ConstructionLines":
                self.layer.addFeature(feature)
            else:

                # set any geometry related attributes ...

                self.setDefaultFieldRestrictionDetails(feature, self.layer, QDate.currentDate())

                TOMsMessageLog.logMessage("In CreateRestrictionTool - getPointsCaptured. currRestrictionLayer: " + str(self.layer.name()),
                                         level=Qgis.Info)

                #newRestrictionID = str(uuid.uuid4())
                #feature[self.layer.fields().indexFromName("GeometryID")] = newRestrictionID
                self.layer.addFeature(feature)  # TH (added for v3)

                dialog = self.iface.getFeatureForm(self.layer, feature)

                self.setupFieldRestrictionDialog(dialog, self.layer, feature)  # connects signals, etc

                self.inProcess = False
                dialog.show()

            pass


    def addPointFromGPS(self, curr_gps_location, curr_gps_info):
        TOMsMessageLog.logMessage(
            "In CreateFeatureWithGPSTool - addPointFromGPS",
            level=Qgis.Info)

        status = self.addVertex(curr_gps_location)

        # TODO: opportunity to add details about GPS point to another table

        return status

class CreatePointTool(FieldRestrictionTypeUtilsMixin, QgsMapToolEmitPoint ):

    def __init__(self, iface, layer):

        TOMsMessageLog.logMessage(("In CreatePointTool - init."), level=Qgis.Info)

        self.iface = iface
        self.canvas = iface.mapCanvas()
        self.currLayer = layer

        QgsMapToolEmitPoint.__init__(self, iface.mapCanvas())
        FieldRestrictionTypeUtilsMixin.__init__(self, iface)

    def canvasReleaseEvent(self, event):

        TOMsMessageLog.logMessage(("In CreatePointTool - canvasReleaseEvent."), level=Qgis.Info)

        self.currLayer.startEditing()  # doesn't return true when editing started - and so using isEditable

        if self.currLayer.isEditable() == False:
            reply = QMessageBox.information(None, "Information",
                                            "Could not start transaction on " + self.currLayer.name(),
                                            QMessageBox.Ok)

        x = event.pos().x()
        y = event.pos().y()
        pointLocation = self.canvas.getCoordinateTransform().toMapCoordinates(x, y)
        TOMsMessageLog.logMessage("In CreatePointTool - location" + " X: " +str(pointLocation.x()) + " Y: " + str(pointLocation.y()), level=Qgis.Info)

        fields = self.currLayer.dataProvider().fields()
        feature = QgsFeature()
        feature.setFields(fields)

        feature.setGeometry(QgsGeometry.fromPointXY(pointLocation))

        self.setDefaultFieldRestrictionDetails(feature, self.currLayer, QDate.currentDate())

        self.currLayer.addFeature(feature)  # TH (added for v3)

        dialog = self.iface.getFeatureForm(self.currLayer, feature)

        self.setupFieldRestrictionDialog(dialog, self.currLayer, feature)  # connects signals, etc

        dialog.show()

    def deactivate(self):
        TOMsMessageLog.logMessage(("In CreatePointTool - deactivated."), level=Qgis.Info)
        #QgsMapTool.deactivate(self)
        self.deactivated.emit()

class getMTR_PointMapTool(QgsMapToolIdentify):

    pointFound = pyqtSignal(object, object, object  )  # TODO: return point and link/node reference

    def __init__(self, iface):
        QgsMapToolIdentify.__init__(self, iface.mapCanvas())

        self.iface = iface
        self.canvas = self.iface.mapCanvas()

        # set up list of layers to snap and check
        #layerDict = ...

    def canvasReleaseEvent(self, event):
        # Return point under cursor

        TOMsMessageLog.logMessage(("In Info - canvasReleaseEvent."), level=Qgis.Info)

        currPt = self.canvas.mouseLastXY()

        nearestLink, nearestNode = self.getNearestLinkNode(currPt)

        self.pointFound.emit(currPt, nearestLink, nearestNode)

    def getNearestLinkNode(self, pos):
        #  def findFeatureAt(self, pos, excludeFeature=None):
        # http://www.lutraconsulting.co.uk/blog/2014/10/17/getting-started-writing-qgis-python-plugins/ - generates "closest feature" function

        """ Find the feature close to the given position.

            'pos' is the position to check, in canvas coordinates.

            if 'excludeFeature' is specified, we ignore this feature when
            finding the clicked-on feature.

            If no feature is close to the given coordinate, we return None.
        """


        ### TODO:


        return nearestLink, nearestNode


