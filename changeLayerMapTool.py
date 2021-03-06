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
    QMenu, QInputDialog
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
    QgsMapLayer,
    Qgis, QgsRectangle, QgsFeatureRequest, QgsVectorLayer,
    QgsFeature, QgsProject, QgsMapLayerType, QgsTransactionGroup,
    QgsGeometry
)
from qgis.gui import (
    QgsMapToolIdentify
)
#from qgis.core import *
#from qgis.gui import *
from TOMs.core.TOMsMessageLog import TOMsMessageLog
from .fieldRestrictionTypeUtilsClass import FieldRestrictionTypeUtilsMixin, gpsParams
from .SelectTool import GeometryInfoMapTool

from TOMs.restrictionTypeUtilsClass import TOMsLayers, TOMsConfigFile
from TOMs.core.TOMsTransaction import TOMsTransaction
from TOMs.restrictionTypeUtilsClass import (originalFeature)
import functools
import uuid
#from .formUtils import demandFormUtils

#############################################################################

class ChangeLayerMapTool(GeometryInfoMapTool):

    def __init__(self, iface, localTransactionGroup):
        GeometryInfoMapTool.__init__(self, iface)
        self.iface = iface
        self.localTransactionGroup = localTransactionGroup

    def canvasReleaseEvent(self, event):
        # Return point under cursor

        self.event = event

        closestFeature, closestLayer = self.findNearestFeatureAtC(event.pos())

        TOMsMessageLog.logMessage(("In ChangeLayerMapTool.canvasReleaseEvent."), level=Qgis.Info)

        # Remove any current selection and add the new ones (if appropriate)

        if closestLayer == None:

            if self.iface.activeLayer():
                self.iface.activeLayer().removeSelection()

        else:

            TOMsMessageLog.logMessage(("In ChangeLayerMapTool.canvasReleaseEvent. Feature selected from layer: " + closestLayer.name() + " id: " + str(
                    closestFeature.id())), level=Qgis.Info)

            if not closestLayer == self.iface.activeLayer():
                if self.iface.activeLayer():
                    self.iface.activeLayer().removeSelection()
                self.iface.setActiveLayer(closestLayer)

            if closestLayer.type() == QgsMapLayer.VectorLayer:
                TOMsMessageLog.logMessage(("In ChangeLayerMapTool.canvasReleaseEvent. layer type " + str(closestLayer.type())),
                                         level=Qgis.Info)

            if closestLayer.geometryType() == QgsWkbTypes.PointGeometry:
                TOMsMessageLog.logMessage(("In ChangeLayerMapTool.canvasReleaseEvent. point layer type "), level=Qgis.Info)

            if closestLayer.geometryType() == QgsWkbTypes.LineGeometry:
                TOMsMessageLog.logMessage(("In ChangeLayerMapTool.canvasReleaseEvent. line layer type "), level=Qgis.Info)

            status = self.changeLayerForFeature(closestLayer, closestFeature)

            TOMsMessageLog.logMessage(("In ChangeLayerMapTool.canvasReleaseEvent. status: {}".format(status)), level=Qgis.Info)


    def changeLayerForFeature(self, currLayer, currFeature):

        status = False

        sameGeomTypeLayerList = self.getSameGeomTypeLayerList(currLayer, currFeature)

        TOMsMessageLog.logMessage("In setNewLayerForFeature: sameGeomTypeLayerList: {}".format(sameGeomTypeLayerList), level=Qgis.Info)

        surveyDialog = QInputDialog()
        surveyDialog.setLabelText("Please confirm new layer for this feature ")
        surveyDialog.setComboBoxItems(sameGeomTypeLayerList)
        surveyDialog.setTextValue(currLayer.name())

        if surveyDialog.exec_() == QDialog.Accepted:
            newLayerName = surveyDialog.textValue()
            TOMsMessageLog.logMessage("In setNewLayerForFeature: {}".format(newLayerName), level=Qgis.Info)

            if currLayer.name() != newLayerName:
                newLayer = QgsProject.instance().mapLayersByName(newLayerName)[0]
                reply = QMessageBox.information(None, "Information", "Setting {} to layer {}".format(currFeature.attribute("GeometryID"), newLayer.name()),
                                            QMessageBox.Ok)

                status = self.moveFeatureToNewLayer(currLayer, currFeature, newLayer)

        return status

    def getSameGeomTypeLayerList(self, currLayer, currFeature):

        sameGeomTypeLayerList = list()

        layerList = QgsProject.instance().mapLayers().values()
        currGeomType = currFeature.geometry().type()

        for layer in layerList:
            if layer.type() == QgsMapLayerType.VectorLayer:
                if layer.geometryType() == currLayer.geometryType():
                    sameGeomTypeLayerList.append(layer.name())

        return sorted(sameGeomTypeLayerList)

    def moveFeatureToNewLayer(self, currLayer, currFeature, newLayer):

        # generate transaction ...
        self.localTransactionGroup.prepareLayerSet([currLayer, newLayer])
        self.localTransactionGroup.startTransactionGroup()

        newLayerProvider = newLayer.dataProvider()
        newLayerFields = newLayerProvider.fields()
        newFeatureEmpty = QgsFeature(newLayerFields)

        newFeature = self.copyRestriction(currFeature, newFeatureEmpty)

        if newFeature:
            # add new feature - and delete original

            currLayer.deleteFeature(currFeature.id())

            dialog = self.iface.getFeatureForm(newLayer, newFeature)
            status = self.setupMoveRestrictionDialog(dialog, newLayer, newFeature)

            if status:
                dialog.show()


    def setupMoveRestrictionDialog(self, restrictionDialog, currRestrictionLayer, currRestriction):

        self.params.getParams()

        # Create a copy of the feature
        self.origFeature = originalFeature()
        self.origFeature.setFeature(currRestriction)

        if restrictionDialog is None:
            reply = QMessageBox.information(None, "Error",
                                            "setupMoveRestrictionDialog. Correct form not found. Rolling back",
                                            QMessageBox.Ok)
            TOMsMessageLog.logMessage(
                "In setupRestrictionDialog. dialog not found",
                level=Qgis.Warning)
            self.localTransactionGroup.rollBackTransactionGroup()
            return False

        restrictionDialog.attributeForm().disconnectButtonBox()
        button_box = restrictionDialog.findChild(QDialogButtonBox, "button_box")

        if button_box is None:
            reply = QMessageBox.information(None, "Error",
                                            "setupMoveRestrictionDialog. Problem with form. Rolling back",
                                            QMessageBox.Ok)
            TOMsMessageLog.logMessage(
                "In setupRestrictionDialog. button box not found",
                level=Qgis.Warning)
            self.localTransactionGroup.rollBackTransactionGroup()
            return False

        button_box.accepted.connect(functools.partial(self.onSaveMoveRestrictionDetails, currRestriction,
                                      currRestrictionLayer, restrictionDialog))

        button_box.rejected.connect(functools.partial(self.onRejectMoveRestrictionDetailsFromForm, restrictionDialog, currRestrictionLayer))

        restrictionDialog.attributeForm().attributeChanged.connect(functools.partial(self.onAttributeChangedClass2_local, currRestriction, currRestrictionLayer))

        self.photoDetails_field(restrictionDialog, currRestrictionLayer, currRestriction)

        self.addScrollBars(restrictionDialog)

        return True

    def onSaveMoveRestrictionDetails(self, currFeature, currFeatureLayer, dialog):
        TOMsMessageLog.logMessage("In onSaveMoveRestrictionDetails: ", level=Qgis.Info)

        try:
            self.camera1.endCamera()
            self.camera2.endCamera()
            self.camera3.endCamera()
        except:
            None

        # deal with issue whereby a null field provided by PayParkingAreaID is a 0 length string (rather than integer)

        if currFeatureLayer.name() == "Bays":
            try:
                if len(currFeature[currFeatureLayer.fields().indexFromName("PayParkingAreaID")].strip()) == 0:
                    currFeature[currFeatureLayer.fields().indexFromName("PayParkingAreaID")] = None
            except:
                None

        currFeatureID = currFeature.id()

        status = currFeatureLayer.addFeature(currFeature)

        TOMsMessageLog.logMessage("In onSaveMoveRestrictionDetails: feature added: {}: status: {}".format(currFeatureID, status),
                                  level=Qgis.Info)

        status = dialog.attributeForm().close()
        TOMsMessageLog.logMessage("In onSaveMoveRestrictionDetails: dialog saved: " + str(currFeatureID),
                                  level=Qgis.Info)
        # currRestrictionLayer.addFeature(currRestriction)  # TH (added for v3)
        # status = currFeatureLayer.updateFeature(currFeature)  # TH (added for v3)

        try:
            self.localTransactionGroup.commitTransactionGroup()
        except Exception as e:
            reply = QMessageBox.information(None, "Information", "Problem committing changes: {}".format(e),
                                            QMessageBox.Ok)

        # currFeatureLayer.blockSignals(False)

        TOMsMessageLog.logMessage("In onSaveDemandDetails: changes committed", level=Qgis.Info)

        status = dialog.close()

    def onRejectMoveRestrictionDetailsFromForm(self, restrictionDialog, currFeatureLayer):
        TOMsMessageLog.logMessage("In onRejectFieldRestrictionDetailsFromForm", level=Qgis.Info)

        try:
            self.camera1.endCamera()
            self.camera2.endCamera()
            self.camera3.endCamera()
        except:
            None

        self.localTransactionGroup.rollBackTransactionGroup()

        status = restrictionDialog.reject()

    def copyRestriction(self, currFeature, newFeature):

        TOMsMessageLog.logMessage("In TOMsNodeTool:copyRestriction",
                                 level=Qgis.Info)

        newFeatureFieldMap = newFeature.fields()
        currFeatureFieldMap = currFeature.fields()

        for field in newFeature.fields():

            fieldName = field.name()
            idx_newFeature = newFeatureFieldMap.indexFromName(field.name())
            # see if can find same field name ... adn set
            idx_currFeature = currFeatureFieldMap.indexFromName(fieldName)
            if idx_currFeature >= 0:
                if not newFeature.setAttribute(idx_newFeature, currFeature.attribute(idx_currFeature)):
                    reply = QMessageBox.information(None, "Information", "Problem adding: {}".format(field.name()),
                                                    QMessageBox.Ok)
                    return None
        # set new restriction id and geometry id
        newRestrictionID = str(uuid.uuid4())
        idxRestrictionID = newFeature.fields().indexFromName("RestrictionID")
        newFeature[idxRestrictionID] = newRestrictionID

        idxGeometryID = newFeature.fields().indexFromName("GeometryID")
        newFeature[idxGeometryID] = None

        # copy geometry ...
        newFeature.setGeometry(QgsGeometry(currFeature.geometry()))

        return newFeature
