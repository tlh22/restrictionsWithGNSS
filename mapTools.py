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
#from TOMs.core.TOMsMessageLog import TOMsMessageLog

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

        #QgsMessageLog.logMessage("In findNearestFeatureAt: shortestDistance: " + str(shortestDistance), tag="TOMs panel")
        QgsMessageLog.logMessage("In findNearestFeatureAt: nrFeatures: " + str(len(featureList)), tag="TOMs panel")

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

        QgsMessageLog.logMessage(("In CreateRestrictionTool - init."), tag="TOMs panel")
        if layer.geometryType() == 0: # PointGeometry:
            captureMode = (CreateRestrictionTool.CapturePoint)
        elif layer.geometryType() == 1: # LineGeometry:
            captureMode = (CreateRestrictionTool.CaptureLine)
        elif layer.geometryType() == 2: # PolygonGeometry:
            captureMode = (CreateRestrictionTool.CapturePolygon)
        else:
            QgsMessageLog.logMessage(("In CreateRestrictionTool - No geometry type found. EXITING ...."), tag="TOMs panel")
            return

        QgsMapToolCapture.__init__(self, iface.mapCanvas(), iface.cadDockWidget(), captureMode)
        FieldRestrictionTypeUtilsMixin.__init__(self, iface)

        # https: // qgis.org / api / classQgsMapToolCapture.html
        canvas = iface.mapCanvas()
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
            QgsMessageLog.logMessage(("In CreateRestrictionTool - No geometry type found. EXITING ...."), tag="TOMs panel")
            return"""

        #self.dialog = dialog
        # Check that GPS is connected ... if not exit
        """if self.getGPSConnection() is False:
            QMessageBox.information(self.iface.mainWindow(), "ERROR",
                                    ("GPS Connection is not present"))
            # TODO: Need to set a signal to stop operations with this tool
            return

        # set up transformation
        dest_crs = self.layer.sourceCrs()
        self.transformation = QgsCoordinateTransform(QgsCoordinateReferenceSystem(4326), dest_crs, QgsProject.instance())"""

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

        QgsMessageLog.logMessage("In CreateRestrictionTool - geometryType for " + str(self.layer.name()) + ": " + str(self.layer.geometryType()), tag="TOMs panel")

        QgsMessageLog.logMessage(("In CreateRestrictionTool - mode set."), tag="TOMs panel")

        # Seems that this is important - or at least to create a point list that is used later to create Geometry
        self.sketchPoints = self.points()
        #self.setPoints(self.sketchPoints)  ... not sure when to use this ??

        # Set up rubber band. In current implementation, it is not showing feeback for "next" location

        self.rb = self.createRubberBand(QgsWkbTypes.LineGeometry)  # what about a polygon ??

        #self.currLayer = self.currentVectorLayer()
        self.currLayer = self.layer

        QgsMessageLog.logMessage(("In CreateRestrictionTool - init. Curr layer is " + str(self.currLayer.name()) + "Incoming: " + str(self.layer)), tag="TOMs panel")

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

    def cadCanvasReleaseEvent(self, event):
        QgsMapToolCapture.cadCanvasReleaseEvent(self, event)
        QgsMessageLog.logMessage(("In Create - cadCanvasReleaseEvent"), tag="TOMs panel")

        if event.button() == Qt.LeftButton:
            if not self.isCapturing():
                self.startCapturing()
            #self.result = self.addVertex(self.toMapCoordinates(event.pos()))
            checkSnapping = event.isSnapped
            QgsMessageLog.logMessage("In Create - cadCanvasReleaseEvent: checkSnapping = " + str(checkSnapping), tag="TOMs panel")

            """tolerance_nearby = 0.5
            tolerance = tolerance_nearby

            searchRect = QgsRectangle(self.currPoint.x() - tolerance,
                                      self.currPoint.y() - tolerance,
                                      self.currPoint.x() + tolerance,
                                      self.currPoint.y() + tolerance)"""

            #locator = self.snappingUtils.snapToMap(self.currPoint)

            # Now wanting to add point(s) to new shape. Take account of snapping and tracing
            # self.toLayerCoordinates(self.layer, event.pos())
            self.currPoint = event.snapPoint()    #  1 is value of QgsMapMouseEvent.SnappingMode (not sure where this is defined)
            self.lastEvent = event
            # If this is the first point, add and k

            nrPoints = self.size()
            res = None

            if not self.lastPoint:

                self.result = self.addVertex(self.currPoint)
                QgsMessageLog.logMessage("In Create - cadCanvasReleaseEvent: adding vertex 0 " + str(self.result), tag="TOMs panel")

            else:

                # check for shortest line
                """resVectorList = self.TOMsTracer.findShortestPath(self.lastPoint, self.currPoint)

                QgsMessageLog.logMessage("In Create - cadCanvasReleaseEvent: traceList" + str(resVectorList), tag="TOMs panel")
                QgsMessageLog.logMessage("In Create - cadCanvasReleaseEvent: traceList" + str(resVectorList[1]), tag="TOMs panel")
                if resVectorList[1] == 0:
                    # path found, add the points to the list
                    QgsMessageLog.logMessage("In Create - cadCanvasReleaseEvent (found path) ", tag="TOMs panel")

                    #self.points.extend(resVectorList)
                    initialPoint = True
                    for point in resVectorList[0]:
                        if not initialPoint:

                            QgsMessageLog.logMessage(("In CreateRestrictionTool - cadCanvasReleaseEvent (found path) X:" + str(
                                point.x()) + " Y: " + str(point.y())), tag="TOMs panel")

                            self.result = self.addVertex(point)

                        initialPoint = False

                    QgsMessageLog.logMessage(("In Create - cadCanvasReleaseEvent (added shortest path)"),
                                             tag="TOMs panel")

                else:"""
                    # error encountered, add just the curr point ??

                self.result = self.addVertex(self.currPoint)
                QgsMessageLog.logMessage(("In CreateRestrictionTool - (adding shortest path) X:" + str(self.currPoint.x()) + " Y: " + str(self.currPoint.y())), tag="TOMs panel")

            self.lastPoint = self.currPoint

            QgsMessageLog.logMessage(("In Create - cadCanvasReleaseEvent (AddVertex/Line) Result: " + str(self.result) + " X:" + str(self.currPoint.x()) + " Y:" + str(self.currPoint.y())), tag="TOMs panel")

        elif (event.button() == Qt.RightButton):
            # Stop capture when right button or escape key is pressed
            #points = self.getCapturedPoints()
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
        QgsMessageLog.logMessage(("In CreateRestrictionTool - getPointsCaptured"), tag="TOMs panel")

        # Check the number of points
        self.nrPoints = self.size()
        QgsMessageLog.logMessage(("In CreateRestrictionTool - getPointsCaptured; Stopping: " + str(self.nrPoints)),
                                 tag="TOMs panel")

        self.sketchPoints = self.points()

        for point in self.sketchPoints:
            QgsMessageLog.logMessage(("In CreateRestrictionTool - getPointsCaptured X:" + str(point.x()) + " Y: " + str(point.y())), tag="TOMs panel")

        # stop capture activity
        self.stopCapturing()

        if self.nrPoints > 0:

            """if self.layer.startEditing() == False:
                reply = QMessageBox.information(None, "Information",
                                                "Could not start transaction on " + self.layer.name(),
                                                QMessageBox.Ok)"""

            # take points from the rubber band and copy them into the "feature"

            fields = self.layer.dataProvider().fields()
            feature = QgsFeature()
            feature.setFields(fields)

            QgsMessageLog.logMessage(("In CreateRestrictionTool. getPointsCaptured, layerType: " + str(self.layer.geometryType())), tag="TOMs panel")

            if self.layer.geometryType() == 0:  # Point
                feature.setGeometry(QgsGeometry.fromPointXY(self.sketchPoints[0]))
            elif self.layer.geometryType() == 1:  # Line
                feature.setGeometry(QgsGeometry.fromPolylineXY(self.sketchPoints))
            elif self.layer.geometryType() == 2:  # Polygon
                feature.setGeometry(QgsGeometry.fromPolygonXY([self.sketchPoints]))
                #feature.setGeometry(QgsGeometry.fromPolygonXY(self.sketchPoints))
            else:
                QgsMessageLog.logMessage(("In CreateRestrictionTool - no geometry type found"), tag="TOMs panel")
                return

            # Currently geometry is not being created correct. Might be worth checking co-ord values ...

            #self.valid = feature.isValid()

            QgsMessageLog.logMessage(("In Create - getPointsCaptured; geometry prepared; " + str(feature.geometry().asWkt())),
                                     tag="TOMs panel")

            if self.layer.name() == "ConstructionLines":
                self.layer.addFeature(feature)
                pass
            else:

                # set any geometry related attributes ...

                self.setDefaultFieldRestrictionDetails(feature, self.layer, QDate.currentDate())

                # is there any other tidying to do ??

                #self.layer.startEditing()
                #dialog = self.iface.getFeatureForm(self.layer, feature)

                #currForm = dialog.attributeForm()
                #currForm.disconnectButtonBox()

                QgsMessageLog.logMessage("In CreateRestrictionTool - getPointsCaptured. currRestrictionLayer: " + str(self.layer.name()),
                                         tag="TOMs panel")

                #button_box = currForm.findChild(QDialogButtonBox, "button_box")
                #button_box.accepted.disconnect(currForm.accept)

                # Disconnect the signal that QGIS has wired up for the dialog to the button box.
                # button_box.accepted.disconnect(restrictionsDialog.accept)
                # Wire up our own signals.
                #button_box.accepted.connect(functools.partial(RestrictionTypeUtils.onSaveRestrictionDetails, feature, self.layer, currForm))
                #button_box.rejected.connect(dialog.reject)

                # To allow saving of the original feature, this function follows changes to attributes within the table and records them to the current feature
                #currForm.attributeChanged.connect(functools.partial(self.onAttributeChanged, feature))
                # Can we now implement the logic from the form code ???

                newRestrictionID = str(uuid.uuid4())
                feature[self.layer.fields().indexFromName("GeometryID")] = newRestrictionID
                self.layer.addFeature(feature)  # TH (added for v3)

                dialog = self.iface.getFeatureForm(self.layer, feature)

                self.setupFieldRestrictionDialog(dialog, self.layer, feature)  # connects signals, etc

                self.inProcess = False
                dialog.show()
                #self.iface.openFeatureForm(self.layer, feature, False, False)

            pass

        #def onAttributeChanged(self, feature, fieldName, value):
        # QgsMessageLog.logMessage("In restrictionFormOpen:onAttributeChanged - layer: " + str(layer.name()) + " (" + str(feature.attribute("RestrictionID")) + "): " + fieldName + ": " + str(value), tag="TOMs panel")

        #feature.setAttribute(fieldName, value)

    """def prepareCurrentRestriction(self):

        fields = self.layer.dataProvider().fields()
        feature = QgsFeature()
        feature.setFields(fields)

        QgsMessageLog.logMessage(
            ("In CreateRestrictionTool. getPointsCaptured, layerType: " + str(self.layer.geometryType())),
            tag="TOMs panel")

        if self.layer.geometryType() == 0:  # Point
            feature.setGeometry(QgsGeometry.fromPointXY(self.sketchPoints[0]))
        elif self.layer.geometryType() == 1:  # Line
            feature.setGeometry(QgsGeometry.fromPolylineXY(self.sketchPoints))
        elif self.layer.geometryType() == 2:  # Polygon
            feature.setGeometry(QgsGeometry.fromPolygonXY([self.sketchPoints]))
            # feature.setGeometry(QgsGeometry.fromPolygonXY(self.sketchPoints))
        else:
            QgsMessageLog.logMessage(("In CreateRestrictionTool - no geometry type found"), tag="TOMs panel")
            return

        QgsMessageLog.logMessage(
            ("In Create - getPointsCaptured; geometry prepared; " + str(feature.geometry().asWkt())),
            tag="TOMs panel")

        if self.layer.name() == "ConstructionLines":
            self.layer.addFeature(feature)
            pass
        else:

            QgsMessageLog.logMessage(
                "In CreateRestrictionTool - getPointsCaptured. currRestrictionLayer: " + str(self.layer.name()),
                tag="TOMs panel")

            self.layer.addFeature(feature)  # TH (added for v3)"""


    def addPointFromGPS(self, curr_gps_location, curr_gps_info):
        QgsMessageLog.logMessage(
            "In CreateFeatureWithGPSTool - addPointFromGPS",
            tag="TOMs panel")

        status = self.addVertex(curr_gps_location)

        # TODO: opportunity to add details about GPS point to another table

        return status

        """def deactivated(self):
        QgsMessageLog.logMessage(("In CreateRestrictionTool - deactivated."), tag="TOMs panel")
        self.deActivatedInProcess.emit(self.inProcess)"""

        """def activated(self):
        QgsMessageLog.logMessage(("In CreateRestrictionTool - activated."), tag="TOMs panel")
        self.alreadyExists = True"""

    def deactivate(self):
        QgsMessageLog.logMessage(("In CreateRestrictionTool - deactivated."), tag="TOMs panel")
        QgsMapTool.deactivate(self)
        self.deactivated.emit()

class CreatePointTool(FieldRestrictionTypeUtilsMixin, QgsMapToolEmitPoint ):

    def __init__(self, iface, layer):

        QgsMessageLog.logMessage(("In CreatePointTool - init."), tag="TOMs panel")

        self.iface = iface
        self.canvas = iface.mapCanvas()
        self.currLayer = layer

        QgsMapToolEmitPoint.__init__(self, iface.mapCanvas())
        FieldRestrictionTypeUtilsMixin.__init__(self, iface)

    def canvasReleaseEvent(self, event):

        QgsMessageLog.logMessage(("In CreatePointTool - canvasReleaseEvent."), tag="TOMs panel")

        if self.currLayer.startEditing() == False:
            reply = QMessageBox.information(None, "Information",
                                            "Could not start transaction on " + self.currLayer.name(),
                                            QMessageBox.Ok)

        x = event.pos().x()
        y = event.pos().y()
        pointLocation = self.canvas.getCoordinateTransform().toMapCoordinates(x, y)
        QgsMessageLog.logMessage("In CreatePointTool - location" + " X: " +str(pointLocation.x()) + " Y: " + str(pointLocation.y()), tag="TOMs panel")

        fields = self.currLayer.dataProvider().fields()
        feature = QgsFeature()
        feature.setFields(fields)

        feature.setGeometry(QgsGeometry.fromPointXY(pointLocation))

        self.setDefaultFieldRestrictionDetails(feature, self.currLayer, QDate.currentDate())

        self.currLayer.addFeature(feature)  # TH (added for v3)

        dialog = self.iface.getFeatureForm(self.currLayer, feature)

        self.setupFieldRestrictionDialog(dialog, self.currLayer, feature)  # connects signals, etc

        dialog.show()

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

        QgsMessageLog.logMessage(("In Info - canvasReleaseEvent."), tag="TOMs panel")

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

