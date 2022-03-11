# -----------------------------------------------------------
# Licensed under the terms of GNU GPL 2
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ---------------------------------------------------------------------
# Tim Hancock 2017
"""
Adapted from http://nathanw.net/2011/09/05/qgis-tips-custom-feature-forms-with-python-logic/

and also ...

https://gis.stackexchange.com/questions/144427/how-to-display-a-picture-in-qgis-custom-form

https://stackoverflow.com/questions/44404349/pyqt-showing-video-stream-from-opencv

"""

# DEBUGMODE = True

from qgis.PyQt.QtWidgets import (
    QMessageBox,
    QAction,
    QDialogButtonBox,
    QLabel,
    QDockWidget,
    QPushButton, QApplication
)

from qgis.PyQt.QtGui import (
    QIcon,
    QPixmap, QImage
)

from qgis.PyQt.QtCore import (
    QObject,
    QTimer,
    pyqtSignal, pyqtSlot,
    QThread
)

from TOMs.core.TOMsMessageLog import TOMsMessageLog
from TOMs.ui.TOMsCamera import (formCamera)
from TOMs.restrictionTypeUtilsClass import (TOMsLayers, originalFeature, RestrictionTypeUtilsMixin)
from restrictionsWithGNSS.fieldRestrictionTypeUtilsClass import (FieldRestrictionTypeUtilsMixin, gpsParams)

from qgis.core import (
    QgsMessageLog,
    QgsExpressionContextUtils
)

import sys, os, ntpath
import numpy as np
# import cv2
import functools
import datetime
import time

try:
    import cv2
    cv2_available = True
except ImportError:
    print('cv2 not available ...')
    QgsMessageLog.logMessage("Not able to import cv2 ...", tag="TOMs panel")
    cv2_available = False


# from demandFormUtils import cvCamera

def formOpen_CountDemand(dialog, layer, feature):
    """
    Code that runs when the form is opened.
    """

    if not feature.isValid():
        #reply = QMessageBox.information(None, "Information", "Invalid feature", QMessageBox.Ok)
        return

    if layer.startEditing() == False:
        #reply = QMessageBox.information(None, "Information", "Could not start transaction", QMessageBox.Ok)
        pass
        
    iface = qgis.utils.iface
    utils = demandFormUtils(iface)

    utils.setupDemandDialog(dialog, layer, feature)


class demandFormUtils(FieldRestrictionTypeUtilsMixin):

    def __init__(self, iface):

        self.iface = iface

        FieldRestrictionTypeUtilsMixin.__init__(self, iface)


    def setupDemandDialog(self, demandDialog, currDemandLayer, currFeature):

        self.params.getParams()
        # self.restrictionDialog = restrictionDialog
        self.demandDialog = demandDialog
        self.currDemandLayer = currDemandLayer
        self.currFeature = currFeature
        # self.restrictionTransaction = restrictionTransaction

        if self.demandDialog is None:
            QgsMessageLog.logMessage(
                "In setupDemandDialog. dialog not found",
                tag="TOMs panel")

        button_box = self.demandDialog.findChild(QDialogButtonBox, "button_box")

        if button_box is None:
            QgsMessageLog.logMessage(
                "In setupDemandDialog. button box not found",
                tag="TOMs panel")
            reply = QMessageBox.information(None, "Information", "Please reset form. There are missing buttons",
                                            QMessageBox.Ok)
            return

        self.demandDialog.disconnectButtonBox()
        try:
            button_box.accepted.disconnect()
        except:
            None

        button_box.accepted.connect(functools.partial(self.onSaveDemandDetails, currFeature,
                                                      currDemandLayer, self.demandDialog))

        try:
            button_box.rejected.disconnect()
        except:
            None

        button_box.rejected.connect(self.onRejectDemandDetailsFromForm)

        self.demandDialog.attributeChanged.connect(
            functools.partial(self.onAttributeChangedClass2, self.currFeature, self.currDemandLayer))

        QgsMessageLog.logMessage("In setupDemandDialog. BEFORE PHOTOS: ", tag="TOMs panel")
                
        self.photoDetails_field(demandDialog, currDemandLayer, currFeature)

    def onSaveDemandDetails(self, currFeature, currFeatureLayer, dialog):
        QgsMessageLog.logMessage("In onSaveDemandDetails: ", tag="TOMs panel")

        self.closeCameras(dialog)

        status = currFeatureLayer.updateFeature(currFeature)
        # status = dialog.save()

        if currFeatureLayer.commitChanges() == False:
            reply = QMessageBox.information(None, "Information",
                                            "Problem committing changes" + str(currFeatureLayer.commitErrors()),
                                            QMessageBox.Ok)
        else:
            QgsMessageLog.logMessage("In onSaveDemandDetails: changes committed", tag="TOMs panel")

    def onRejectDemandDetailsFromForm(self):
        QgsMessageLog.logMessage("In onRejectDemandDetailsFromForm", tag="TOMs panel")
        # self.currDemandLayer.destroyEditCommand()

        self.closeCameras(self.demandDialog)

        if self.currDemandLayer.rollBack() == False:
            reply = QMessageBox.information(None, "Information", "Problem rolling back changes", QMessageBox.Ok)
        else:
            QgsMessageLog.logMessage("In onRejectDemandDetailsFromForm: rollBack successful ...", tag="TOMs panel")

        # self.demandDialog.reject()
        self.demandDialog.close()

    def onAttributeChangedClass2(self, currFeature, layer, fieldName, value):
        """QgsMessageLog.logMessage(
            "In FormOpen:onAttributeChangedClass 2 - layer: " + str(layer.name()) + " (" + fieldName + "): " + str(
                value), tag="TOMs panel")"""

        # self.currFeature.setAttribute(fieldName, value)
        try:

            currFeature[layer.fields().indexFromName(fieldName)] = value

        except:

            reply = QMessageBox.information(None, "Error",
                                            "onAttributeChangedClass2. Update failed for: " + str(
                                                layer.name()) + " (" + fieldName + "): " + str(value),
                                            QMessageBox.Ok)  # rollback all changes
        return

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