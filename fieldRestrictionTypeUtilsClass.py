#-----------------------------------------------------------
# Licensed under the terms of GNU GPL 2
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#---------------------------------------------------------------------
# Tim Hancock 2017

"""
Series of functions to deal with restrictionsInProposals. Defined as static functions to allow them to be used in forms ... (not sure if this is the best way ...)

"""
from qgis.PyQt.QtWidgets import (
    QMessageBox,
    QAction,
    QDialogButtonBox,
    QLabel,
    QDockWidget,
    QDialog,
    QLabel,
    QPushButton,
    QApplication
)

from qgis.PyQt.QtGui import (
    QIcon,
    QPixmap,
    QImage
)

from qgis.PyQt.QtCore import (
    QObject,
    QTimer,
    QThread,
    pyqtSignal,
    pyqtSlot
)

from qgis.PyQt.QtSql import (
    QSqlDatabase
)

from qgis.core import (
    QgsExpressionContextScope,
    QgsExpressionContextUtils,
    QgsExpression,
    QgsFeatureRequest,
    QgsMessageLog,
    QgsFeature,
    QgsGeometry,
    QgsTransaction,
    QgsTransactionGroup,
    QgsProject,
    QgsSettings
)

from qgis.gui import *
import functools
import time
import os
#import cv2


from abc import ABCMeta
from .generateGeometryUtils import generateGeometryUtils
from TOMs.restrictionTypeUtilsClass import TOMsParams

try:
    import cv2
except ImportError:
    None

import uuid

"""
class TOMsParams(QObject):


    def __init__(self):
        QObject.__init__(self)
        # self.iface = iface

        QgsMessageLog.logMessage("In TOMSParams.init ...", tag="TOMs panel")
        self.TOMsParamsList = ["BayWidth",
                          "BayLength",
                          "BayOffsetFromKerb",
                          "LineOffsetFromKerb",
                          "CrossoverShapeWidth",
                          "PhotoPath",
                          "MinimumTextDisplayScale"
                        ]

        self.TOMsParamsDict = {}

    def getParams(self):

        QgsMessageLog.logMessage("In TOMSLayers.getParams ...", tag="TOMs panel")
        found = True

        # Check for project being open
        currProject = QgsProject.instance()

        if len(currProject.fileName()) == 0:
            QMessageBox.information(self.iface.mainWindow(), "ERROR", ("Project not yet open"))
            found = False

        else:

            # QgsMessageLog.logMessage("In TOMSLayers.getParams ... starting to get", tag="TOMs panel")

            for param in self.TOMsParamsList:
                QgsMessageLog.logMessage("In TOMSLayers.getParams ... getting " + str(param), tag="TOMs panel")
                currParam = None
                try:
                    currParam = QgsExpressionContextUtils.projectScope(QgsProject.instance()).variable(param)
                except None:
                    QMessageBox.information(self.iface.mainWindow(), "ERROR", ("Property " + param + " is not present"))

                if len(str(currParam))>0:
                    self.TOMsParamsDict[param] = currParam
                    QgsMessageLog.logMessage("In TOMSLayers.getParams ... set " + str(param) + " as " + str(currParam), tag="TOMs panel")
                else:
                    QMessageBox.information(self.iface.mainWindow(), "ERROR", ("Property " + param + " is not present"))
                    found = False
                    break

        if found == False:
            self.TOMsParamsNotFound.emit()
        else:
            self.TOMsParamsSet.emit()

            # QgsMessageLog.logMessage("In TOMSLayers.getParams ... finished ", tag="TOMs panel")

        return found

    def setParam(self, param):
        return self.TOMsParamsDict.get(param)
"""
class TOMSLayers(QObject):

    TOMsLayersNotFound = pyqtSignal()
    """ signal will be emitted if there is a problem with opening TOMs - typically a layer missing """
    TOMsLayersSet = pyqtSignal()
    """ signal will be emitted if everything is OK with opening TOMs """

    def __init__(self, iface):
        QObject.__init__(self)
        self.iface = iface

        QgsMessageLog.logMessage("In TOMSLayers.init ...", tag="TOMs panel")
        #self.proposalsManager = proposalsManager

        # TODO: Load these from a local file - or database

        #RestrictionsLayers = QgsMapLayerRegistry.instance().mapLayersByName("RestrictionLayers")[0]
        self.TOMsLayerList = [
            "Bays",
            "Lines",
            "Signs",
            "RestrictionPolygons",
            # "ConstructionLines",
            # "CPZs",
            # "ParkingTariffAreas",
            # "StreetGazetteerRecords",
            "RoadCentreLine",
            "RoadCasement",
            # "RestrictionTypes",
            "BayLineTypes",
            # "BayTypes",
            # "LineTypes",
            # "RestrictionPolygonTypes",
            "LengthOfTime",
            "PaymentTypes",
            "RestrictionShapeTypes",
            "SignTypes",
            "TimePeriods",
            "UnacceptabilityTypes"
                         ]
        self.TOMsLayerDict = {}

    def getLayers(self):

        QgsMessageLog.logMessage("In TOMSLayers.getLayers ...", tag="TOMs panel")
        found = True

        # Check for project being open
        project = QgsProject.instance()

        if len(project.fileName()) == 0:
            QMessageBox.information(self.iface.mainWindow(), "ERROR", ("Project not yet open"))
            found = False

        else:

            for layer in self.TOMsLayerList:
                if QgsProject.instance().mapLayersByName(layer):
                    self.TOMsLayerDict[layer] = QgsProject.instance().mapLayersByName(layer)[0]
                else:
                    QMessageBox.information(self.iface.mainWindow(), "ERROR", ("Table " + layer + " is not present"))
                    found = False
                    break

        # TODO: need to deal with any errors arising ...

        if found == False:
            self.TOMsLayersNotFound.emit()
        else:
            self.TOMsLayersSet.emit()

        return

    def setLayer(self, layer):
        return self.TOMsLayerDict.get(layer)

class gpsParams(TOMsParams):

    gpsParamsNotFound = pyqtSignal()
    """ signal will be emitted if there is a problem with opening TOMs - typically a layer missing """
    gpsParamsSet = pyqtSignal()
    """ signal will be emitted if there is a problem with opening TOMs - typically a layer missing """

    def __init__(self, iface):
        TOMsParams.__init__(self)
        self.iface = iface

        QgsMessageLog.logMessage("In gpsParams.init ...", tag="TOMs panel")

        self.TOMsParamsList.extend([
                          "gpsPort"
                               ])
        #self.gpsParamsDict = {}

        """def getParams(self):

        found = True
        # QgsMessageLog.logMessage("In TOMSLayers.getParams ...", tag="TOMs panel")
        if TOMsParams.getParams(self):

            # Check for project being open
            currProject = QgsProject.instance()

            if len(currProject.fileName()) == 0:
                QMessageBox.information(self.iface.mainWindow(), "ERROR", ("Project not yet open"))
                found = False

            else:

                for param in self.gpsParamsList:

                    try:
                        currParam = QgsExpressionContextUtils.projectScope(QgsProject.instance()).variable(param)
                    except None:
                        QMessageBox.information(self.iface.mainWindow(), "ERROR",
                                                ("Property " + param + " is not present"))

                    if len(str(currParam)) > 0:
                        self.TOMsParamsDict[param] = currParam
                        QgsMessageLog.logMessage("In gpsLayers.getParams ... set " + str(param) + " as " + str(currParam),
                            tag="TOMs panel")
                    else:
                        QMessageBox.information(self.iface.mainWindow(), "ERROR", ("Property " + param + " is not present"))
                        found = False
                        break

            if found == False:
                self.gpsParamsNotFound.emit()
            else:
                self.gpsParamsSet.emit()

        return

        def setGpsParam(self, param):
        return self.gpsParamsDict.get(param)
        """

class originalFeature(object):
    def __init__(self, feature=None):
        self.savedFeature = None

    def setFeature(self, feature):
        self.savedFeature = QgsFeature(feature)
        #self.printFeature()

    def getFeature(self):
        #self.printFeature()
        return self.savedFeature

    def getGeometryID(self):
        return self.savedFeature.attribute("GeometryID")

    def printFeature(self):
        QgsMessageLog.logMessage("In TOMsNodeTool:originalFeature - attributes (fid:" + str(self.savedFeature.id()) + "): " + str(self.savedFeature.attributes()),
                                 tag="TOMs panel")
        QgsMessageLog.logMessage("In TOMsNodeTool:originalFeature - attributes: " + str(self.savedFeature.geometry().asWkt()),
                                 tag="TOMs panel")

class FieldRestrictionTypeUtilsMixin():
    def __init__(self, iface):

        self.iface = iface
        self.settings = QgsSettings()

    def setDefaultFieldRestrictionDetails(self, currRestriction, currRestrictionLayer, currDate):
        QgsMessageLog.logMessage("In setDefaultFieldRestrictionDetails: ", tag="TOMs panel")

        # TODO: Need to check whether or not these fields exist. Also need to retain the last values and reuse
        # gis.stackexchange.com/questions/138563/replacing-action-triggered-script-by-one-supplied-through-qgis-plugin

        try:
            currRestriction.setAttribute("CreateDateTime", currDate)
        except Exception:
            None

        generateGeometryUtils.setRoadName(currRestriction)
        if currRestrictionLayer.geometryType() == 1:  # Line or Bay
            generateGeometryUtils.setAzimuthToRoadCentreLine(currRestriction)
            currRestriction.setAttribute("Restriction_Length", currRestriction.geometry().length())


        #currentCPZ, cpzWaitingTimeID = generateGeometryUtils.getCurrentCPZDetails(currRestriction)

        #currRestriction.setAttribute("CPZ", currentCPZ)

        #currDate = self.proposalsManager.date()

        if currRestrictionLayer.name() == "Lines":
            currRestriction.setAttribute("RestrictionTypeID", self.readLastUsedDetails("Lines", "RestrictionTypeID", 201))  # 10 = SYL (Lines)
            currRestriction.setAttribute("GeomShapeID", self.readLastUsedDetails("Lines", "GeomShapeID", 10))   # 10 = Parallel Line
            currRestriction.setAttribute("NoWaitingTimeID", self.readLastUsedDetails("Lines", "NoWaitingTimeID", None))
            currRestriction.setAttribute("NoLoadingTimeID", self.readLastUsedDetails("Lines", "NoLoadingTimeID", None))
            #currRestriction.setAttribute("NoWTimeID", cpzWaitingTimeID)
            #currRestriction.setAttribute("CreateDateTime", currDate)
            currRestriction.setAttribute("Unacceptability", self.readLastUsedDetails("Lines", "Unacceptability", None))

        elif currRestrictionLayer.name() == "Bays":
            currRestriction.setAttribute("RestrictionTypeID", self.readLastUsedDetails("Bays", "RestrictionTypeID", 101))  # 28 = Permit Holders Bays (Bays)
            currRestriction.setAttribute("GeomShapeID", self.readLastUsedDetails("Bays", "GeomShapeID", 1)) # 21 = Parallel Bay (Polygon)
            currRestriction.setAttribute("NrBays", -1)
            currRestriction.setAttribute("TimePeriodID", self.readLastUsedDetails("Bays", "TimePeriodID", None))

            #currRestriction.setAttribute("MaxStayID", ptaMaxStayID)
            #currRestriction.setAttribute("NoReturnID", ptaNoReturnTimeID)
            #currRestriction.setAttribute("ParkingTariffArea", currentPTA)
            #currRestriction.setAttribute("CreateDateTime", currDate)

        elif currRestrictionLayer.name() == "Signs":
            currRestriction.setAttribute("SignType_1", self.readLastUsedDetails("Signs", "SignType_1", 28))  # 28 = Permit Holders Only (Signs)

        elif currRestrictionLayer.name() == "RestrictionPolygons":
            currRestriction.setAttribute("RestrictionTypeID", self.readLastUsedDetails("RestrictionPolygons", "RestrictionTypeID", 4))  # 28 = Residential mews area (RestrictionPolygons)

        pass

    def storeLastUsedDetails(self, layer, field, value):
        entry = '{layer}/{field}'.format(layer=layer, field=field)
        QgsMessageLog.logMessage("In storeLastUsedDetails: " + str(entry) + " (" + str(value) + ")", tag="TOMs panel")
        self.settings.setValue(entry, value)

    def readLastUsedDetails(self, layer, field, default):
        entry = '{layer}/{field}'.format(layer=layer, field=field)
        QgsMessageLog.logMessage("In readLastUsedDetails: " + str(entry) + " (" + str(default) + ")", tag="TOMs panel")
        return self.settings.value(entry, default)

    def setupFieldRestrictionDialog(self, restrictionDialog, currRestrictionLayer, currRestriction):

        #self.restrictionDialog = restrictionDialog
        #self.currRestrictionLayer = currRestrictionLayer
        #self.currRestriction = currRestriction
        #self.restrictionTransaction = restrictionTransaction

        # Create a copy of the feature
        self.origFeature = originalFeature()
        self.origFeature.setFeature(currRestriction)

        if restrictionDialog is None:
            QgsMessageLog.logMessage(
                "In setupRestrictionDialog. dialog not found",
                tag="TOMs panel")

        restrictionDialog.attributeForm().disconnectButtonBox()
        button_box = restrictionDialog.findChild(QDialogButtonBox, "button_box")

        if button_box is None:
            QgsMessageLog.logMessage(
                "In setupRestrictionDialog. button box not found",
                tag="TOMs panel")

        button_box.accepted.connect(functools.partial(self.onSaveFieldRestrictionDetails, currRestriction,
                                      currRestrictionLayer, restrictionDialog))

        button_box.rejected.connect(functools.partial(self.onRejectFieldRestrictionDetailsFromForm, restrictionDialog, currRestrictionLayer))

        restrictionDialog.attributeForm().attributeChanged.connect(functools.partial(self.onAttributeChangedClass2, currRestriction, currRestrictionLayer))

        self.photoDetails(restrictionDialog, currRestrictionLayer, currRestriction)

        """def onSaveRestrictionDetailsFromForm(self):
        QgsMessageLog.logMessage("In onSaveRestrictionDetailsFromForm", tag="TOMs panel")
        self.onSaveRestrictionDetails(self.currRestriction,
                                      self.currRestrictionLayer, self.restrictionDialog, self.restrictionTransaction)"""

    def onAttributeChangedClass2(self, currFeature, layer, fieldName, value):
        QgsMessageLog.logMessage(
            "In FormOpen:onAttributeChangedClass 2 - layer: " + str(layer.name()) + " (" + fieldName + "): " + str(value), tag="TOMs panel")

        # self.currRestriction.setAttribute(fieldName, value)
        try:

            currFeature[layer.fields().indexFromName(fieldName)] = value
            #currFeature.setAttribute(layer.fields().indexFromName(fieldName), value)

        except:

            reply = QMessageBox.information(None, "Error",
                                                "onAttributeChangedClass2. Update failed for: " + str(layer.name()) + " (" + fieldName + "): " + str(value),
                                                QMessageBox.Ok)  # rollback all changes

        self.storeLastUsedDetails(layer.name(), fieldName, value)

        return

        """def onSaveFieldRestrictionDetails(self, currRestriction, currRestrictionLayer, dialog):
        QgsMessageLog.logMessage("In onSaveFieldRestrictionDetails: " + str(currRestriction.attribute("GeometryID")), tag="TOMs panel")

        status = dialog.attributeForm().save()
        currRestrictionLayer.addFeature(currRestriction)  # TH (added for v3)
        #currRestrictionLayer.updateFeature(currRestriction)  # TH (added for v3)"""

    def onSaveFieldRestrictionDetails(self, currFeature, currFeatureLayer, dialog):
        QgsMessageLog.logMessage("In onSaveFieldRestrictionDetails: ", tag="TOMs panel")

        try:
            self.camera1.endCamera()
            self.camera2.endCamera()
            self.camera3.endCamera()
        except:
            None

        attrs1 = currFeature.attributes()
        QgsMessageLog.logMessage("In onSaveDemandDetails: currRestriction: " + str(attrs1),
                                 tag="TOMs panel")

        QgsMessageLog.logMessage(
            ("In onSaveDemandDetails. geometry: " + str(currFeature.geometry().asWkt())),
            tag="TOMs panel")

        currFeatureID = currFeature.id()
        QgsMessageLog.logMessage("In onSaveDemandDetails: currFeatureID: " + str(currFeatureID),
                                 tag="TOMs panel")

        status = currFeatureLayer.updateFeature(currFeature)
        """if currFeatureID > 0:   # Not sure what this value should if the feature has not been created ...

            # TODO: Sort out this for UPDATE
            self.setDefaultRestrictionDetails(currFeature, currFeatureLayer)

            status = currFeatureLayer.updateFeature(currFeature)
            QgsMessageLog.logMessage("In onSaveDemandDetails: updated Feature: ", tag="TOMs panel")
        else:
            status = currFeatureLayer.addFeature(currFeature)
            QgsMessageLog.logMessage("In onSaveDemandDetails: added Feature: " + str(status), tag="TOMs panel")"""

        QgsMessageLog.logMessage("In onSaveDemandDetails: Before commit", tag="TOMs panel")

        """reply = QMessageBox.information(None, "Information",
                                        "Wait a moment ...",
                                        QMessageBox.Ok)"""
        attrs1 = currFeature.attributes()
        QgsMessageLog.logMessage("In onSaveDemandDetails: currRestriction: " + str(attrs1),
                                 tag="TOMs panel")

        QgsMessageLog.logMessage(
            ("In onSaveDemandDetails. geometry: " + str(currFeature.geometry().asWkt())),
            tag="TOMs panel")

        """QgsMessageLog.logMessage("In onSaveDemandDetails: currActiveLayer: " + str(self.iface.activeLayer().name()),
                                 tag="TOMs panel")"""
        QgsMessageLog.logMessage("In onSaveDemandDetails: currActiveLayer: " + str(currFeatureLayer.name()),
                                 tag="TOMs panel")
        currFeatureLayer
        #Test
        #status = dialog.attributeForm().save()
        #status = dialog.accept()
        #status = dialog.accept()

        """reply = QMessageBox.information(None, "Information",
                                        "And another ... iseditable: " + str(currFeatureLayer.isEditable()),
                                        QMessageBox.Ok)"""

        #currFeatureLayer.blockSignals(True)

        """if currFeatureID == 0:
            self.iface.mapCanvas().unsetMapTool(self.iface.mapCanvas().mapTool())
            QgsMessageLog.logMessage("In onSaveDemandDetails: mapTool unset",
                                     tag="TOMs panel")"""

        """try:
            currFeatureLayer.commitChanges()
        except:
            reply = QMessageBox.information(None, "Information", "Problem committing changes" + str(currFeatureLayer.commitErrors()), QMessageBox.Ok)

        #currFeatureLayer.blockSignals(False)

        QgsMessageLog.logMessage("In onSaveDemandDetails: changes committed", tag="TOMs panel")

        status = dialog.close()"""

        status = dialog.attributeForm().save()
        #currRestrictionLayer.addFeature(currRestriction)  # TH (added for v3)
        currFeatureLayer.updateFeature(currFeature)  # TH (added for v3)

        try:
            currFeatureLayer.commitChanges()
        except:
            reply = QMessageBox.information(None, "Information", "Problem committing changes" + str(currFeatureLayer.commitErrors()), QMessageBox.Ok)

        #currFeatureLayer.blockSignals(False)

        QgsMessageLog.logMessage("In onSaveDemandDetails: changes committed", tag="TOMs panel")

        status = dialog.close()
        #self.mapTool = None
        self.iface.mapCanvas().unsetMapTool(self.iface.mapCanvas().mapTool())

    def onRejectFieldRestrictionDetailsFromForm(self, restrictionDialog, currFeatureLayer):
        QgsMessageLog.logMessage("In onRejectFieldRestrictionDetailsFromForm", tag="TOMs panel")

        try:
            self.camera1.endCamera()
            self.camera2.endCamera()
            self.camera3.endCamera()
        except:
            None

        currFeatureLayer.rollBack()
        restrictionDialog.reject()

        #del self.mapTool

        """def onRejectFieldRestrictionDetailsFromForm(self, restrictionDialog):
        QgsMessageLog.logMessage("In onRejectFieldRestrictionDetailsFromForm", tag="TOMs panel")

        restrictionDialog.reject()"""

    def photoDetails(self, restrictionDialog, currRestrictionLayer, currRestriction):

        # Function to deal with photo fields

        self.demandDialog = restrictionDialog
        self.currDemandLayer = currRestrictionLayer
        self.currFeature = currRestriction

        QgsMessageLog.logMessage("In photoDetails", tag="TOMs panel")

        FIELD1 = self.demandDialog.findChild(QLabel, "Photo_Widget_01")
        FIELD2 = self.demandDialog.findChild(QLabel, "Photo_Widget_02")
        FIELD3 = self.demandDialog.findChild(QLabel, "Photo_Widget_03")

        photoPath = QgsExpressionContextUtils.projectScope(QgsProject.instance()).variable('PhotoPath')
        projectFolder = QgsExpressionContextUtils.projectScope(QgsProject.instance()).variable('project_folder')

        """ v2.18
        photoPath = QgsExpressionContextUtils.projectScope().variable('PhotoPath')
        projectFolder = QgsExpressionContextUtils.projectScope().variable('project_folder')
        """
        path_absolute = os.path.join(projectFolder, photoPath)

        if path_absolute == None:
            reply = QMessageBox.information(None, "Information", "Please set value for PhotoPath.", QMessageBox.Ok)
            return

        # Check path exists ...
        if os.path.isdir(path_absolute) == False:
            reply = QMessageBox.information(None, "Information", "PhotoPath folder " + str(
                path_absolute) + " does not exist. Please check value.", QMessageBox.Ok)
            return

        layerName = self.currDemandLayer.name()

        # Generate the full path to the file

        # fileName1 = "Photos"
        fileName1 = "Photos_01"
        fileName2 = "Photos_02"
        fileName3 = "Photos_03"

        idx1 = self.currDemandLayer.fields().indexFromName(fileName1)
        idx2 = self.currDemandLayer.fields().indexFromName(fileName2)
        idx3 = self.currDemandLayer.fields().indexFromName(fileName3)

        """  v2.18
        idx1 = self.currDemandLayer.fieldNameIndex(fileName1)
        idx2 = self.currDemandLayer.fieldNameIndex(fileName2)
        idx3 = self.currDemandLayer.fieldNameIndex(fileName3)
        """

        QgsMessageLog.logMessage("In photoDetails. idx1: " + str(idx1) + "; " + str(idx2) + "; " + str(idx3),
                                 tag="TOMs panel")
        # if currFeatureFeature[idx1]:
        # QgsMessageLog.logMessage("In photoDetails. photo1: " + str(currFeatureFeature[idx1]), tag="TOMs panel")
        # QgsMessageLog.logMessage("In photoDetails. photo2: " + str(currFeatureFeature.attribute(idx2)), tag="TOMs panel")
        # QgsMessageLog.logMessage("In photoDetails. photo3: " + str(currFeatureFeature.attribute(idx3)), tag="TOMs panel")

        if FIELD1:
            QgsMessageLog.logMessage("In photoDetails. FIELD 1 exisits",
                                     tag="TOMs panel")
            if self.currFeature[idx1]:
                newPhotoFileName1 = os.path.join(path_absolute, self.currFeature[idx1])
            else:
                newPhotoFileName1 = None

            # QgsMessageLog.logMessage("In photoDetails. Photo1: " + str(newPhotoFileName1), tag="TOMs panel")
            pixmap1 = QPixmap(newPhotoFileName1)
            if pixmap1.isNull():
                pass
                # FIELD1.setText('Picture could not be opened ({path})'.format(path=newPhotoFileName1))
            else:
                FIELD1.setPixmap(pixmap1)
                FIELD1.setScaledContents(True)
                QgsMessageLog.logMessage("In photoDetails. Photo1: " + str(newPhotoFileName1), tag="TOMs panel")

            START_CAMERA_1 = self.demandDialog.findChild(QPushButton, "startCamera1")
            TAKE_PHOTO_1 = self.demandDialog.findChild(QPushButton, "getPhoto1")
            TAKE_PHOTO_1.setEnabled(False)

            self.camera1 = formCamera(path_absolute, newPhotoFileName1)
            START_CAMERA_1.clicked.connect(
                functools.partial(self.camera1.useCamera, START_CAMERA_1, TAKE_PHOTO_1, FIELD1))
            self.camera1.notifyPhotoTaken.connect(functools.partial(self.savePhotoTaken, idx1))

        if FIELD2:
            QgsMessageLog.logMessage("In photoDetails. FIELD 2 exisits",
                                     tag="TOMs panel")
            if self.currFeature[idx2]:
                newPhotoFileName2 = os.path.join(path_absolute, self.currFeature[idx2])
            else:
                newPhotoFileName2 = None

            # newPhotoFileName2 = os.path.join(path_absolute, str(self.currFeature[idx2]))
            # newPhotoFileName2 = os.path.join(path_absolute, str(self.currFeature.attribute(fileName2)))
            # QgsMessageLog.logMessage("In photoDetails. Photo2: " + str(newPhotoFileName2), tag="TOMs panel")
            pixmap2 = QPixmap(newPhotoFileName2)
            if pixmap2.isNull():
                pass
                # FIELD1.setText('Picture could not be opened ({path})'.format(path=newPhotoFileName1))
            else:
                FIELD2.setPixmap(pixmap2)
                FIELD2.setScaledContents(True)
                QgsMessageLog.logMessage("In photoDetails. Photo2: " + str(newPhotoFileName2), tag="TOMs panel")

            START_CAMERA_2 = self.demandDialog.findChild(QPushButton, "startCamera2")
            TAKE_PHOTO_2 = self.demandDialog.findChild(QPushButton, "getPhoto2")
            TAKE_PHOTO_2.setEnabled(False)

            self.camera2 = formCamera(path_absolute, newPhotoFileName2)
            START_CAMERA_2.clicked.connect(
                functools.partial(self.camera2.useCamera, START_CAMERA_2, TAKE_PHOTO_2, FIELD2))
            self.camera2.notifyPhotoTaken.connect(functools.partial(self.savePhotoTaken, idx2))

        if FIELD3:
            QgsMessageLog.logMessage("In photoDetails. FIELD 3 exisits",
                                     tag="TOMs panel")

            if self.currFeature[idx3]:
                newPhotoFileName3 = os.path.join(path_absolute, self.currFeature[idx3])
            else:
                newPhotoFileName3 = None

            # newPhotoFileName3 = os.path.join(path_absolute, str(self.currFeature[idx3]))
            # newPhotoFileName3 = os.path.join(path_absolute,
            #                                 str(self.currFeature.attribute(fileName3)))
            # newPhotoFileName3 = os.path.join(path_absolute, str(layerName + "_Photos_03"))

            # QgsMessageLog.logMessage("In photoDetails. Photo3: " + str(newPhotoFileName3), tag="TOMs panel")
            pixmap3 = QPixmap(newPhotoFileName3)
            if pixmap3.isNull():
                pass
                # FIELD1.setText('Picture could not be opened ({path})'.format(path=newPhotoFileName1))
            else:
                FIELD3.setPixmap(pixmap3)
                FIELD3.setScaledContents(True)
                QgsMessageLog.logMessage("In photoDetails. Photo3: " + str(newPhotoFileName3), tag="TOMs panel")

            START_CAMERA_3 = self.demandDialog.findChild(QPushButton, "startCamera3")
            TAKE_PHOTO_3 = self.demandDialog.findChild(QPushButton, "getPhoto3")
            TAKE_PHOTO_3.setEnabled(False)

            self.camera3 = formCamera(path_absolute, newPhotoFileName3)
            START_CAMERA_3.clicked.connect(
                functools.partial(self.camera3.useCamera, START_CAMERA_3, TAKE_PHOTO_3, FIELD3))
            self.camera3.notifyPhotoTaken.connect(functools.partial(self.savePhotoTaken, idx3))

        pass

    def getLookupDescription(self, lookupLayer, code):

        #QgsMessageLog.logMessage("In getLookupDescription", tag="TOMs panel")

        query = "\"Code\" = " + str(code)
        request = QgsFeatureRequest().setFilterExpression(query)

        #QgsMessageLog.logMessage("In getLookupDescription. queryStatus: " + str(query), tag="TOMs panel")

        for row in lookupLayer.getFeatures(request):
            #QgsMessageLog.logMessage("In getLookupDescription: found row " + str(row.attribute("Description")), tag="TOMs panel")
            return row.attribute("Description") # make assumption that only one row

        return None

    @pyqtSlot(str)
    def savePhotoTaken(self, idx, fileName):
        QgsMessageLog.logMessage("In demandFormUtils::savePhotoTaken ... " + fileName + " idx: " + str(idx),
                                 tag="TOMs panel")
        if len(fileName) > 0:
            simpleFile = ntpath.basename(fileName)
            QgsMessageLog.logMessage("In demandFormUtils::savePhotoTaken. Simple file: " + simpleFile, tag="TOMs panel")

            try:
                self.currFeature[idx] = simpleFile
                QgsMessageLog.logMessage("In demandFormUtils::savePhotoTaken. attrib value changed", tag="TOMs panel")
            except:
                QgsMessageLog.logMessage("In demandFormUtils::savePhotoTaken. problem changing attrib value",
                                         tag="TOMs panel")
                reply = QMessageBox.information(None, "Error",
                                                "savePhotoTaken. problem changing attrib value",
                                                QMessageBox.Ok)

class formCamera(QObject):
    notifyPhotoTaken = QtCore.pyqtSignal(str)

    def __init__(self, path_absolute, currFileName):
        QtCore.QObject.__init__(self)
        self.path_absolute = path_absolute
        self.currFileName = currFileName
        self.camera = cvCamera()

    @pyqtSlot(QPixmap)
    def displayFrame(self, pixmap):
        # QgsMessageLog.logMessage("In formCamera::displayFrame ... ", tag="TOMs panel")
        self.FIELD.setPixmap(pixmap)
        self.FIELD.setScaledContents(True)
        QtGui.QApplication.processEvents()  # processes the event queue - https://stackoverflow.com/questions/43094589/opencv-imshow-prevents-qt-python-crashing

    def useCamera(self, START_CAMERA_BUTTON, TAKE_PHOTO_BUTTON, FIELD):
        QgsMessageLog.logMessage("In formCamera::useCamera ... ", tag="TOMs panel")
        self.START_CAMERA_BUTTON = START_CAMERA_BUTTON
        self.TAKE_PHOTO_BUTTON = TAKE_PHOTO_BUTTON
        self.FIELD = FIELD

        # self.blockSignals(True)
        self.START_CAMERA_BUTTON.clicked.disconnect()
        self.START_CAMERA_BUTTON.clicked.connect(self.endCamera)

        """ Camera code  """

        self.camera.changePixmap.connect(self.displayFrame)
        self.camera.closeCamera.connect(self.endCamera)

        self.TAKE_PHOTO_BUTTON.setEnabled(True)
        self.TAKE_PHOTO_BUTTON.clicked.connect(functools.partial(self.camera.takePhoto, self.path_absolute))
        self.camera.photoTaken.connect(self.checkPhotoTaken)
        self.photoTaken = False

        QgsMessageLog.logMessage("In formCamera::useCamera: starting camera ... ", tag="TOMs panel")

        self.camera.startCamera()

    def endCamera(self):

        QgsMessageLog.logMessage("In formCamera::endCamera: stopping camera ... ", tag="TOMs panel")

        self.camera.stopCamera()
        self.camera.changePixmap.disconnect(self.displayFrame)
        self.camera.closeCamera.disconnect(self.endCamera)

        # del self.camera

        self.TAKE_PHOTO_BUTTON.setEnabled(False)
        self.START_CAMERA_BUTTON.setChecked(False)
        self.TAKE_PHOTO_BUTTON.clicked.disconnect()

        self.START_CAMERA_BUTTON.clicked.disconnect()
        self.START_CAMERA_BUTTON.clicked.connect(
            functools.partial(self.useCamera, self.START_CAMERA_BUTTON, self.TAKE_PHOTO_BUTTON, self.FIELD))

        if self.photoTaken == False:
            self.resetPhoto()

    @pyqtSlot(str)
    def checkPhotoTaken(self, fileName):
        QgsMessageLog.logMessage("In formCamera::photoTaken: file: " + fileName, tag="TOMs panel")

        if len(fileName) > 0:
            self.photoTaken = True
            self.notifyPhotoTaken.emit(fileName)
        else:
            self.resetPhoto()
            self.photoTaken = False

    def resetPhoto(self):
        QgsMessageLog.logMessage("In formCamera::resetPhoto ... ", tag="TOMs panel")

        pixmap = QPixmap(self.currFileName)
        if pixmap.isNull():
            pass
        else:
            self.FIELD.setPixmap(pixmap)
            self.FIELD.setScaledContents(True)


class cvCamera(QThread):
    changePixmap = pyqtSignal(QPixmap)
    closeCamera = pyqtSignal()
    photoTaken = pyqtSignal(str)

    def __init__(self):
        QThread.__init__(self)

    def stopCamera(self):
        QgsMessageLog.logMessage("In cvCamera::stopCamera ... ", tag="TOMs panel")
        self.cap.release()

    def startCamera(self):

        QgsMessageLog.logMessage("In cvCamera::startCamera: ... ", tag="TOMs panel")

        self.cap = cv2.VideoCapture(0)  # video capture source camera (Here webcam of laptop)

        self.cap.set(3, 640)  # width=640
        self.cap.set(4, 480)  # height=480

        while self.cap.isOpened():
            self.getFrame()
            # cv2.imshow('img1',self.frame) #display the captured image
            # cv2.waitKey(1)
            time.sleep(0.1)  # QTimer::singleShot()
        else:
            QgsMessageLog.logMessage("In cvCamera::startCamera: camera closed ... ", tag="TOMs panel")
            self.closeCamera.emit()

    def getFrame(self):

        """ Camera code  """

        # QgsMessageLog.logMessage("In cvCamera::getFrame ... ", tag="TOMs panel")

        ret, self.frame = self.cap.read()  # return a single frame in variable `frame`

        if ret == True:
            # Need to change from BRG (cv::mat) to RGB image
            cvRGBImg = cv2.cvtColor(self.frame, cv2.cv.CV_BGR2RGB)
            qimg = QtGui.QImage(cvRGBImg.data, cvRGBImg.shape[1], cvRGBImg.shape[0], QtGui.QImage.Format_RGB888)

            # Now display ...
            pixmap = QtGui.QPixmap.fromImage(qimg)

            self.changePixmap.emit(pixmap)

        else:

            QgsMessageLog.logMessage("In cvCamera::useCamera: frame not returned ... ", tag="TOMs panel")
            self.closeCamera.emit()

    def takePhoto(self, path_absolute):

        QgsMessageLog.logMessage("In cvCamera::takePhoto ... ", tag="TOMs panel")
        # Save frame to file

        fileName = 'Photo_{}.png'.format(datetime.datetime.now().strftime('%Y%m%d_%H%M%S%z'))
        newPhotoFileName = os.path.join(path_absolute, fileName)

        QgsMessageLog.logMessage("Saving photo: file: " + newPhotoFileName, tag="TOMs panel")
        writeStatus = cv2.imwrite(newPhotoFileName, self.frame)

        if writeStatus is True:
            reply = QMessageBox.information(None, "Information", "Photo captured.", QMessageBox.Ok)
            self.photoTaken.emit(newPhotoFileName)
        else:
            reply = QMessageBox.information(None, "Information", "Problem taking photo.", QMessageBox.Ok)
            self.photoTaken.emit()

        # Now stop camera (and display image)

        self.cap.release()
