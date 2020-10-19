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
    QApplication,
    QComboBox, QSizePolicy, QGridLayout
)

from qgis.PyQt.QtGui import (
    QIcon,
    QPixmap,
    QImage, QPainter
)

from qgis.PyQt.QtCore import (
    QObject,
    QTimer,
    QThread,
    pyqtSignal,
    pyqtSlot, Qt
)

from qgis.PyQt.QtSql import (
    QSqlDatabase
)

from qgis.core import (
    Qgis,
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
import time, datetime
import os, uuid
#import cv2
import math

from abc import ABCMeta
from TOMs.generateGeometryUtils import generateGeometryUtils
from TOMs.restrictionTypeUtilsClass import (TOMsParams, TOMsLayers, originalFeature, RestrictionTypeUtilsMixin)

from TOMs.ui.TOMsCamera import (formCamera)
from restrictionsWithGNSS.ui.imageLabel import (imageLabel)

cv2_available = True
try:
    import cv2
except ImportError:
    QgsMessageLog.logMessage("Not able to import cv2 ...", tag="TOMs panel")
    cv2_available = False

import uuid
from TOMs.core.TOMsMessageLog import TOMsMessageLog

ZOOM_LIMIT = 5

class gpsLayers(TOMsLayers):
    def __init__(self, iface):
        TOMsLayers.__init__(self, iface)
        self.iface = iface
        #TOMsMessageLog.logMessage("In gpsLayers.init ...", level=Qgis.Info)
        # TODO: Load these from a local file - or database
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
            "AdditionalConditionTypes",
            "BayLineTypes",
            "BayTypesInUse",
            "BayTypesInUse_View",
            "LineTypesInUse",
            "LineTypesInUse_View",
            "RestrictionPolygonTypes",
            "RestrictionPolygonTypesInUse",
            "RestrictionPolygonTypesInUse_View",
            "LengthOfTime",
            "PaymentTypes",
            #"RestrictionShapeTypes",
            "MHTC_CheckIssueTypes",
            #"MHTC_CheckStatus",
            "SignConditionTypes",
            "SignIlluminationTypes",
            "SignOrientationTypes",
            "SignTypes",
            "SignTypesInUse",
            "SignTypesInUse_View",
            "TimePeriods",
            "TimePeriodsInUse",
            "TimePeriodsInUse_View",
            "UnacceptableTypes",
            "Benches",
            "Bins",
            "Bollards (point)",
            "BusStopSigns",
            "CCTV_Cameras",
            "CommunicationCabinets",
            "CycleParking (point)",
            "CycleParking (in a line)",
            "DisplayBoards",
            "EV_ChargingPoints",
            "StreetNamePlates",
            "SubterraneanFeatures",
            "TrafficSignals",
            "UnidentifiedStaticObjects",
            "VehicleBarriers",
            "Bollards (in a line)",
            "BusShelters",
            "CrossingPoints",
            "EndOfStreetMarkings",
            "PedestrianRailings",
            "TrafficCalming",
            "ISL_Electrical_Items",
            "ISL_Electrical_Item_Types",
            "AssetConditionTypes",
            "BinTypes",
            "BollardTypes",
            "CommunicationCabinetTypes",
            "CrossingPointTypes",
            "CycleParkingTypes",
            "DisplayBoardTypes",
            "EV_ChargingPointTypes",
            "EndOfStreetMarkingTypes",
            "PedestrianRailingsTypes",
            "Postboxes",
            "SubterraneanFeatureTypes",
            "TelephoneBoxes",
            "TelegraphPoles",
            "TrafficCalmingTypes",
            "VehicleBarrierTypes",
            "AccessRestrictions",
            "CarriagewayMarkingTypesInUse",
            "CarriagewayMarkingTypesInUse_View",
            "CarriagewayMarkings",
            "HighwayDedications",
            "RestrictionsForVehicles",
            "StructureTypeValues",
            "SpecialDesignations",
            "TurnRestrictions",
            "vehicleQualifiers",
            "MHTC_RoadLinks",
            "GNSS_Pts",
            "MHTC_Kerblines"
                         ]
        self.TOMsLayerDict = {}

class gpsParams(TOMsParams):
    def __init__(self):
        TOMsParams.__init__(self)
        #self.iface = iface

        #TOMsMessageLog.logMessage("In gpsParams.init ...", level=Qgis.Info)

        self.TOMsParamsList.extend([
                          "gpsPort",
                          "CameraNr",
                          "roamDistance"
                               ])

class FieldRestrictionTypeUtilsMixin():
    def __init__(self, iface):
        #RestrictionTypeUtilsMixin.__init__(self, iface)
        self.iface = iface
        self.settings = QgsSettings()

        self.params = gpsParams()

        #self.TOMsUtils = RestrictionTypeUtilsMixin(self.iface)

    def setDefaultFieldRestrictionDetails(self, currRestriction, currRestrictionLayer, currDate):
        TOMsMessageLog.logMessage("In setDefaultFieldRestrictionDetails: {}".format(currRestrictionLayer.name()), level=Qgis.Info)

        # TODO: Need to check whether or not these fields exist. Also need to retain the last values and reuse
        # gis.stackexchange.com/questions/138563/replacing-action-triggered-script-by-one-supplied-through-qgis-plugin

        try:
            currRestriction.setAttribute("LastUpdateDateTime", currDate)
        except Exception as e:
            TOMsMessageLog.logMessage("In setDefaultFieldRestrictionDetails. Problem with setting LastUpdateDateTime: {}".format(e),
                                      level=Qgis.Info)

        try:
            generateGeometryUtils.setRoadName(currRestriction)
        except Exception as e:
            TOMsMessageLog.logMessage("In setDefaultFieldRestrictionDetails. Problem with setting Road Name: {}".format(e),
                                      level=Qgis.Info)

        """if currRestrictionLayer.geometryType() == 1:  # Line or Bay
            generateGeometryUtils.setAzimuthToRoadCentreLine(currRestriction)
            currRestriction.setAttribute("RestrictionLength", currRestriction.geometry().length())"""

        currentCPZ, cpzWaitingTimeID, cpzMatchDayTimePeriodID = generateGeometryUtils.getCurrentCPZDetails(currRestriction)
        """TOMsMessageLog.logMessage(
            "In setDefaultFieldRestrictionDetails. CPZ found: {}: control: {}".format(currentCPZ, cpzWaitingTimeID),
            level=Qgis.Warning)"""
        #currRestriction.setAttribute("CPZ", currentCPZ)

        newRestrictionID = str(uuid.uuid4())
        currRestriction.setAttribute("RestrictionID", newRestrictionID)
        TOMsMessageLog.logMessage("In setDefaultFieldRestrictionDetails. newRestID: {}, {}".format(newRestrictionID, currRestriction[currRestrictionLayer.fields().indexFromName("RestrictionID")]),
                                  level=Qgis.Info)

        if currRestrictionLayer.name() == "Lines":
            currRestriction.setAttribute("RestrictionTypeID", self.readLastUsedDetails("Lines", "RestrictionTypeID", 201))  # 10 = SYL (Lines)
            currRestriction.setAttribute("GeomShapeID", self.readLastUsedDetails("Lines", "GeomShapeID", 10))   # 10 = Parallel Line
            currRestriction.setAttribute("NoWaitingTimeID", cpzWaitingTimeID)
            #currRestriction.setAttribute("NoLoadingTimeID", self.readLastUsedDetails("Lines", "NoLoadingTimeID", None))
            #currRestriction.setAttribute("NoWTimeID", cpzWaitingTimeID)
            #currRestriction.setAttribute("CreateDateTime", currDate)
            currRestriction.setAttribute("UnacceptableTypeID", self.readLastUsedDetails("Lines", "UnacceptableTypeID", None))

            generateGeometryUtils.setAzimuthToRoadCentreLine(currRestriction)
            currRestriction.setAttribute("RestrictionLength", currRestriction.geometry().length())

            currRestriction.setAttribute("CPZ", currentCPZ)
            currRestriction.setAttribute("MatchDayTimePeriodID", cpzMatchDayTimePeriodID)

            currRestriction.setAttribute("ComplianceRestrictionSignIssue", 1)  # No issue
            currRestriction.setAttribute("ComplianceRoadMarkingsFaded", 1)  # No issue

        elif currRestrictionLayer.name() == "Bays":
            currRestriction.setAttribute("RestrictionTypeID", self.readLastUsedDetails("Bays", "RestrictionTypeID", 101))  # 28 = Permit Holders Bays (Bays)
            currRestriction.setAttribute("GeomShapeID", self.readLastUsedDetails("Bays", "GeomShapeID", 1)) # 21 = Parallel Bay (Polygon)
            currRestriction.setAttribute("NrBays", -1)
            currRestriction.setAttribute("TimePeriodID", cpzWaitingTimeID)

            #currRestriction.setAttribute("MaxStayID", ptaMaxStayID)
            #currRestriction.setAttribute("NoReturnID", ptaNoReturnTimeID)
            #currRestriction.setAttribute("ParkingTariffArea", currentPTA)
            #currRestriction.setAttribute("CreateDateTime", currDate)
            generateGeometryUtils.setAzimuthToRoadCentreLine(currRestriction)
            currRestriction.setAttribute("RestrictionLength", currRestriction.geometry().length())

            currRestriction.setAttribute("CPZ", currentCPZ)
            currRestriction.setAttribute("MatchDayTimePeriodID", cpzMatchDayTimePeriodID)

            currRestriction.setAttribute("ComplianceRestrictionSignIssue", 1)  # No issue
            currRestriction.setAttribute("ComplianceRoadMarkingsFaded", 1)  # No issue

            try:
                payParkingAreasLayer = QgsProject.instance().mapLayersByName("PayParkingAreas")[0]
                currPayParkingArea = generateGeometryUtils.getPolygonForRestriction(currRestriction,
                                                                                    payParkingAreasLayer)
                currRestriction.setAttribute("PayParkingAreaID", currPayParkingArea.attribute("Code"))
            except Exception as e:
                TOMsMessageLog.logMessage(
                    "In setDefaultFieldRestrictionDetails. issue obtaining PayParkingAreaID: {}".format(e),
                    level=Qgis.Info)

        elif currRestrictionLayer.name() == "Signs":
            currRestriction.setAttribute("SignType_1", self.readLastUsedDetails("Signs", "SignType_1", 28))  # 28 = Permit Holders Only (Signs)
            #currRestriction.setAttribute("SignOrientationTypeID", NULL)
            currRestriction.setAttribute("SignConditionTypeID", 1)  # 1 = Good
            currRestriction.setAttribute("ComplianceRestrictionSignIssue", 1)  # No issue

        elif currRestrictionLayer.name() == "RestrictionPolygons":
            currRestriction.setAttribute("RestrictionTypeID", self.readLastUsedDetails("RestrictionPolygons", "RestrictionTypeID", 4))  # 28 = Residential mews area (RestrictionPolygons)

            currRestriction.setAttribute("CPZ", currentCPZ)
            currRestriction.setAttribute("MatchDayTimePeriodID", cpzMatchDayTimePeriodID)

            currRestriction.setAttribute("GeomShapeID", self.readLastUsedDetails("Lines", "GeomShapeID", 50))   # 10 = Parallel Line
            currRestriction.setAttribute("ComplianceRestrictionSignIssue", 1)  # No issue
            currRestriction.setAttribute("ComplianceRoadMarkingsFaded", 1)  # No issue

        elif currRestrictionLayer.name() == "CrossingPoints":
            generateGeometryUtils.setAzimuthToRoadCentreLine(currRestriction)
            currRestriction.setAttribute("GeomShapeID", 35)  # 35 = Crossover

        # set compliance defaults
        try:
            currRestriction.setAttribute("ComplianceRoadMarkingsFaded", 1)  # No issue
        except Exception as e:
            TOMsMessageLog.logMessage("In setDefaultFieldRestrictionDetails. Problem with setting ComplianceRoadMarkingsFaded: {}".format(e),
                                      level=Qgis.Info)

        try:
            currRestriction.setAttribute("ComplianceRestrictionSignIssue", 1)  # No issue
        except Exception as e:
            TOMsMessageLog.logMessage("In setDefaultFieldRestrictionDetails. Problem with setting ComplianceRestrictionSignIssue: {}".format(e),
                                      level=Qgis.Info)

        # update feature
        #currRestrictionLayer.updateFeature(currRestriction)

    def storeLastUsedDetails(self, layer, field, value):
        entry = '{layer}/{field}'.format(layer=layer, field=field)
        TOMsMessageLog.logMessage("In storeLastUsedDetails: " + str(entry) + " (" + str(value) + ")", level=Qgis.Info)
        self.settings.setValue(entry, value)

    def readLastUsedDetails(self, layer, field, default):
        entry = '{layer}/{field}'.format(layer=layer, field=field)
        TOMsMessageLog.logMessage("In readLastUsedDetails: " + str(entry) + " (" + str(default) + ")", level=Qgis.Info)
        return self.settings.value(entry, default)

    def setupFieldRestrictionDialog(self, restrictionDialog, currRestrictionLayer, currRestriction):

        #self.restrictionDialog = restrictionDialog
        #self.currRestrictionLayer = currRestrictionLayer
        #self.currRestriction = currRestriction
        #self.restrictionTransaction = restrictionTransaction

        self.params.getParams()

        # Create a copy of the feature
        self.origFeature = originalFeature()
        self.origFeature.setFeature(currRestriction)

        if restrictionDialog is None:
            reply = QMessageBox.information(None, "Error",
                                            "setupFieldRestrictionDialog. Correct form not found",
                                            QMessageBox.Ok)
            TOMsMessageLog.logMessage(
                "In setupRestrictionDialog. dialog not found",
                level=Qgis.Warning)
            return

        restrictionDialog.attributeForm().disconnectButtonBox()
        button_box = restrictionDialog.findChild(QDialogButtonBox, "button_box")

        if button_box is None:
            TOMsMessageLog.logMessage(
                "In setupRestrictionDialog. button box not found",
                level=Qgis.Warning)
            return

        button_box.accepted.connect(functools.partial(self.onSaveFieldRestrictionDetails, currRestriction,
                                      currRestrictionLayer, restrictionDialog))

        button_box.rejected.connect(functools.partial(self.onRejectFieldRestrictionDetailsFromForm, restrictionDialog, currRestrictionLayer))

        restrictionDialog.attributeForm().attributeChanged.connect(functools.partial(self.onAttributeChangedClass2_local, currRestriction, currRestrictionLayer))

        self.photoDetails_field(restrictionDialog, currRestrictionLayer, currRestriction)

        self.addScrollBars(restrictionDialog)

        """def onSaveRestrictionDetailsFromForm(self):
        TOMsMessageLog.logMessage("In onSaveRestrictionDetailsFromForm", level=Qgis.Info)
        self.onSaveRestrictionDetails(self.currRestriction,
                                      self.currRestrictionLayer, self.restrictionDialog, self.restrictionTransaction)"""

    def onAttributeChangedClass2_local(self, currFeature, layer, fieldName, value):

        #self.TOMsUtils.onAttributeChangedClass2(currFeature, layer, fieldName, value)

        TOMsMessageLog.logMessage(
            "In field:FormOpen:onAttributeChangedClass 2 - layer: " + str(layer.name()) + " (" + fieldName + "): " + str(value), level=Qgis.Info)


        # self.currRestriction.setAttribute(fieldName, value)
        try:

            currFeature[layer.fields().indexFromName(fieldName)] = value
            #currFeature.setAttribute(layer.fields().indexFromName(fieldName), value)

        except Exception as e:

            reply = QMessageBox.information(None, "Error",
                                                "onAttributeChangedClass2. Update failed for: " + str(layer.name()) + " (" + fieldName + "): " + str(value),
                                                QMessageBox.Ok)  # rollback all changes


        self.storeLastUsedDetails(layer.name(), fieldName, value)

        return

    def onSaveFieldRestrictionDetails(self, currFeature, currFeatureLayer, dialog):
        TOMsMessageLog.logMessage("In onSaveFieldRestrictionDetails: ", level=Qgis.Info)

        try:
            self.camera1.endCamera()
            self.camera2.endCamera()
            self.camera3.endCamera()
        except:
            None

        attrs1 = currFeature.attributes()
        TOMsMessageLog.logMessage("In onSaveDemandDetails: currRestriction: " + str(attrs1),
                                 level=Qgis.Warning)

        TOMsMessageLog.logMessage(
            ("In onSaveDemandDetails. geometry: " + str(currFeature.geometry().asWkt())),
            level=Qgis.Warning)

        currFeatureID = currFeature.id()
        TOMsMessageLog.logMessage("In onSaveDemandDetails: currFeatureID: " + str(currFeatureID),
                                 level=Qgis.Warning)

        status = currFeatureLayer.updateFeature(currFeature)
        TOMsMessageLog.logMessage("In onSaveDemandDetails: feature updated: " + str(currFeatureID),
                                 level=Qgis.Warning)
        """if currFeatureID > 0:   # Not sure what this value should if the feature has not been created ...

            # TODO: Sort out this for UPDATE
            self.setDefaultRestrictionDetails(currFeature, currFeatureLayer)

            status = currFeatureLayer.updateFeature(currFeature)
            TOMsMessageLog.logMessage("In onSaveDemandDetails: updated Feature: ", level=Qgis.Info)
        else:
            status = currFeatureLayer.addFeature(currFeature)
            TOMsMessageLog.logMessage("In onSaveDemandDetails: added Feature: " + str(status), level=Qgis.Info)"""

        status = dialog.attributeForm().close()
        TOMsMessageLog.logMessage("In onSaveDemandDetails: dialog saved: " + str(currFeatureID),
                                 level=Qgis.Warning)
        #currRestrictionLayer.addFeature(currRestriction)  # TH (added for v3)
        #status = currFeatureLayer.updateFeature(currFeature)  # TH (added for v3)

        try:
            currFeatureLayer.commitChanges()
        except Exception as e:
            reply = QMessageBox.information(None, "Information", "Problem committing changes: {}".format(e), QMessageBox.Ok)

        #currFeatureLayer.blockSignals(False)

        TOMsMessageLog.logMessage("In onSaveDemandDetails: changes committed", level=Qgis.Info)

        status = dialog.close()
        #self.mapTool = None
        #self.iface.mapCanvas().unsetMapTool(self.iface.mapCanvas().mapTool())

    def onRejectFieldRestrictionDetailsFromForm(self, restrictionDialog, currFeatureLayer):
        TOMsMessageLog.logMessage("In onRejectFieldRestrictionDetailsFromForm", level=Qgis.Info)

        try:
            self.camera1.endCamera()
            self.camera2.endCamera()
            self.camera3.endCamera()
        except:
            None

        currFeatureLayer.rollBack()
        restrictionDialog.reject()

        #del self.mapTool

    def photoDetails_field(self, restrictionDialog, currRestrictionLayer, currRestriction):

        # Function to deal with photo fields

        self.demandDialog = restrictionDialog
        self.currDemandLayer = currRestrictionLayer
        self.currFeature = currRestriction

        TOMsMessageLog.logMessage("In photoDetails", level=Qgis.Info)

        photoPath = QgsExpressionContextUtils.projectScope(QgsProject.instance()).variable('PhotoPath')
        projectFolder = QgsExpressionContextUtils.projectScope(QgsProject.instance()).variable('project_folder')

        path_absolute = os.path.join(projectFolder, photoPath)

        if path_absolute == None:
            reply = QMessageBox.information(None, "Information", "Please set value for PhotoPath.", QMessageBox.Ok)
            return

        # Check path exists ...
        if os.path.isdir(path_absolute) == False:
            reply = QMessageBox.information(None, "Information", "PhotoPath folder " + str(
                path_absolute) + " does not exist. Please check value.", QMessageBox.Ok)
            return

        # if cv2 is available, check camera nr
        try:
            cameraNr = int(self.params.setParam("CameraNr"))
        except Exception as e:
            TOMsMessageLog.logMessage("In photoDetails_field: cameraNr issue: {}".format(e), level=Qgis.Info)
            if cv2_available:
                cameraNr = QMessageBox.information(None, "Information", "Please set value for CameraNr.", QMessageBox.Ok)
            cameraNr = None

        TOMsMessageLog.logMessage("In photoDetails_field: cameraNr is: {}".format(cameraNr), level=Qgis.Info)

        layerName = self.currDemandLayer.name()

        # Generate the full path to the file

        fileName1 = "Photos_01"
        fileName2 = "Photos_02"
        fileName3 = "Photos_03"

        idx1 = self.currDemandLayer.fields().indexFromName(fileName1)
        idx2 = self.currDemandLayer.fields().indexFromName(fileName2)
        idx3 = self.currDemandLayer.fields().indexFromName(fileName3)

        TOMsMessageLog.logMessage("In photoDetails. idx1: " + str(idx1) + "; " + str(idx2) + "; " + str(idx3),
                                 level=Qgis.Info)

        if cameraNr is not None:
            TOMsMessageLog.logMessage("Camera TRUE", level=Qgis.Info)
            takePhoto = True
        else:
            TOMsMessageLog.logMessage("Camera FALSE", level=Qgis.Info)
            takePhoto = False

        FIELD1 = self.demandDialog.findChild(QLabel, "Photo_Widget_01")
        FIELD2 = self.demandDialog.findChild(QLabel, "Photo_Widget_02")
        FIELD3 = self.demandDialog.findChild(QLabel, "Photo_Widget_03")

        if FIELD1:
            TOMsMessageLog.logMessage("In photoDetails. FIELD 1 exists",
                                     level=Qgis.Info)
            if self.currFeature[idx1]:
                newPhotoFileName1 = os.path.join(path_absolute, self.currFeature[idx1])
                TOMsMessageLog.logMessage("In photoDetails. photo1: {}".format(newPhotoFileName1), level=Qgis.Info)
            else:
                newPhotoFileName1 = None

            pixmap1 = QPixmap(newPhotoFileName1)
            if pixmap1.isNull():
                pass
                # FIELD1.setText('Picture could not be opened ({path})'.format(path=newPhotoFileName1))
            else:

                tab = FIELD1.parentWidget()
                grid = FIELD1.parentWidget().layout()

                photo_Widget1 = imageLabel(tab)
                TOMsMessageLog.logMessage(
                    "In photoDetails. FIELD 1 w: {}; h: {}".format(FIELD1.width(), FIELD1.height()), level=Qgis.Info)
                photo_Widget1.setObjectName("Photo_Widget_01")
                photo_Widget1.setText("No photo is here")
                #photo_Widget1 = imageLabel(tab)
                grid.addWidget(photo_Widget1, 0, 0, 1, 1)

                FIELD1.hide()
                FIELD1.setParent(None)
                FIELD1 = photo_Widget1
                FIELD1.set_Pixmap(pixmap1)

                TOMsMessageLog.logMessage("In photoDetails. FIELD 1 Photo1: " + str(newPhotoFileName1), level=Qgis.Info)
                TOMsMessageLog.logMessage("In photoDetails.pixmap1 size: {}".format(pixmap1.size()),
                                          level=Qgis.Info)

                FIELD1.pixmapUpdated.connect(functools.partial(self.displayPixmapUpdated, FIELD1))
                #ZOOM_IN_1 = self.demandDialog.findChild(QPushButton, "pb_zoomIn_01")
                #ZOOM_IN_1.clicked.connect(FIELD1._zoomInButton)

                #ZOOM_OUT_1 = self.demandDialog.findChild(QPushButton, "pb_zoomOut_01")
                #ZOOM_OUT_1.clicked.connect(FIELD1._zoomOutButton)

            if takePhoto:
                START_CAMERA_1 = self.demandDialog.findChild(QPushButton, "startCamera1")
                TAKE_PHOTO_1 = self.demandDialog.findChild(QPushButton, "getPhoto1")
                TAKE_PHOTO_1.setEnabled(False)

                self.camera1 = formCamera(path_absolute, newPhotoFileName1, cameraNr)
                START_CAMERA_1.clicked.connect(
                    functools.partial(self.camera1.useCamera, START_CAMERA_1, TAKE_PHOTO_1, FIELD1))
                self.camera1.notifyPhotoTaken.connect(functools.partial(self.savePhotoTaken, idx1))

        if FIELD2:
            TOMsMessageLog.logMessage("In photoDetails. FIELD 2 exisits",
                                     level=Qgis.Info)
            if self.currFeature[idx2]:
                newPhotoFileName2 = os.path.join(path_absolute, self.currFeature[idx2])
                TOMsMessageLog.logMessage("In photoDetails. Photo1: " + str(newPhotoFileName2), level=Qgis.Info)
            else:
                newPhotoFileName2 = None

            # newPhotoFileName2 = os.path.join(path_absolute, str(self.currFeature[idx2]))
            # newPhotoFileName2 = os.path.join(path_absolute, str(self.currFeature.attribute(fileName2)))
            # TOMsMessageLog.logMessage("In photoDetails. Photo2: " + str(newPhotoFileName2), level=Qgis.Info)
            pixmap2 = QPixmap(newPhotoFileName2)
            if pixmap2.isNull():
                pass
                # FIELD1.setText('Picture could not be opened ({path})'.format(path=newPhotoFileName1))
            else:

                tab = FIELD2.parentWidget()
                grid = FIELD2.parentWidget().layout()

                photo_Widget2 = imageLabel(tab)
                TOMsMessageLog.logMessage(
                    "In photoDetails. FIELD 2 w: {}; h: {}".format(FIELD2.width(), FIELD2.height()), level=Qgis.Info)
                photo_Widget2.setObjectName("Photo_Widget_02")
                photo_Widget2.setText("No photo is here")
                #photo_Widget2 = imageLabel(tab)
                grid.addWidget(photo_Widget2, 0, 0, 1, 1)

                FIELD2.hide()
                FIELD2.setParent(None)
                FIELD2 = photo_Widget2
                FIELD2.set_Pixmap(pixmap2)

                TOMsMessageLog.logMessage("In photoDetails. FIELD 2 Photo2: " + str(newPhotoFileName2), level=Qgis.Info)
                TOMsMessageLog.logMessage("In photoDetails.pixmap2 size: {}".format(pixmap2.size()),
                                          level=Qgis.Info)

                FIELD2.pixmapUpdated.connect(functools.partial(self.displayPixmapUpdated, FIELD2))
                #ZOOM_IN_2 = self.demandDialog.findChild(QPushButton, "pb_zoomIn_02")
                #ZOOM_IN_2.clicked.connect(FIELD2._zoomInButton)

                #ZOOM_OUT_2 = self.demandDialog.findChild(QPushButton, "pb_zoomOut_02")
                #ZOOM_OUT_2.clicked.connect(FIELD2._zoomOutButton)

                """
                FIELD2.setPixmap(pixmap2)
                FIELD2.setScaledContents(True)
                TOMsMessageLog.logMessage("In photoDetails. Photo2: " + str(newPhotoFileName2), level=Qgis.Info)"""

            if takePhoto:
                START_CAMERA_2 = self.demandDialog.findChild(QPushButton, "startCamera2")
                TAKE_PHOTO_2 = self.demandDialog.findChild(QPushButton, "getPhoto2")
                TAKE_PHOTO_2.setEnabled(False)

                self.camera2 = formCamera(path_absolute, newPhotoFileName2, cameraNr)
                START_CAMERA_2.clicked.connect(
                    functools.partial(self.camera2.useCamera, START_CAMERA_2, TAKE_PHOTO_2, FIELD2))
                self.camera2.notifyPhotoTaken.connect(functools.partial(self.savePhotoTaken, idx2))

        if FIELD3:
            TOMsMessageLog.logMessage("In photoDetails. FIELD 3 exisits",
                                     level=Qgis.Info)

            if self.currFeature[idx3]:
                newPhotoFileName3 = os.path.join(path_absolute, self.currFeature[idx3])
                TOMsMessageLog.logMessage("In photoDetails. Photo1: " + str(newPhotoFileName3), level=Qgis.Info)
            else:
                newPhotoFileName3 = None

            # newPhotoFileName3 = os.path.join(path_absolute, str(self.currFeature[idx3]))
            # newPhotoFileName3 = os.path.join(path_absolute,
            #                                 str(self.currFeature.attribute(fileName3)))
            # newPhotoFileName3 = os.path.join(path_absolute, str(layerName + "_Photos_03"))

            # TOMsMessageLog.logMessage("In photoDetails. Photo3: " + str(newPhotoFileName3), level=Qgis.Info)
            pixmap3 = QPixmap(newPhotoFileName3)
            if pixmap3.isNull():
                pass
                # FIELD1.setText('Picture could not be opened ({path})'.format(path=newPhotoFileName1))
            else:
                
                tab = FIELD3.parentWidget()
                grid = FIELD3.parentWidget().layout()

                photo_Widget3 = imageLabel(tab)
                TOMsMessageLog.logMessage(
                    "In photoDetails. FIELD 3 w: {}; h: {}".format(FIELD3.width(), FIELD3.height()), level=Qgis.Info)
                photo_Widget3.setObjectName("Photo_Widget_03")
                photo_Widget3.setText("No photo is here")
                #photo_Widget3 = imageLabel(tab)
                grid.addWidget(photo_Widget3, 0, 0, 1, 1)

                FIELD3.hide()
                FIELD3.setParent(None)
                FIELD3 = photo_Widget3
                FIELD3.set_Pixmap(pixmap3)

                TOMsMessageLog.logMessage("In photoDetails. FIELD 3 Photo3: " + str(newPhotoFileName3), level=Qgis.Info)
                TOMsMessageLog.logMessage("In photoDetails.pixmap3 size: {}".format(pixmap3.size()),
                                          level=Qgis.Info)

                FIELD3.pixmapUpdated.connect(functools.partial(self.displayPixmapUpdated, FIELD3))
                #ZOOM_IN_3 = self.demandDialog.findChild(QPushButton, "pb_zoomIn_03")
                #ZOOM_IN_3.clicked.connect(FIELD3._zoomInButton)

                #ZOOM_OUT_3 = self.demandDialog.findChild(QPushButton, "pb_zoomOut_03")
                #ZOOM_OUT_3.clicked.connect(FIELD3._zoomOutButton)

                """FIELD3.setPixmap(pixmap3)
                FIELD3.setScaledContents(True)
                TOMsMessageLog.logMessage("In photoDetails. Photo3: " + str(newPhotoFileName3), level=Qgis.Info)"""

            if takePhoto:
                START_CAMERA_3 = self.demandDialog.findChild(QPushButton, "startCamera3")
                TAKE_PHOTO_3 = self.demandDialog.findChild(QPushButton, "getPhoto3")
                TAKE_PHOTO_3.setEnabled(False)

                self.camera3 = formCamera(path_absolute, newPhotoFileName3, cameraNr)
                START_CAMERA_3.clicked.connect(
                    functools.partial(self.camera3.useCamera, START_CAMERA_3, TAKE_PHOTO_3, FIELD3))
                self.camera3.notifyPhotoTaken.connect(functools.partial(self.savePhotoTaken, idx3))

        pass

    def addScrollBars(self, restrictionDialog):
        TOMsMessageLog.logMessage("In addScrollBars", level=Qgis.Info)

        # find any combo boxes in the form and add the scroll bar

        childWidgetList = restrictionDialog.findChildren(QComboBox)
        #button_box = restrictionDialog.findChild(QDialogButtonBox, "button_box")

        for formWidget in childWidgetList:

            TOMsMessageLog.logMessage("In addScrollBars: widget type {}".format(type(formWidget)), level=Qgis.Info)

            if isinstance(formWidget, QComboBox):
                #print('WidgetName: {}'.format(formWidget.objectName()))
                formWidget.setStyleSheet("QComboBox { combobox-popup: 0; }")
                formWidget.setMaxVisibleItems(10)
                formWidget.view().setVerticalScrollBarPolicy(Qt.ScrollBarAsNeeded)

        return

    def getLookupDescription(self, lookupLayer, code):

        #TOMsMessageLog.logMessage("In getLookupDescription", level=Qgis.Info)

        query = "\"Code\" = " + str(code)
        request = QgsFeatureRequest().setFilterExpression(query)

        #TOMsMessageLog.logMessage("In getLookupDescription. queryStatus: " + str(query), level=Qgis.Info)

        for row in lookupLayer.getFeatures(request):
            #TOMsMessageLog.logMessage("In getLookupDescription: found row " + str(row.attribute("Description")), level=Qgis.Info)
            return row.attribute("Description") # make assumption that only one row

        return None

    @pyqtSlot(QPixmap)
    def displayPixmapUpdated(self, FIELD, pixmap):
        TOMsMessageLog.logMessage("In utils::displayPixmapUpdated ... ", level=Qgis.Warning)
        FIELD.setPixmap(pixmap)
        FIELD.setScaledContents(True)
        QApplication.processEvents()  # processes the event queue - https://stackoverflow.com/questions/43094589/opencv-imshow-prevents-qt-python-crashing

    """"@pyqtSlot(QPixmap)
    def displayFrame(self, pixmap):
        TOMsMessageLog.logMessage("In formCamera::displayFrame ... ", level=Qgis.Info)
        self.FIELD.setPixmap(pixmap)
        self.FIELD.setScaledContents(True)
        QApplication.processEvents()  # processes the event queue - https://stackoverflow.com/questions/43094589/opencv-imshow-prevents-qt-python-crashing"""

    @pyqtSlot(str)
    def savePhotoTaken(self, idx, fileName):
        TOMsMessageLog.logMessage("In demandFormUtils::savePhotoTaken ... " + fileName + " idx: " + str(idx),
                                 level=Qgis.Info)
        if len(fileName) > 0:
            simpleFile = os.path.basename(fileName)
            TOMsMessageLog.logMessage("In demandFormUtils::savePhotoTaken. Simple file: " + simpleFile, level=Qgis.Info)

            try:
                self.currFeature[idx] = simpleFile
                TOMsMessageLog.logMessage("In demandFormUtils::savePhotoTaken. attrib value changed", level=Qgis.Info)
            except:
                TOMsMessageLog.logMessage("In demandFormUtils::savePhotoTaken. problem changing attrib value",
                                         level=Qgis.Info)
                reply = QMessageBox.information(None, "Error",
                                                "savePhotoTaken. problem changing attrib value",
                                                QMessageBox.Ok)

    def store_gnss_pts(self, curr_gps_location, curr_gps_info):

        TOMsMessageLog.logMessage("In gnssTools.store_gnss_pts ",
                                     level=Qgis.Info)

        GNSS_Pts_Layer = self.tableNames.setLayer("GNSS_Pts")
        try:
            GNSS_Pts_Layer.startEditing()
        except Exception as e:
            reply = QMessageBox.information(None, "Information", "Problem starting edit session on GNSS_Pts: {}".format(e), QMessageBox.Ok)
            TOMsMessageLog.logMessage("Problem starting edit session on GNSS_Pts: {}".format(e), level=Qgis.Warning)
            return False

        fields = GNSS_Pts_Layer.fields()
        feature = QgsFeature()
        feature.setFields(fields)
        feature.setGeometry(QgsGeometry.fromPointXY(curr_gps_location))

        for gnssField in dir(curr_gps_info):
            #TOMsMessageLog.logMessage ('Attribute: {}'.format(gnssField), level=Qgis.Warning)
            if gnssField in fields.names():
                value = getattr(curr_gps_info, gnssField)

                TOMsMessageLog.logMessage ('** Found {}: {}'.format(gnssField, value), level=Qgis.Info)

                if GNSS_Pts_Layer.fields().field(gnssField).isNumeric():
                    if math.isnan(value):   # https://stackoverflow.com/questions/944700/how-can-i-check-for-nan-values
                        value = None
                feature[GNSS_Pts_Layer.fields().indexFromName(gnssField)] = value

        #attrs = feature.attributes()
        #TOMsMessageLog.logMessage('--Attribs {}'.format(attrs), level=Qgis.Warning)

        GNSS_Pts_Layer.addFeatures([feature])

        try:
            GNSS_Pts_Layer.commitChanges()
        except Exception as e:
            reply = QMessageBox.information(None, "Information", "Problem committing changes to GNSS_Pts: {}".format(e), QMessageBox.Ok)
            TOMsMessageLog.logMessage("Problem committing changes to GNSS_Pts: {}".format(e), level=Qgis.Warning)

            return False

        return True
