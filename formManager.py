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
from .resources import *

from qgis.PyQt.QtCore import (
    QObject,
    QDate,
    pyqtSignal,
    QCoreApplication, pyqtSlot, QThread, QRect, Qt
)

from qgis.PyQt.QtGui import (
    QIcon,
    QPixmap, QColor, QFont, QDoubleValidator
)

from qgis.PyQt.QtWidgets import (
    QMessageBox,
    QAction,
    QDialogButtonBox,
    QLabel,
    QDockWidget,
    QWidget,
    QHBoxLayout, QComboBox, QGroupBox, QFormLayout, QStackedWidget, QPushButton, QLineEdit
)

from qgis.core import (
    QgsExpressionContextUtils,
    QgsProject,
    QgsMessageLog,
    QgsFeature,
    QgsGeometry, QgsGeometryUtils,
    QgsApplication, QgsCoordinateTransform, QgsCoordinateReferenceSystem,
    QgsGpsDetector, QgsGpsConnection, QgsGpsInformation, QgsPoint, QgsPointXY,
    QgsDataSourceUri, QgsRectangle, QgsFeatureRequest, QgsWkbTypes
)

from qgis.gui import (
    QgsVertexMarker,
    QgsMapToolEmitPoint, QgsRubberBand
)

from qgis.analysis import (
    QgsVectorLayerDirector, QgsNetworkDistanceStrategy, QgsGraphBuilder, QgsGraphAnalyzer
)

import os, time
import psycopg2
from abc import ABCMeta, abstractstaticmethod, abstractmethod

#from qgis.gui import *

# from .CadNodeTool.TOMsNodeTool import TOMsNodeTool
from .MTR_Restriction_dialog import MTR_RestrictionDialog
from .mapTools import CreateRestrictionTool, CreatePointTool
#from TOMsUtils import *

from .fieldRestrictionTypeUtilsClass import FieldRestrictionTypeUtilsMixin, TOMSLayers, gpsParams
from .SelectTool import GeometryInfoMapTool
from .MTR_Tools import getLinkDetailsMapTool

import functools


class mtrForm(MTR_RestrictionDialog):
    def __init__(self, iface, parent=None):
        if not parent:
            parent = iface.mainWindow()
        super().__init__(parent)

        self.iface = iface

        QgsMessageLog.logMessage("In generateMTRForm::init", tag="TOMs panel")

        #self.currDialog = MTR_RestrictionDialog(self.iface.mainWindow())
        self.linkLayer = QgsProject.instance().mapLayersByName("OS_RAMI_RoadLink")[0]
        self.dbConn = self.getDbConnection()
        if not self.dbConn:
            reply = QMessageBox.information(None, "Information",
                                            "Problem with db connection",
                                            QMessageBox.Ok)
            return

        self.currPointReferenceMapTool = None

        self.setupThisUi()
        # https://www.tutorialspoint.com/pyqt/pyqt_qstackedwidget.htm

        self.setupTrace()
        self.ptList = []

    def setupThisUi(self):

        # create stacked widgets that can be used based on the restriction type choosen
        self.accessRestrictionAttributeStack = QWidget()
        self.turnRestrictionAttributeStack = QWidget()
        self.highwayDedicationAttributeStack = QWidget()
        self.restrictionForVehiclesAttributeStack = QWidget()

        self.attributeLayout = self.findChild(QFormLayout, "attributesFormLayout")

        self.accessRestrictionGeometryStack = QWidget()
        self.turnRestrictionGeometryStack = QWidget()
        self.highwayDedicationGeometryStack = QWidget()
        self.restrictionForVehiclesGeometryStack = QWidget()

        self.geometryLayout = self.findChild(QFormLayout, "geometryFormLayout")

        self.generateAccessRestrictionForm()
        self.generateTurnRestrictionForm()
        self.generateHighwayDedicationForm()
        self.generateRestrictionForVehiclesForm()

        self.geometryStack = QStackedWidget(self)
        self.geometryStack.addWidget(self.accessRestrictionGeometryStack)
        self.geometryStack.addWidget(self.turnRestrictionGeometryStack)
        self.geometryStack.addWidget(self.highwayDedicationGeometryStack)
        self.geometryStack.addWidget(self.restrictionForVehiclesGeometryStack)
        self.geometryLayout.addWidget(self.geometryStack)

        self.attributeStack = QStackedWidget(self)
        self.attributeStack.addWidget(self.accessRestrictionAttributeStack)
        self.attributeStack.addWidget(self.turnRestrictionAttributeStack)
        self.attributeStack.addWidget(self.highwayDedicationAttributeStack)
        self.attributeStack.addWidget(self.restrictionForVehiclesAttributeStack)

        self.attributeLayout.addWidget(self.attributeStack)

        self.generateFirstStageForm()

        # Display for shortest path
        self.rbShortPath = QgsRubberBand(self.iface.mapCanvas())
        self.rbShortPath.setColor(Qt.green)
        self.rbShortPath.setWidth(5)

    def setupTrace(self):

        self.director = QgsVectorLayerDirector(self.linkLayer, -1, '', '', '', QgsVectorLayerDirector.DirectionBoth)
        strategy = QgsNetworkDistanceStrategy()
        self.director.addStrategy(strategy)
        self.builder = QgsGraphBuilder(self.linkLayer.crs())

    def generateFirstStageForm(self):

        QgsMessageLog.logMessage("In generateFirstStageForm::generateForm ... ", tag="TOMs panel")

        mtrTypeLayout = self.findChild(QFormLayout, "MTR_Type_Layout")
        self.mtrTypeCB = self.findChild(QComboBox, "cmb_MTR_list")

        enumList = self.getEnumList('MT_RestrictionType')

        #QgsMessageLog.logMessage("In generateFirstStageForm::generateForm ... signal connected 1", tag="TOMs panel")
        self.mtrTypeCB.addItems(enumList)
        #QgsMessageLog.logMessage("In generateFirstStageForm::generateForm ... signal connected 2", tag="TOMs panel")
        self.mtrTypeCB.currentIndexChanged.connect(self.onChanged)
        self.mtrTypeCB.setCurrentIndex(1)
        QgsMessageLog.logMessage("In generateFirstStageForm::generateForm ... signal connected 3", tag="TOMs panel")

    def onChanged(self, i):
        QgsMessageLog.logMessage("In generateFirstStageForm::selectionchange...", tag="TOMs panel")
        #QgsMessageLog.logMessage("In generateFirstStageForm::selectionchange.  Current index selection changed " + text, tag="TOMs panel")
        self.attributeStack.setCurrentIndex(i-1)  # to take account of the "null"
        self.geometryStack.setCurrentIndex(i-1)  # to take account of the "null"

    def getPointReference(self):
        QgsMessageLog.logMessage("In getPointReference ..." + self.mtrTypeCB.currentText(), tag="TOMs panel")

        self.mapTool = self.currPointReferenceMapTool

        if not self.mapTool:
            self.mapTool = getLinkDetailsMapTool(self.iface)
            self.currPointReferenceMapTool = self.mapTool

        self.iface.mapCanvas().setMapTool(self.mapTool)

        self.mapTool.notifyLinkFound.connect(self.foundLinkForPoint)

    def getLinkReference(self):
        QgsMessageLog.logMessage("In getLinkReference ..." + self.mtrTypeCB.currentText(), tag="TOMs panel")

        self.mapTool = self.currPointReferenceMapTool

        if not self.mapTool:
            self.mapTool = getLinkDetailsMapTool(self.iface)
            self.currPointReferenceMapTool = self.mapTool

        self.iface.mapCanvas().setMapTool(self.mapTool)

        self.mapTool.notifyLinkFound.connect(self.foundLinkForLine)

    def getLinkReferenceFirst(self):
        QgsMessageLog.logMessage("In getLinkReferenceFirst ... ", tag="TOMs panel")
        self.ptList = []
        self.rbShortPath.reset()
        self.getLinkReference()

    def foundLinkForPoint(self, nearestPt, feature, length):
        QgsMessageLog.logMessage("In foundLink ... length: " + str(length), tag="TOMs panel")
        self.mapTool.notifyLinkFound.disconnect(self.foundLinkForPoint)

        # check restriction type
        # if only point
            # process point
            # add details to relevant layers
            # make the geometry layout "not available" and highlight the attribute details
        # otherwise check whether or not a point is already found

    def foundLinkForLine(self, nearestPt, feature, length):
        QgsMessageLog.logMessage("In foundLink ... length: " + str(length), tag="TOMs panel")
        self.mapTool.notifyLinkFound.disconnect(self.foundLinkForLine)

        # add details to list
        self.ptList.append((nearestPt, feature, length))
        if len(self.ptList) >= 2:
            # we can now display the line - taken from Qgis Py Cookbook
            startPt = self.ptList[0][0].asPoint()
            endPt = self.ptList[1][0].asPoint()

            QgsMessageLog.logMessage("In foundLinkForLine::startPt " + startPt.asWkt(), tag="TOMs panel")
            QgsMessageLog.logMessage("In foundLinkForLine::endPt " + endPt.asWkt(), tag="TOMs panel")

            route = self.showShortestPath(startPt, endPt)

            # prepare list of links

            startFeature = self.ptList[0][1]
            endFeature = self.ptList[1][1]

            if startFeature != endFeature:
                # need to step through route and identify each new link

                self.linkList = [startFeature]
                currLink = startFeature
                QgsMessageLog.logMessage("In foundLinkForLine::currLink " + currLink.geometry().asWkt(),
                                         tag="TOMs panel")
                for currPt in route:
                    # if p is on currLink, move on. Otherwise add link to list
                    QgsMessageLog.logMessage("In foundLinkForLine::currPt " + currPt.asWkt(), tag="TOMs panel")

                    if not self.pointOnLine(currPt, currLink.geometry()):
                        # get link that contains p and prevPt
                        nextLink = self.findLinkContainingLine(prevPt, currPt)
                        if nextLink == endFeature:
                            break
                        else:
                            self.linkList.append(nextLink)
                            currLink = nextLink
                            QgsMessageLog.logMessage("In foundLinkForLine::currLink " + currLink.geometry().asWkt(), tag="TOMs panel")

                    prevPt = currPt

                self.linkList.append(endFeature)

    def pointOnLine(self, pt, lineGeom):

        ptGeom = QgsGeometry.fromPointXY(pt)
        dist = ptGeom.distance(lineGeom.nearestPoint(ptGeom))
        QgsMessageLog.logMessage("In pointOnLine. Dist " + str(dist), tag="TOMs panel")
        if dist > 0.001:
            return False

        return True

    def findLinkContainingLine(self, pt1, pt2):

        QgsMessageLog.logMessage("In findLinkContainingLine::pt1 " + pt1.asWkt() + " pt2: " + pt2.asWkt(), tag="TOMs panel")

        lineGeom = QgsGeometry.fromPolylineXY([pt1, pt2])

        request = QgsFeatureRequest().setFilterRect(QgsRectangle(pt1, pt2))
        for feature in self.linkLayer.getFeatures(request):

            intersectGeom = lineGeom.intersection(feature.geometry())
            QgsMessageLog.logMessage("In findLinkContainingLine:: intersectGeom " + intersectGeom.asWkt(),
                                     tag="TOMs panel")

            if intersectGeom.type() == QgsWkbTypes.LineGeometry:
                # this is our next feature
                return feature

        QgsMessageLog.logMessage("In findLinkContainingLine: ERROR. No link found containing line." , tag="TOMs panel")
        return None

    def showShortestPath(self, startPoint, endPoint):
        # taken from Qgis Py Cookbook
        #startPoint = self.ptList[0][0].asPoint()
        #endPoint = self.ptList[1][0].asPoint()

        tiedPoints = self.director.makeGraph(self.builder, [startPoint, endPoint])
        tStart, tStop = tiedPoints

        graph = self.builder.graph()
        idxStart = graph.findVertex(tStart)

        tree = QgsGraphAnalyzer.shortestTree(graph, idxStart, 0)

        idxStart = tree.findVertex(tStart)
        idxEnd = tree.findVertex(tStop)

        if idxEnd == -1:
            raise Exception('No route!')

        # Add last point
        route = [tree.vertex(idxEnd).point()]

        # Iterate the graph
        while idxEnd != idxStart:
            edgeIds = tree.vertex(idxEnd).incomingEdges()
            if len(edgeIds) == 0:
                break
            edge = tree.edge(edgeIds[0])
            route.insert(0, tree.vertex(edge.fromVertex()).point())
            idxEnd = edge.fromVertex()

        # This may require coordinate transformation if project's CRS
        # is different than layer's CRS
        for p in route:
            self.rbShortPath.addPoint(p)

        return route

    def generateAccessRestrictionForm(self):

        QgsMessageLog.logMessage("In generateAccessRestrictionForm::generateForm ... ", tag="TOMs panel")

        layout = QFormLayout()
        #groupBox = QGroupBox("Restriction Attributes", self.currDialog)
        #formLayout = QFormLayout()

        # Add access restriction type
        self.cb_accessRestrictionType = QComboBox(self)
        enumList = self.getEnumList('AccessRestrictionValue')
        self.cb_accessRestrictionType.addItems(enumList)
        layout.addRow(self.tr("&Access Restriction Type:"), self.cb_accessRestrictionType)

        # Add vehicle exemption
        self.cb_accessRestrictionVehicleExemptions = QComboBox(self)
        enumList = self.getTableList('"moving_traffic"."vehicleQualifiers"')
        self.cb_accessRestrictionVehicleExemptions.addItems(enumList)
        layout.addRow(self.tr("&Vehicle exemptions:"), self.cb_accessRestrictionVehicleExemptions)

        # Add vehicle inclusions
        self.cb_accessRestrictionVehicleInclusions = QComboBox(self)
        enumList = self.getTableList('"moving_traffic"."vehicleQualifiers"')
        self.cb_accessRestrictionVehicleInclusions.addItems(enumList)
        layout.addRow(self.tr("&Vehicle inclusions:"), self.cb_accessRestrictionVehicleInclusions)

        # add time intervals
        self.cb_accessRestrictionTimePeriods = QComboBox(self)
        enumList = self.getTableList('"moving_traffic"."TimePeriods"')
        self.cb_accessRestrictionTimePeriods.addItems(enumList)
        layout.addRow(self.tr("&Time Period:"), self.cb_accessRestrictionTimePeriods)

        # add traffic sign
        """self.cb_trafficSign = QComboBox(self)
        enumList = self.getTableList('Signs')
        self.cb_timePeriods.addItems(enumList)
        layout.addRow(self.tr("&Traffic Sign:"), self.cb_timePeriods)"""

        self.accessRestrictionAttributeStack.setLayout(layout)

        # set up network reference capture

        geomLayout = QFormLayout()
        self.btn_PointReference = QPushButton("Location")
        self.btn_PointReference.clicked.connect(self.getPointReference)
        geomLayout.addRow(self.tr("&Access Restriction Location:"), self.btn_PointReference)

        # add link direction
        self.cb_accessRestrictionLinkDirectionValue = QComboBox(self)
        enumList = self.getEnumList('LinkDirectionValue')
        self.cb_accessRestrictionLinkDirectionValue.addItems(enumList)
        geomLayout.addRow(self.tr("&Applicable link direction:"), self.cb_accessRestrictionLinkDirectionValue)

        self.accessRestrictionGeometryStack.setLayout(geomLayout)

        # create relevant features
        """
        self.accessRestrictionFeature = QgsFeature(self.accessRestrictionLayer)
        self.accessRestrictionNetworkReference = QgsFeature(self.pointReferenceLayer)
        # link them together with a uuid??

        # self.accessRestrictionFeature
        """
    def generateTurnRestrictionForm(self):

        QgsMessageLog.logMessage("In generateTurnRestrictionForm::generateForm ... ", tag="TOMs panel")

        layout = QFormLayout()

        # Add turn restriction type
        self.cb_turnRestrictionType = QComboBox(self)
        enumList = self.getEnumList('TurnRestrictionValue')
        self.cb_turnRestrictionType.addItems(enumList)
        layout.addRow(self.tr("&Turn Restriction Type:"), self.cb_turnRestrictionType)

        # Add vehicle exemption
        self.cb_turnRestrictionVehicleExemptions = QComboBox(self)
        enumList = self.getTableList('"moving_traffic"."vehicleQualifiers"')
        self.cb_turnRestrictionVehicleExemptions.addItems(enumList)
        layout.addRow(self.tr("&Vehicle exemptions:"), self.cb_turnRestrictionVehicleExemptions)

        # Add vehicle inclusions
        self.cb_turnRestrictionVehicleInclusions = QComboBox(self)
        enumList = self.getTableList('"moving_traffic"."vehicleQualifiers"')
        self.cb_turnRestrictionVehicleInclusions.addItems(enumList)
        layout.addRow(self.tr("&Vehicle inclusions:"), self.cb_turnRestrictionVehicleInclusions)

        # add time intervals
        self.cb_turnRestrictionTimePeriods = QComboBox(self)
        enumList = self.getTableList('"moving_traffic"."TimePeriods"')
        self.cb_turnRestrictionTimePeriods.addItems(enumList)
        layout.addRow(self.tr("&Time Period:"), self.cb_turnRestrictionTimePeriods)

        self.turnRestrictionAttributeStack.setLayout(layout)

        # set up network reference capture

        geomLayout = QFormLayout()
        self.btn_StartReference = QPushButton("Start")
        self.btn_EndReference = QPushButton("End")
        self.btn_StartReference.clicked.connect(self.getLinkReferenceFirst)
        self.btn_EndReference.clicked.connect(self.getLinkReference)
        geomLayout.addRow(self.tr("&Turn Restriction Start:"), self.btn_StartReference)
        geomLayout.addRow(self.tr("&Turn Restriction End:"), self.btn_EndReference)

        self.turnRestrictionGeometryStack.setLayout(geomLayout)

        # create relevant features
        """
        self.turnRestrictionFeature = QgsFeature(self.turnRestrictionLayer)
        self.turnRestrictionNetworkReference = QgsFeature(self.linkReferenceLayer)
        # link them together with a uuid??

        # self.accessRestrictionFeature
        """
    def generateHighwayDedicationForm(self):

        QgsMessageLog.logMessage("In generateHighwayDedicationForm::generateForm ... ", tag="TOMs panel")

        layout = QFormLayout()

        # Add turn restriction type
        self.cb_dedicationValue = QComboBox(self)
        enumList = self.getEnumList('DedicationValue')
        self.cb_dedicationValue.addItems(enumList)
        layout.addRow(self.tr("&Dedication:"), self.cb_dedicationValue)

        self.highwayDedicationAttributeStack.setLayout(layout)

        # set up network reference capture

        geomLayout = QFormLayout()
        self.btn_StartReference = QPushButton("Start")
        self.btn_EndReference = QPushButton("End")
        self.btn_StartReference.clicked.connect(self.getLinkReferenceFirst)
        self.btn_EndReference.clicked.connect(self.getLinkReference)
        geomLayout.addRow(self.tr("&Highway Dedication Start:"), self.btn_StartReference)
        geomLayout.addRow(self.tr("&Highway Dedication End:"), self.btn_EndReference)

        self.highwayDedicationGeometryStack.setLayout(geomLayout)

        # create relevant features
        """
        self.turnRestrictionFeature = QgsFeature(self.turnRestrictionLayer)
        self.turnRestrictionNetworkReference = QgsFeature(self.linkReferenceLayer)
        # link them together with a uuid??

        # self.accessRestrictionFeature
        """

    def generateRestrictionForVehiclesForm(self):

        QgsMessageLog.logMessage("In generateRestrictionForVehiclesForm::generateForm ... ", tag="TOMs panel")

        layout = QFormLayout()
        # Add restriction for vehicles type
        self.cb_restrictionForVehiclesType = QComboBox(self)
        enumList = self.getEnumList('RestrictionTypeValue')
        self.cb_restrictionForVehiclesType.addItems(enumList)
        layout.addRow(self.tr("&Access Restriction Type:"), self.cb_restrictionForVehiclesType)

        # add measure
        self.le_restrictionForVehiclesMeasure = QLineEdit()
        self.le_restrictionForVehiclesMeasure.setValidator(QDoubleValidator(0.99, 999.99, 2))
        layout.addRow(self.tr("&Measure (in metric units):"), self.le_restrictionForVehiclesMeasure)

        # add measure
        self.le_restrictionForVehiclesMeasure2 = QLineEdit()
        self.le_restrictionForVehiclesMeasure2.setValidator(QDoubleValidator(0.99, 999.99, 2))
        layout.addRow(self.tr("&Measure (in imperial units) [only if present]:"), self.le_restrictionForVehiclesMeasure2)

        # Add vehicle exemption
        self.cb_restrictionForVehiclesVehicleExemptions = QComboBox(self)
        enumList = self.getTableList('"moving_traffic"."vehicleQualifiers"')
        self.cb_restrictionForVehiclesVehicleExemptions.addItems(enumList)
        layout.addRow(self.tr("&Vehicle exemptions:"), self.cb_restrictionForVehiclesVehicleExemptions)

        # Add vehicle inclusions
        self.cb_restrictionForVehiclesVehicleInclusions = QComboBox(self)
        enumList = self.getTableList('"moving_traffic"."vehicleQualifiers"')
        self.cb_restrictionForVehiclesVehicleInclusions.addItems(enumList)
        layout.addRow(self.tr("&Vehicle inclusions:"), self.cb_restrictionForVehiclesVehicleInclusions)

        # add structure type
        self.cb_restrictionForVehiclesStructureType = QComboBox(self)
        enumList = self.getEnumList('StructureTypeValue')
        self.cb_restrictionForVehiclesStructureType.addItems(enumList)
        layout.addRow(self.tr("&Structure Type:"), self.cb_restrictionForVehiclesStructureType)

        # add traffic sign
        """self.cb_trafficSign = QComboBox(self)
        enumList = self.getTableList('Signs')
        self.cb_timePeriods.addItems(enumList)
        layout.addRow(self.tr("&Traffic Sign:"), self.cb_timePeriods)"""

        self.restrictionForVehiclesAttributeStack.setLayout(layout)

        geomLayout = QFormLayout()
        self.btn_PointReference = QPushButton("Location")
        self.btn_PointReference.clicked.connect(self.getPointReference)
        geomLayout.addRow(self.tr("&Restriction For Vehicle Location:"), self.btn_PointReference)

        # add link direction
        self.cb_restrictionForVehiclesLinkDirectionValue = QComboBox(self)
        enumList = self.getEnumList('LinkDirectionValue')
        self.cb_restrictionForVehiclesLinkDirectionValue.addItems(enumList)
        geomLayout.addRow(self.tr("&Applicable link direction:"), self.cb_restrictionForVehiclesLinkDirectionValue)

        self.restrictionForVehiclesGeometryStack.setLayout(geomLayout)

        # create relevant features
        """
        self.accessRestrictionFeature = QgsFeature(self.accessRestrictionLayer)
        self.accessRestrictionNetworkReference = QgsFeature(self.pointReferenceLayer)
        # link them together with a uuid??

        # self.accessRestrictionFeature
        """



    def getDbConnection(self):
        # http://pyqgis.org/blog/2013/04/11/creating-a-postgresql-connection-from-a-qgis-layer-datasource/
        # get the active layer
        dbConn = None
        #layer = self.iface.activeLayer()  # TODO: use a layer know to be using the database

        # get the underlying data provider
        provider = self.linkLayer.dataProvider()
        if provider.name() == 'postgres':
            # get the URI containing the connection parameters
            uri = QgsDataSourceUri(provider.dataSourceUri())
            QgsMessageLog.logMessage("In captureGPSFeatures::getDbConnection. db URI :" + uri.uri(), tag="TOMs panel")
            dbConn = psycopg2.connect(uri.connectionInfo())

        return dbConn

    def getEnumList(self, enum):
        typeList = ['',]

        query = 'SELECT unnest(enum_range(NULL::"{}"))::text'.format(enum)
        QgsMessageLog.logMessage("In generateMTRForm::getEnumList. query is " + query, tag="TOMs panel")

        cursor = self.dbConn.cursor()
        cursor.execute(query)
        result = cursor.fetchall()

        for value, in result:
            typeList.append(value)

        return typeList

    def getTableList(self, table):
        typeList = ['',]

        query = 'SELECT "Description" FROM {}'.format(table)
        QgsMessageLog.logMessage("In generateMTRForm::getTableList. query is " + query, tag="TOMs panel")

        cursor = self.dbConn.cursor()
        cursor.execute(query)
        result = cursor.fetchall()

        for value, in result:
            typeList.append(value)

        return typeList

