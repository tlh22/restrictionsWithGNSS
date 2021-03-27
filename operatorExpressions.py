#-----------------------------------------------------------
# Licensed under the terms of GNU GPL 2
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#---------------------------------------------------------------------
# Tim Hancock/Matthias Kuhn 2017
#
"""

https://github.com/NathanW2/qgsexpressionsplus/blob/master/functions.py

Extra functions for QgsExpression
register=False in order to delay registring of functions before we load the plugin

*** TH: Using this code to move Expression functions into main code body

"""

#from qgis.utils import qgsfunction

import qgis

#from qgis.core import *
from qgis.gui import *
from qgis.utils import *
from TOMs.core.TOMsMessageLog import TOMsMessageLog
from qgis.core import (
    Qgis,
    QgsMessageLog,
    QgsExpression, QgsGeometry, QgsPointXY,
    QgsFeature, QgsProject, QgsFeatureRequest,
    QgsSpatialIndex
)
import math
import random

from TOMs.core.TOMsGeometryElement import ElementGeometryFactory
from TOMs.expressions import TOMsExpressions

from TOMs.constants import (
    ProposalStatus,
    RestrictionAction,
    RestrictionLayers,
    RestrictionGeometryTypes
)

import sys, traceback


""" ****************************** """

class operatorExpressions(TOMsExpressions):

    def __init__(self):
        QgsMessageLog.logMessage("Starting operatorExpressions ... ", tag='TOMs Panel', level=Qgis.Warning)

        self.functions = [
            #self.generateDemandPoints,
            self.lookupJunctionDetails
        ]

    @qgsfunction(args='auto', group='TOMsDemand2', usesgeometry=False, register=True)
    def generateDemandPoints(feature, parent):
        # Returns the location of points representing demand

        TOMsMessageLog.logMessage('generateDemandPoints: {}'.format(feature.attribute("GeometryID")),
                                  level=Qgis.Info)

        demand = feature.attribute("Demand")
        if demand == 0:
            return None

        capacity = feature.attribute("Capacity")

        nrSpaces = capacity - demand
        if nrSpaces < 0:
            nrSpaces = 0

        TOMsMessageLog.logMessage('generateDemandPoints: capacity: {}; nrSpaces: {}; demand: {}'.format(capacity, nrSpaces, demand),
                                  level=Qgis.Info)

        # now get geometry for demand locations

        """
        #newFeature = QgsFeature(feature)
        currGeomShapeID = feature.attribute("GeomShapeID")
        if currGeomShapeID < 10:
            currGeomShapeID = currGeomShapeID + 20
        if currGeomShapeID >= 10 and currGeomShapeID < 20:
            currGeomShapeID = 21

        #newFeature.setAttribute("GeomShapeID", currGeomShapeID)"""

        try:
            #geomShowingSpaces = ElementGeometryFactory.getElementGeometry(newFeature)  # TODO: for some reason the details from newFeature are not "saved" and used
            #geomShowingSpaces = ElementGeometryFactory.getElementGeometry(feature, currGeomShapeID)
            geomShowingSpaces = ElementGeometryFactory.getElementGeometry(feature)
        except Exception as e:
            TOMsMessageLog.logMessage('generateDemandPoints: error in expression function: {}'.format(e),
                              level=Qgis.Warning)
            return None

        random.seed(1234)  # need to ramdomise, but it needs to be repeatable?!?, i.e., when you pan, they stay in the same place
        listBaysToDelete = []
        listBaysToDelete = random.sample(range(capacity), k=math.ceil(nrSpaces))

        # deal with split geometries - half on/half off
        if feature.attribute("GeomShapeID") == 22:
            for i in range(capacity, (capacity*2)):  # NB: range stops one before end ...
                listBaysToDelete.append(i)

        TOMsMessageLog.logMessage('generateDemandPoints: bays to delete {}'.format(listBaysToDelete),
                                  level=Qgis.Info)

        centroidGeomList = []
        counter = 0
        for polygonGeom in geomShowingSpaces.parts():
            TOMsMessageLog.logMessage('generateDemandPoints: considering part {}'.format(counter),
                                      level=Qgis.Info)
            if not counter in listBaysToDelete:
                centrePt = QgsPointXY(polygonGeom.centroid())
                TOMsMessageLog.logMessage(
                    'generateDemandPoints: adding centroid for {}: {}'.format(counter, centrePt.asWkt()),
                    level=Qgis.Info)
                try:
                    centroidGeomList.append(centrePt)
                except Exception as e:
                    TOMsMessageLog.logMessage('generateDemandPoints: error adding centroid for counter {}: {}'.format(counter, e),
                                              level=Qgis.Warning)
            counter = counter + 1

        TOMsMessageLog.logMessage('generateDemandPoints: nrDemandPoints {}'.format(len(centroidGeomList)),
                                  level=Qgis.Info)

        try:
            demandPoints = QgsGeometry.fromMultiPointXY(centroidGeomList)
        except Exception as e:
            TOMsMessageLog.logMessage('generateDemandPoints: error creating final geom: {}'.format(e),
                                      level=Qgis.Warning)

        return demandPoints

    @qgsfunction(args='auto', group='JunctionProtection', usesgeometry=False, register=True)
    def lookupJunctionDetails(field, joinChars, feature, parent):
        # function to lookup junction details give a map frame
        concat_fields = []
        mapFrameID = feature.attribute("GeometryID")
        TOMsMessageLog.logMessage('lookupJunctionDetails: mapFrameID {}'.format(mapFrameID),
                                  level=Qgis.Info)
        junctionsInMapFramesLayer = QgsProject.instance().mapLayersByName("JunctionsWithinMapFrames")[0]
        junctionsLayer = QgsProject.instance().mapLayersByName("HaveringJunctions")[0]
        # get junctions for map frame
        query1 = "\"MapFrameID\" = '{}'".format(mapFrameID)
        request1 = QgsFeatureRequest().setFilterExpression(query1)

        for row1 in junctionsInMapFramesLayer.getFeatures(request1):
            #TOMsMessageLog.logMessage("In getLookupLabelText: found row " + str(row.attribute("LabelText")), level=Qgis.Info)
            junctionID = row1.attribute("JunctionID") # make assumption that only one row
            TOMsMessageLog.logMessage('lookupJunctionDetails: considering junctionID {}'.format(junctionID),
                                      level=Qgis.Info)
            query2 = "\"GeometryID\" = '{}'".format(junctionID)
            request2 = QgsFeatureRequest().setFilterExpression(query2)
            for row2 in junctionsLayer.getFeatures(request2):
                concat_fields.append(row2.attribute(field))

        try:
            result = joinChars.join(concat_fields)
        except:
            result = ''

        TOMsMessageLog.logMessage('lookupJunctionDetails: concat_fields .{}.'.format(result),
                                  level=Qgis.Info)
        return result.strip()

    # https://gis.stackexchange.com/questions/152257/how-to-refer-to-another-layer-in-the-field-calculator  - see for inspiration
    @qgsfunction(args="auto", group='JunctionProtection', usesgeometry=True, register=True)
    def pointInPoly(layerName, refColumn, defaultValue, geom, feature, parent):
        # attempt to make a generic point in poly function ...
        
        TOMsMessageLog.logMessage("In pointInPoly", level=Qgis.Warning)

        # Get the reference layer
        try:
            refLayer = QgsProject.instance().mapLayersByName(layerName)[0]
        except Exception as e:
            refLayer = None

        if refLayer:

            TOMsMessageLog.logMessage("In pointInPoly. ref layer found ... ", level=Qgis.Warning)
            # TODO: ensure refLayer is polygon
            # TODO: deal with different geom types for the incoming geom. For the moment assume a point

            for poly in refLayer.getFeatures():
                if poly.geometry().contains(geom):
                    #TOMsMessageLog.logMessage("In getPolygonForRestriction. feature found", level=Qgis.Info)
                    return poly.attribute(refColumn)

        return defaultValue


    def registerFunctions(self):

        toms_list = QgsExpression.Functions()

        for func in self.functions:
            TOMsMessageLog.logMessage("Considering function {}".format(func.name()), level=Qgis.Info)
            try:
                if func in toms_list:
                    QgsExpression.unregisterFunction(func.name())
            except AttributeError:
                pass

            if QgsExpression.registerFunction(func):
                TOMsMessageLog.logMessage("Registered expression function {}".format(func.name()), level=Qgis.Info)

    def unregisterFunctions(self):
        # Unload all the functions that we created.
        for func in self.functions:
            QgsExpression.unregisterFunction(func.name())
            TOMsMessageLog.logMessage("Unregistered expression function {}".format(func.name()), level=Qgis.Info)

        #QgsExpression.cleanRegisteredFunctions()  # this seems to crash the reload ...
