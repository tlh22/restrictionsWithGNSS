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
    QComboBox, QSizePolicy, QGridLayout, QWidget
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
from TOMs.restrictionTypeUtilsClass import (TOMsParams, TOMsLayers, originalFeature, TOMsConfigFile, RestrictionTypeUtilsMixin)

from TOMs.ui.TOMsCamera import (formCamera)
from TOMs.ui.TOMsCamera2 import TOMsCameraWidget

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

"""
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
            "SubterraneanFeatures (point)",
            "SubterraneanFeatures (in a line)",
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

"""
class gpsParams(TOMsParams):
    def __init__(self):
        TOMsParams.__init__(self)
        #self.iface = iface

        #TOMsMessageLog.logMessage("In gpsParams.init ...", level=Qgis.Info)

        self.TOMsParamsList.extend([
                          "gpsPort",
                          "CameraNr",
                          "roamDistance",
                          "rotateCamera"
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

        currentCPZ, cpzWaitingTimeID = generateGeometryUtils.getCurrentCPZDetails(currRestriction)
        currentED, edWaitingTimeID = generateGeometryUtils.getCurrentEventDayDetails(currRestriction)
        #currentCPZ, cpzWaitingTimeID, cpzMatchDayTimePeriodID = generateGeometryUtils.getCurrentCPZDetails(currRestriction)
        """TOMsMessageLog.logMessage(
            "In setDefaultFieldRestrictionDetails. CPZ found: {}: control: {}".format(currentCPZ, cpzWaitingTimeID),
            level=Qgis.Info)"""
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
            currRestriction.setAttribute("MatchDayEventDayZone", currentED)
            currRestriction.setAttribute("MatchDayTimePeriodID", edWaitingTimeID)

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
            currRestriction.setAttribute("MatchDayEventDayZone", currentED)
            currRestriction.setAttribute("MatchDayTimePeriodID", edWaitingTimeID)

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
            currRestriction.setAttribute("SignOrientationTypeID", 3)
            currRestriction.setAttribute("SignConditionTypeID", 1)  # 1 = Good
            currRestriction.setAttribute("ComplianceRestrictionSignIssue", 1)  # No issue

        elif currRestrictionLayer.name() == "RestrictionPolygons":
            currRestriction.setAttribute("RestrictionTypeID", self.readLastUsedDetails("RestrictionPolygons", "RestrictionTypeID", 4))  # 28 = Residential mews area (RestrictionPolygons)

            currRestriction.setAttribute("CPZ", currentCPZ)
            currRestriction.setAttribute("MatchDayEventDayZone", currentED)
            currRestriction.setAttribute("MatchDayTimePeriodID", edWaitingTimeID)

            currRestriction.setAttribute("GeomShapeID", self.readLastUsedDetails("Lines", "GeomShapeID", 50))   # 10 = Parallel Line
            currRestriction.setAttribute("ComplianceRestrictionSignIssue", 1)  # No issue
            currRestriction.setAttribute("ComplianceRoadMarkingsFaded", 1)  # No issue

        elif currRestrictionLayer.name() == "CrossingPoints":
            generateGeometryUtils.setAzimuthToRoadCentreLine(currRestriction)
            currRestriction.setAttribute("GeomShapeID", 35)  # 35 = Crossover
            currRestriction.setAttribute("CrossingPointTypeID", 3)  # 3 = Vehicle (Dropped Kerb)

        elif currRestrictionLayer.name() == "CarriagewayMarkings":
            #generateGeometryUtils.setAzimuthToRoadCentreLine(currRestriction)
            currRestriction.setAttribute("CarriagewayMarkingType_1",
                                         self.readLastUsedDetails("CarriagewayMarkings", "CarriagewayMarkingType_1", 1))  # 1 = 20 mph

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
        TOMsMessageLog.logMessage("In setupFieldRestrictionDialog {}:{}... ".format(currRestrictionLayer.name(), currRestriction.attribute("RestrictionID")), level=Qgis.Info)

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

        TOMsMessageLog.logMessage("In setupFieldRestrictionDialog. Entering photoDetails_field ... ", level=Qgis.Info)
        """reply = QMessageBox.information(None, "Information",
                                        "Entering camera setup ...",
                                        QMessageBox.Ok)"""

        restrictionDialog.attributeForm().attributeChanged.connect(functools.partial(self.onAttributeChangedClass2_local, currRestriction, currRestrictionLayer))

        self.addScrollBars(restrictionDialog)

        self.photoDetails_field(restrictionDialog, currRestrictionLayer, currRestriction)

        """
            set form location (based on last position)
        """
        dw = restrictionDialog.width()
        dh = restrictionDialog.height()
        restrictionDialog.setGeometry(int(self.readLastUsedDetails(currRestrictionLayer.name(), 'geometry_x', 200)),
                                      int(self.readLastUsedDetails(currRestrictionLayer.name(), 'geometry_y', 200)),
                                      dw, dh)

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

        self.closeCameras(dialog)
        # deal with issue whereby a null field provided by PayParkingAreaID is a 0 length string (rather than integer)

        if currFeatureLayer.name() == "Bays":
            try:
                if len (currFeature[currFeatureLayer.fields().indexFromName("PayParkingAreaID")].strip()) == 0:
                    currFeature[currFeatureLayer.fields().indexFromName("PayParkingAreaID")] = None
            except Exception as e:
                TOMsMessageLog.logMessage('onSaveFieldRestrictionDetails: dealing with PayParkingAreaID {}'.format(e),
                                          level=Qgis.Warning)
                
        attrs1 = currFeature.attributes()
        TOMsMessageLog.logMessage("In onSaveDemandDetails: currRestriction: " + str(attrs1),
                                 level=Qgis.Info)

        TOMsMessageLog.logMessage(
            ("In onSaveDemandDetails. geometry: " + str(currFeature.geometry().asWkt())),
            level=Qgis.Info)

        currFeatureID = currFeature.id()
        TOMsMessageLog.logMessage("In onSaveDemandDetails: currFeatureID: " + str(currFeatureID),
                                 level=Qgis.Info)

        status = currFeatureLayer.updateFeature(currFeature)
        TOMsMessageLog.logMessage("In onSaveDemandDetails: feature updated: " + str(currFeatureID),
                                 level=Qgis.Info)
        """if currFeatureID > 0:   # Not sure what this value should if the feature has not been created ...

            # TODO: Sort out this for UPDATE
            self.setDefaultRestrictionDetails(currFeature, currFeatureLayer)

            status = currFeatureLayer.updateFeature(currFeature)
            TOMsMessageLog.logMessage("In onSaveDemandDetails: updated Feature: ", level=Qgis.Info)
        else:
            status = currFeatureLayer.addFeature(currFeature)
            TOMsMessageLog.logMessage("In onSaveDemandDetails: added Feature: " + str(status), level=Qgis.Info)"""

        """
            save form location for reuse
        """
        self.storeLastUsedDetails(currFeatureLayer.name(), 'geometry_x', dialog.geometry().x())
        self.storeLastUsedDetails(currFeatureLayer.name(), 'geometry_y', dialog.geometry().y())

        status = dialog.attributeForm().close()
        TOMsMessageLog.logMessage("In onSaveDemandDetails: dialog saved: " + str(currFeatureID),
                                 level=Qgis.Info)
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

        self.closeCameras(restrictionDialog)

        currFeatureLayer.rollBack()

        """
            save form location for reuse
        """
        self.storeLastUsedDetails(currFeatureLayer.name(), 'geometry_x', restrictionDialog.geometry().x())
        self.storeLastUsedDetails(currFeatureLayer.name(), 'geometry_y', restrictionDialog.geometry().y())

        restrictionDialog.reject()

        #del self.mapTool

    def closeCameras(self, dialog=None):
        """
        Function to close cameras as cleanly as possible

        """
        try:
            self.camera1.close_camera()
            self.camera1.photoTaken.connect(functools.partial(self.savePhotoTaken, self.idx1))
        except Exception as e:
            TOMsMessageLog.logMessage('closeCameras: error disconnecting camera 1 {}'.format(e),
                                      level=Qgis.Warning)

        try:
            self.camera2.close_camera()
            self.camera2.photoTaken.connect(functools.partial(self.savePhotoTaken, self.idx2))
        except Exception as e:
            TOMsMessageLog.logMessage('closeCameras: error disconnecting camera 2 {}'.format(e),
                                      level=Qgis.Warning)

        try:
            self.camera3.close_camera()
            self.camera3.photoTaken.connect(functools.partial(self.savePhotoTaken, self.idx3))
        except Exception as e:
            TOMsMessageLog.logMessage('closeCameras: error disconnecting camera 3 {}'.format(e),
                                      level=Qgis.Warning)

        return

    def photoDetails_field(self, restrictionDialog, currRestrictionLayer, currRestriction):

        try:
            TOMsMessageLog.logMessage("In photoDetails_field {}:{} ... ".format(currRestrictionLayer.name(), currRestriction.attribute("RestrictionID")), level=Qgis.Warning)
        except Exception as e:
            TOMsMessageLog.logMessage('photoDetails_field: print error {}'.format(e),
                                      level=Qgis.Warning)

        try:
            TOMsMessageLog.logMessage("In photoDetails_field {}:{} ... ".format(currRestrictionLayer.name(), currRestriction.attribute("GeometryID")), level=Qgis.Warning)
        except Exception as e:
            TOMsMessageLog.logMessage('photoDetails_field: print error {}'.format(e),
                                      level=Qgis.Warning)
                                      
        # Function to deal with photo fields

        self.currFeature = currRestriction  ## need for SavePhotoTaken -- TODO: should try to change

        try:
            cameraNr = int(self.params.setParam("CameraNr"))
        except Exception as e:
            TOMsMessageLog.logMessage("In photoDetails_field: cameraNr issue: {}".format(e), level=Qgis.Warning)

        path_absolute = self.getPhotoPath()
        if path_absolute is None:
            return

        # get image resolution

        frameWidth, frameHeight = self.getCameraResolution()
        TOMsMessageLog.logMessage("In gnns: In photoDetails_field: ... resolution: {}*{} ".format(frameWidth, frameHeight), level=Qgis.Info)

        rotateCamera = False
        try:
            if int(self.params.setParam("rotateCamera")) > 0:
                rotateCamera = True
        except Exception as e:
            TOMsMessageLog.logMessage("In photoDetails_field: rotateCamera issue: {}".format(e), level=Qgis.Warning)

        TOMsMessageLog.logMessage("In photoDetails_field: cameraNr is: {}; rotate: {}".format(cameraNr, rotateCamera), level=Qgis.Info)

        fileName1 = "Photos_01"
        fileName2 = "Photos_02"
        fileName3 = "Photos_03"

        self.idx1 = currRestrictionLayer.fields().indexFromName(fileName1)
        self.idx2 = currRestrictionLayer.fields().indexFromName(fileName2)
        self.idx3 = currRestrictionLayer.fields().indexFromName(fileName3)

        TOMsMessageLog.logMessage("In photoDetails. idx1: " + str(self.idx1) + "; " + str(self.idx2) + "; " + str(self.idx3),
                                 level=Qgis.Info)

        if cameraNr is not None:
            TOMsMessageLog.logMessage("Camera TRUE", level=Qgis.Info)
            takePhoto = True
        else:
            TOMsMessageLog.logMessage("Camera FALSE", level=Qgis.Info)
            takePhoto = False

        camera1Tab = restrictionDialog.findChild(QWidget, "Photos_01")
        camera2Tab = restrictionDialog.findChild(QWidget, "Photos_02")
        camera3Tab = restrictionDialog.findChild(QWidget, "Photos_03")

        # Want to create a stacked widget with the viewer and the camera

        if camera1Tab:

            TOMsMessageLog.logMessage("In photoDetails. camera1Tab exists; photo1: {}".format(currRestriction.attribute("Photos_01")),
                                     level=Qgis.Warning)

            self.camera1 = TOMsCameraWidget()
            self.camera1.setupWidget(currRestriction.attribute("Photos_01"))
            camera1Layout = camera1Tab.layout()
            camera1Layout.addWidget(self.camera1)
            self.camera1.photoTaken.connect(functools.partial(self.savePhotoTaken, self.idx1))

        if camera2Tab:

            TOMsMessageLog.logMessage("In photoDetails. camera2Tab exists; photo2: {}".format(currRestriction.attribute("Photos_02")),
                                     level=Qgis.Warning)

            self.camera2 = TOMsCameraWidget()
            self.camera2.setupWidget(currRestriction.attribute("Photos_02"))
            camera2Layout = camera2Tab.layout()
            camera2Layout.addWidget(self.camera2)
            self.camera2.photoTaken.connect(functools.partial(self.savePhotoTaken, self.idx2))

        if camera3Tab:

            TOMsMessageLog.logMessage("In photoDetails. camera3Tab exists; photo3: {}".format(currRestriction.attribute("Photos_03")),
                                     level=Qgis.Warning)

            self.camera3 = TOMsCameraWidget()
            self.camera3.setupWidget(currRestriction.attribute("Photos_03"))
            camera3Layout = camera3Tab.layout()
            camera3Layout.addWidget(self.camera3)
            self.camera3.photoTaken.connect(functools.partial(self.savePhotoTaken, self.idx3))
            
        """
        Deal with exit from form by using x rather than "Accept/Reject". Need to ensure that cameras are closed
        """
        if takePhoto:
            try:
                restrictionDialog.finished.connect(functools.partial(self.closeCameras, restrictionDialog))
            except Exception as e:
                TOMsMessageLog.logMessage('photoDetails: error setting up close cameras: {}'.format(e),
                                          level=Qgis.Warning)

            # if coming from Demand
            try:
                restrictionDialog.destroyed.connect(functools.partial(self.closeCameras, restrictionDialog))
            except Exception as e:
                TOMsMessageLog.logMessage('photoDetails: error setting up close cameras: {}'.format(e),
                                          level=Qgis.Warning)
        pass

    def getPhotoPath(self):
        """ check that photo path exists """
        TOMsMessageLog.logMessage("In getPhotoPath", level=Qgis.Info)

        photoPath = QgsExpressionContextUtils.projectScope(QgsProject.instance()).variable('PhotoPath')

        projectFolder = QgsExpressionContextUtils.projectScope(QgsProject.instance()).variable('project_home')

        path_absolute = os.path.join(projectFolder, photoPath)

        if path_absolute == None:
            reply = QMessageBox.information(None, "Information", "Please set value for PhotoPath.", QMessageBox.Ok)
            return None

        # Check path exists ...
        if os.path.isdir(path_absolute) == False:
            reply = QMessageBox.information(None, "Information", "PhotoPath folder " + str(
                path_absolute) + " does not exist. Please check value.", QMessageBox.Ok)
            return None

        TOMsMessageLog.logMessage("In getPhotoPath. Returning {}".format(path_absolute), level=Qgis.Info)
        return path_absolute

    def getCameraResolution(self):
        TOMsConfigFileObject = TOMsConfigFile()
        TOMsConfigFileObject.initialiseTOMsConfigFile()
        frameWidth = TOMsConfigFileObject.getTOMsConfigElement('Camera', 'Width')
        frameHeight = TOMsConfigFileObject.getTOMsConfigElement('Camera', 'Height')
        if frameWidth is None or frameHeight is None:
            res = QMessageBox.information(None, "Information", "Please set value for camera resolution.", QMessageBox.Ok)
            return 0, 0
        return int(frameWidth), int(frameHeight)


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
        TOMsMessageLog.logMessage("In utils::displayPixmapUpdated ... ", level=Qgis.Info)
        FIELD.setPixmap(pixmap)
        FIELD.setScaledContents(True)
        QApplication.processEvents()  # processes the event queue - https://stackoverflow.com/questions/43094589/opencv-imshow-prevents-qt-python-crashing

    def displayImage(self, FIELD, pixmap):
        TOMsMessageLog.logMessage("In utils::displayImage ... ", level=Qgis.Info)

        try:
            FIELD.update_image(pixmap.scaled(FIELD.width(), FIELD.height(), QtCore.Qt.KeepAspectRatio,
                                                transformMode=QtCore.Qt.SmoothTransformation))
        except Exception as e:
            TOMsMessageLog.logMessage('displayImage: error {}'.format(e),
                                      level=Qgis.Warning)

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
                                 level=Qgis.Warning)
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
