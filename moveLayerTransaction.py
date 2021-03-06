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

class MoveLayerTransaction(QObject):
    #transactionCompleted = pyqtSignal()
    """Signal will be emitted, when the transaction is finished - either committed or rollback"""

    def __init__(self, iface):

        QObject.__init__(self)

        self.iface = iface

        # self.currTransactionGroup = None
        self.currTransactionGroup = QgsTransactionGroup()
        self.setTransactionGroup = []
        self.TOMsTransactionList = []

    def prepareLayerSet(self, layerList):

        # Function to create group of layers to be in Transaction for changing proposal

        TOMsMessageLog.logMessage("In MoveLayerTransaction. prepareLayerSet: ", level=Qgis.Info)

        for layer in layerList:
            self.TOMsTransactionList.append(layer)

        for layer in self.TOMsTransactionList:
            self.setTransactionGroup.append(layer)
            TOMsMessageLog.logMessage("In MoveLayerTransaction.prepareLayerSet. Adding " + layer.name(), level=Qgis.Info)

        self.createTransactionGroup()

    def createTransactionGroup(self):

        TOMsMessageLog.logMessage("In MoveLayerTransaction.createTransactionGroup",
                                 level=Qgis.Info)

        if self.currTransactionGroup:

            for layer in self.setTransactionGroup:

                try:
                    self.currTransactionGroup.addLayer(layer)
                except Exception as e:
                    TOMsMessageLog.logMessage("In MoveLayerTransaction:createTransactionGroup: adding {}. error: {}".format(layer.name(), e), level=Qgis.Warning)

                TOMsMessageLog.logMessage("In MoveLayerTransaction:createTransactionGroup. Adding " + str(layer.name()), level=Qgis.Info)

                layer.raiseError.connect(functools.partial(self.printRaiseError, layer))

            self.modified = False
            self.errorOccurred = False

            #self.transactionCompleted.connect(self.proposalsManager.updateMapCanvas)

            return

    def startTransactionGroup(self):

        TOMsMessageLog.logMessage("In MoveLayerTransaction:startTransactionGroup.", level=Qgis.Info)

        if self.currTransactionGroup.isEmpty():
            TOMsMessageLog.logMessage("In MoveLayerTransaction:startTransactionGroup. Currently empty adding layers", level=Qgis.Info)
            self.createTransactionGroup()

        status = self.TOMsTransactionList[0].startEditing()  # could be any table ...
        if status == False:
            TOMsMessageLog.logMessage("In MoveLayerTransaction:startTransactionGroup. *** Error starting transaction ...", level=Qgis.Warning)
        else:
            TOMsMessageLog.logMessage("In MoveLayerTransaction:startTransactionGroup. Transaction started correctly!!! ...", level=Qgis.Warning)
        return status

    def layerModified(self):
        self.modified = True

    def isTransactionGroupModified(self):
        # indicates whether or not there has been any change within the transaction
        return self.modified

    def printMessage(self, layer, message):
        TOMsMessageLog.logMessage("In MoveLayerTransaction:printMessage. " + str(message) + " ... " + str(layer.name()),
                                 level=Qgis.Warning)

    def printAttribChanged(self, fid, idx, v):
        TOMsMessageLog.logMessage("MoveLayerTransaction: Attributes changed for feature " + str(fid),
                                 level=Qgis.Warning)

    def printRaiseError(self, layer, message):
        TOMsMessageLog.logMessage("MoveLayerTransaction: Error from " + str(layer.name()) + ": " + str(message),
                                 level=Qgis.Warning)
        self.errorOccurred = True
        self.errorMessage = message

    def commitTransactionGroup(self, currRestrictionLayer=None):

        TOMsMessageLog.logMessage("In MoveLayerTransaction:commitTransactionGroup",
                                 level=Qgis.Info)

        # unset map tool. I don't understand why this is required, but ... without it QGIS crashes
        currMapTool = self.iface.mapCanvas().mapTool()
        # currMapTool.deactivate()
        self.iface.mapCanvas().unsetMapTool(self.iface.mapCanvas().mapTool())
        self.mapTool = None

        if not self.currTransactionGroup:
            TOMsMessageLog.logMessage("In MoveLayerTransaction:commitTransactionGroup. Transaction DOES NOT exist",
                                     level=Qgis.Warning)
            return

        if self.errorOccurred == True:
            reply = QMessageBox.information(None, "Error",
                                            str(self.errorMessage), QMessageBox.Ok)
            self.rollBackTransactionGroup()
            return False

        for layer in self.setTransactionGroup:

            TOMsMessageLog.logMessage("In MoveLayerTransaction:commitTransactionGroup. Considering: " + layer.name(),
                                     level=Qgis.Info)

            commitStatus = layer.commitChanges()

            if commitStatus == False:
                reply = QMessageBox.information(None, "Error",
                                                "Changes to " + layer.name() + " failed: " + str(
                                                    layer.commitErrors()), QMessageBox.Ok)
                commitErrors = layer.rollBack()

            break

        self.modified = False
        self.errorOccurred = False

        # signal for redraw ...
        #self.transactionCompleted.emit()

        return commitStatus

    def layersInTransaction(self):
        return self.setTransactionGroup

    def errorInTransaction(self, errorMsg):
        reply = QMessageBox.information(None, "Error",
                                        "TOMsTransaction:Proposal changes failed: " + errorMsg, QMessageBox.Ok)
        TOMsMessageLog.logMessage("In errorInTransaction: " + errorMsg,
                                 level=Qgis.Warning)

    def deleteTransactionGroup(self):

        if self.currTransactionGroup:

            if self.currTransactionGroup.modified():
                TOMsMessageLog.logMessage("In MoveLayerTransaction:deleteTransactionGroup. Transaction contains edits ... NOT deleting",
                                         level=Qgis.Warning)
                return

            #self.currTransactionGroup.commitError.disconnect(self.errorInTransaction)
            self.currTransactionGroup = None

        return

    def rollBackTransactionGroup(self):

        TOMsMessageLog.logMessage("In MoveLayerTransaction:rollBackTransactionGroup",
                                 level=Qgis.Info)

        # unset map tool. I don't understand why this is required, but ... without it QGIS crashes
        self.iface.mapCanvas().unsetMapTool(self.iface.mapCanvas().mapTool())

        try:
            self.TOMsTransactionList[0].rollBack()  # could be any table ...
            TOMsMessageLog.logMessage("In MoveLayerTransaction:rollBackTransactionGroup. Transaction rolled back correctly ...",
                                     level=Qgis.Info)
        except:
            TOMsMessageLog.logMessage("In MoveLayerTransaction:rollBackTransactionGroup. error: ...",
                                     level=Qgis.Warning)

        self.modified = False
        self.errorOccurred = False
        self.errorMessage = None

        return
