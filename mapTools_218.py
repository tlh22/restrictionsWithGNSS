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
#import time

from qgis.core import *
from qgis.gui import *

from PyQt4.QtCore import *
from PyQt4.QtGui import *

from core.proposalsManager import *
#from restrictionTypeUtils import RestrictionTypeUtils
from generateGeometryUtils import generateGeometryUtils
from TOMs.restrictionTypeUtilsClass import RestrictionTypeUtilsMixin
#from TOMs.CadNodeTool.TOMsNodeTool import originalFeature

from TOMs.constants import (
    ACTION_CLOSE_RESTRICTION,
    ACTION_OPEN_RESTRICTION
)

import functools

#from cmath import rect, phase
#import numpy as np
import uuid

#from constants import *

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

    def findNearestFeatureAtPL(self, pos):
        pass

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

        self.RestrictionLayers = QgsMapLayerRegistry.instance().mapLayersByName("RestrictionLayers")[0]

        #currLayer = self.TOMslayer  # need to loop through the layers and choose closest to click point
        #iface.setActiveLayer(currLayer)

        shortestDistance = float("inf")

        featureList = []
        layerList = []

        context = QgsExpressionContext()

        for layerDetails in self.RestrictionLayers.getFeatures():

            # Exclude consideration of CPZs
            if layerDetails.attribute("id") >= 6:  # CPZs
                continue

            self.currLayer = RestrictionTypeUtilsMixin.getRestrictionsLayer (layerDetails)

            context.appendScopes(QgsExpressionContextUtils.globalProjectLayerScopes(self.currLayer))

            # Loop through all features in the layer to find the closest feature
            for f in self.currLayer.getFeatures(request):
                # Add any features that are found should be added to a list
                featureList.append(f)
                layerList.append(self.currLayer)

                context.setFeature(f)
                expression1 = QgsExpression('generate_display_geometry ("GeometryID",  "GeomShapeID",  "AzimuthToRoadCentreLine",   @BayOffsetFromKerb, @BayWidth)')

                shapeGeom = expression1.evaluate(context)

                dist = f.geometry().distance(QgsGeometry.fromPoint(mapPt))
                if dist < shortestDistance:
                    shortestDistance = dist
                    closestFeature = f
                    closestLayer = self.currLayer

            extra_match = QgsPointLocator(QgsPointLocator.All, self.currLayer)
            extra_match.setExtent(searchRect)
            extra_match.setRenderContext()

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

class CreateFeatureWithGPSTool(QgsMapToolCapture, RestrictionTypeUtilsMixin):
    # helpful link - http://apprize.info/python/qgis/7.html ??
    def __init__(self, iface, layer):

        QgsMessageLog.logMessage(("In CreateFeatureWithGPSTool - init."), tag="TOMs panel")

        QgsMapToolCapture.__init__(self, iface.mapCanvas(), iface.cadDockWidget())
        #https: // qgis.org / api / classQgsMapToolCapture.html
        canvas = iface.mapCanvas()
        self.iface = iface
        self.layer = layer

        # Check that GPS is connected ... if not exit
        if self.getGPSConnection() is False:
            QMessageBox.information(self.iface.mainWindow(), "ERROR",
                                    ("GPS Connection is not present"))
            return False

        # set up transformation
        dest_crs = self.layer.sourceCrs()
        self.transform = QgsCoordinateTransform(QgsCoordinateReferenceSystem(4326), dest_crs, QgsProject.instance())

        #advancedDigitizingPanel = self.iface.AdvancedDigitizingTools()
        advancedDigitizingPanel = iface.mainWindow().findChild(QDockWidget, 'AdvancedDigitizingTools')
        if not advancedDigitizingPanel:
            QMessageBox.information(self.iface.mainWindow(), "ERROR",
                                    ("Advanced Digitising Panel is not present"))
        # TODO: Need to do something if this is not present

        advancedDigitizingPanel.setVisible(True)
        self.setupPanelTabs(self.iface, advancedDigitizingPanel)

        # I guess at this point, it is possible to set things like capture mode, snapping preferences, ... (not sure of all the elements that are required)
        # capture mode (... not sure if this has already been set? - or how to set it)

        QgsMessageLog.logMessage("In CreateFeatureWithGPSTool - geometryType for " + str(self.layer.name()) + ": " + str(self.layer.geometryType()), tag="TOMs panel")

        if self.layer.geometryType() == 0: # PointGeometry:
            self.setMode(CreateFeatureWithGPSTool.CapturePoint)
        elif self.layer.geometryType() == 1: # LineGeometry:
            self.setMode(CreateFeatureWithGPSTool.CaptureLine)
        elif self.layer.geometryType() == 2: # PolygonGeometry:
            self.setMode(CreateFeatureWithGPSTool.CapturePolygon)
        else:
            QgsMessageLog.logMessage(("In CreateFeatureWithGPSTool - No geometry type found. EXITING ...."), tag="TOMs panel")
            return

        QgsMessageLog.logMessage(("In CreateFeatureWithGPSTool - mode set."), tag="TOMs panel")

        # Seems that this is important - or at least to create a point list that is used later to create Geometry
        self.sketchPoints = self.points()

        # Set up rubber band. In current implementation, it is not showing feeback for "next" location

        self.rb = self.createRubberBand(QGis.Line)  # what about a polygon ??

        self.currLayer = self.currentVectorLayer()

        QgsMessageLog.logMessage(("In CreateFeatureWithGPSTool - init. Curr layer is " + str(self.currLayer.name()) + "Incoming: " + str(self.layer)), tag="TOMs panel")

        # set up snapping configuration   *******************
        self.snappingUtils = QgsSnappingUtils()
        self.snappingUtils.setSnapToMapMode(QgsSnappingUtils.SnapAdvanced)

        # set up tracing configuration
        self.CreateFeatureWithGPSToolTracer = QgsTracer()
        RoadCasementLayer = QgsMapLayerRegistry.instance().mapLayersByName("RoadCasement")[0]
        traceLayersNames = [RoadCasementLayer]
        self.CreateFeatureWithGPSToolTracer.setLayers(traceLayersNames)

        # set an extent for the Tracer
        tracerExtent = iface.mapCanvas().extent()
        tolerance = 1000.0
        tracerExtent.setXMaximum(tracerExtent.xMaximum() + tolerance)
        tracerExtent.setYMaximum(tracerExtent.yMaximum() + tolerance)
        tracerExtent.setXMinimum(tracerExtent.xMinimum() - tolerance)
        tracerExtent.setYMinimum(tracerExtent.yMinimum() - tolerance)

        self.CreateFeatureWithGPSToolTracer.setExtent(tracerExtent)

        self.lastPoint = None

    def cadCanvasReleaseEvent(self, event):
        QgsMapToolCapture.cadCanvasReleaseEvent(self, event)
        QgsMessageLog.logMessage(("In CreateFeatureWithGPSTool - cadCanvasReleaseEvent"), tag="TOMs panel")

        if event.button() == Qt.LeftButton:
            if not self.isCapturing():
                self.startCapturing()
            #self.result = self.addVertex(self.toMapCoordinates(event.pos()))
            checkSnapping = event.isSnapped
            QgsMessageLog.logMessage("In CreateFeatureWithGPSTool - cadCanvasReleaseEvent: checkSnapping = " + str(checkSnapping), tag="TOMs panel")

            # Now wanting to add point(s) to new shape. Take account of snapping and tracing
            # self.toLayerCoordinates(self.layer, event.pos())
            self.currPoint = event.snapPoint(1)    #  1 is value of QgsMapMouseEvent.SnappingMode (not sure where this is defined)
            self.lastEvent = event
            # If this is the first point, add and k

            nrPoints = self.size()
            res = None

            if not self.lastPoint:
                self.result = self.addVertex(self.currPoint)
                QgsMessageLog.logMessage("In CreateFeatureWithGPSTool - cadCanvasReleaseEvent: adding vertex 0 " + str(self.result), tag="TOMs panel")

            else:

                # check for shortest line
                resVectorList = self.TOMsTracer.findShortestPath(self.lastPoint, self.currPoint)

                QgsMessageLog.logMessage("In CreateFeatureWithGPSTool - cadCanvasReleaseEvent: traceList" + str(resVectorList), tag="TOMs panel")
                QgsMessageLog.logMessage("In CreateFeatureWithGPSTool - cadCanvasReleaseEvent: traceList" + str(resVectorList[1]), tag="TOMs panel")
                if resVectorList[1] == 0:
                    # path found, add the points to the list
                    QgsMessageLog.logMessage("In CreateFeatureWithGPSTool - cadCanvasReleaseEvent (found path) ", tag="TOMs panel")

                    #self.points.extend(resVectorList)
                    initialPoint = True
                    for point in resVectorList[0]:
                        if not initialPoint:

                            QgsMessageLog.logMessage(("In CreateFeatureWithGPSTool - cadCanvasReleaseEvent (found path) X:" + str(
                                point.x()) + " Y: " + str(point.y())), tag="TOMs panel")

                            self.result = self.addVertex(point)

                        initialPoint = False

                    QgsMessageLog.logMessage(("In CreateFeatureWithGPSTool - cadCanvasReleaseEvent (added shortest path)"),
                                             tag="TOMs panel")

                else:
                    # error encountered, add just the curr point ??

                    self.result = self.addVertex(self.currPoint)
                    QgsMessageLog.logMessage(("In CreateFeatureWithGPSTool - (adding shortest path) X:" + str(self.currPoint.x()) + " Y: " + str(self.currPoint.y())), tag="TOMs panel")

            self.lastPoint = self.currPoint

            QgsMessageLog.logMessage(("In CreateFeatureWithGPSTool - cadCanvasReleaseEvent (AddVertex/Line) Result: " + str(self.result) + " X:" + str(self.currPoint.x()) + " Y:" + str(self.currPoint.y())), tag="TOMs panel")

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
        QgsMessageLog.logMessage(("In CreateFeatureWithGPSTool - getPointsCaptured"), tag="TOMs panel")

        # Check the number of points
        self.nrPoints = self.size()
        QgsMessageLog.logMessage(("In CreateFeatureWithGPSTool - getPointsCaptured; Stopping: " + str(self.nrPoints)),
                                 tag="TOMs panel")

        self.sketchPoints = self.points()

        for point in self.sketchPoints:
            QgsMessageLog.logMessage(("In CreateFeatureWithGPSTool - getPointsCaptured X:" + str(point.x()) + " Y: " + str(point.y())), tag="TOMs panel")

        # stop capture activity
        self.stopCapturing()

        if self.nrPoints > 0:

            # take points from the rubber band and copy them into the "feature"

            fields = self.layer.dataProvider().fields()
            feature = QgsFeature()
            feature.setFields(fields)

            QgsMessageLog.logMessage(("In CreateFeatureWithGPSTool. getPointsCaptured, layerType: " + str(self.layer.geometryType())), tag="TOMs panel")

            if self.layer.geometryType() == 0:  # Point
                feature.setGeometry(QgsGeometry.fromPoint(self.sketchPoints[0]))
            elif self.layer.geometryType() == 1:  # Line
                feature.setGeometry(QgsGeometry.fromPolyline(self.sketchPoints))
            elif self.layer.geometryType() == 2:  # Polygon
                feature.setGeometry(QgsGeometry.fromPolygon([self.sketchPoints]))
                #feature.setGeometry(QgsGeometry.fromPolygon(self.sketchPoints))
            else:
                QgsMessageLog.logMessage(("In CreateFeatureWithGPSTool - no geometry type found"), tag="TOMs panel")
                return

            # Currently geometry is not being created correct. Might be worth checking co-ord values ...

            #self.valid = feature.isValid()

            QgsMessageLog.logMessage(("In CreateFeatureWithGPSTool - getPointsCaptured; geometry prepared; " + str(feature.geometry().exportToWkt())),
                                     tag="TOMs panel")

            if self.layer.name() == "ConstructionLines":
                self.layer.addFeature(feature)
                pass
            else:

                # set any geometry related attributes ...

                self.setDefaultRestrictionDetails(feature, self.layer)

                QgsMessageLog.logMessage("In In CreateFeatureWithGPSTool - getPointsCaptured. currRestrictionLayer: " + str(self.layer.name()),
                                         tag="TOMs panel")

                dialog = self.iface.getFeatureForm(self.layer, feature)

                self.setupRestrictionDialog(dialog, self.layer, feature)  # connects signals, etc

                dialog.show()

    def getGPSConnection(self):

        # https://gis.stackexchange.com/questions/306653/read-status-and-xy-coordinates-from-gps-widget-with-python-qgis-3?rq=1

        #self.connectionRegistry = QgsGpsConnectionRegistry().instance()
        self.connectionRegistry = QgsApplication.gpsConnectionRegistry()
        self.connectionList = self.connectionRegistry.connectionList()
        result = self.connectionList[0].connect()

        if self.connectionList[0].status() == QgsGPSConnection.Connected:
            return True

        return False

    def addPointFromGPS(self):
        QgsMessageLog.logMessage(
            "In CreateFeatureWithGPSTool - addPointFromGPS",
            tag="TOMs panel")
        # assume that GPS is connected and get current co-ords ...
        GPSInfo = connectionList[0].currentGPSInformation()
        lon = GPSInfo.longitude
        lat = GPSInfo.latitude

        # ** need to be able to convert from lat/long to Point
        gpsPt = self.transform(QgsPointXY(lon,lat))
        status = self.addVertex(gpsPt)

        # opportunity to add details about GPS point to another table

        return status

