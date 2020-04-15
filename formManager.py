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
"""
from PyQt4.QtCore import (
    QObject,
    QDate,
    pyqtSignal,
    QCoreApplication
)

from PyQt4.QtGui import (
    QMessageBox,
    QAction,
    QIcon,
    QDialogButtonBox,
    QPixmap,
    QLabel
)

from qgis.core import (
    QgsExpressionContextUtils,
    QgsMapLayerRegistry,
    QgsMessageLog, QgsFeature, QgsGeometry
)

import os

from qgis.gui import *

from TOMs.CadNodeTool.TOMsNodeTool import TOMsNodeTool

from TOMs.mapTools import *
#from TOMsUtils import *
from TOMs.constants import (
    ACTION_CLOSE_RESTRICTION,
    ACTION_OPEN_RESTRICTION
)

from TOMs.restrictionTypeUtilsClass import RestrictionTypeUtilsMixin, TOMsTransaction, setupTableNames
#from BayRestrictionForm import BayRestrictionForm

import functools
"""

# https://www.opengis.ch/2016/09/07/using-threads-in-qgis-python-plugins/
# https://snorfalorpagus.net/blog/2013/12/07/multithreading-in-qgis-python-plugins/

# Initialize Qt resources from file resources.py
from .resources import *

from qgis.PyQt.QtCore import (
    QObject,
    QDate,
    pyqtSignal,
    QCoreApplication, pyqtSlot, QThread, QRect
)

from qgis.PyQt.QtGui import (
    QIcon,
    QPixmap, QColor, QFont
)

from qgis.PyQt.QtWidgets import (
    QMessageBox,
    QAction,
    QDialogButtonBox,
    QLabel,
    QDockWidget,
    QWidget,
    QHBoxLayout, QComboBox, QGroupBox, QFormLayout
)

from qgis.core import (
    QgsExpressionContextUtils,
    QgsProject,
    QgsMessageLog,
    QgsFeature,
    QgsGeometry,
    QgsApplication, QgsCoordinateTransform, QgsCoordinateReferenceSystem,
    QgsGpsDetector, QgsGpsConnection, QgsGpsInformation, QgsPoint, QgsPointXY
)

from qgis.gui import (
    QgsVertexMarker,
    QgsMapToolEmitPoint
)

import os, time
from abc import ABCMeta, abstractstaticmethod, abstractmethod

#from qgis.gui import *

# from .CadNodeTool.TOMsNodeTool import TOMsNodeTool
from .MTR_Restriction_dialog import MTR_RestrictionDialog
from .mapTools import CreateRestrictionTool, CreatePointTool
#from TOMsUtils import *

from .fieldRestrictionTypeUtilsClass import FieldRestrictionTypeUtilsMixin, TOMSLayers, gpsParams
from .SelectTool import GeometryInfoMapTool

import functools


class generateMTRForm(QObject):
    def __init__(self, iface, dbConn, currDialog):
        super().__init__()

        self.iface = iface
        self.currDialog = currDialog
        self.dbConn = dbConn

        QgsMessageLog.logMessage("In generateMTRForm::init", tag="TOMs panel")

        #self.font = QFont()
        #self.font.setPointSize(8)

        #self.generateForm()

    @abstractmethod
    def generateForm(self):
        #SELECT unnest(enum_range(NULL::"AccessRestrictionValue"))::text AS your_column
        pass

    @abstractmethod
    def setupNetworkReferenceCapture(self):
        pass

    def getEnumList(self, enum):

        typeList= []

        query = 'SELECT unnest(enum_range(NULL::"{}"))::text'.format(enum)
        QgsMessageLog.logMessage("In generateMTRForm::getEnumList. query is " + query, tag="TOMs panel")

        cursor = self.dbConn.cursor()
        cursor.execute(query)
        result = cursor.fetchall()

        for value, in result:
            typeList.append(value)

        return typeList


class combo(QWidget):
    def __init__(self, parent=None):
        super(combo, self).__init__(parent)

        layout = QHBoxLayout()
        self.cb = QComboBox(parent)

        font = QFont()
        font.setPointSize(10)
        self.cb.setFont(font)

        self.cb.setGeometry(QRect(50, 120, 200, 60))

        self.cb.addItem("C")
        self.cb.addItem("C++")
        self.cb.addItems(["Java", "C#", "Python"])
        self.cb.currentIndexChanged.connect(self.selectionchange)

        layout.addWidget(self.cb)
        self.setLayout(layout)
        #self.setWindowTitle("combo box demo")

    def selectionchange(self, i):
        QgsMessageLog.logMessage("Items in the list are :", tag="TOMs panel")

        for count in range(self.cb.count()):
            QgsMessageLog.logMessage(str(self.cb.itemText(count)), tag="TOMs panel")
        QgsMessageLog.logMessage("Current index" + str(i) + "selection changed " + self.cb.currentText(), tag="TOMs panel")

class generateFirstStageForm(generateMTRForm):
    def __init__(self, iface, dbConn, currDialog):
        super().__init__(iface, dbConn, currDialog)
        QgsMessageLog.logMessage("In factory. generateFirstStageForm ... ", tag="TOMs panel")
        #self.font = QFont()
        #self.font.setPointSize(12)
        #

    def generateForm(self):

        QgsMessageLog.logMessage("In generateFirstStageForm::generateForm ... ", tag="TOMs panel")

        mtrTypeLayout = self.currDialog.findChild(QFormLayout, "MTR_Type_Layout")
        mtrTypeCB = self.currDialog.findChild(QComboBox, "cmb_MTR_list")
        #groupBox = QGroupBox("Restriction Attributes", self.currDialog)
        #formLayout = QFormLayout()

        enumList = self.getEnumList('MT_RestrictionType')
        # Add access restriction type
        #lbl_accessRestrictionType = QLabel(self.currDialog)
        #lbl_accessRestrictionType.setText("Access Restriction Type:")

        #self.cb_accessRestrictionType = QComboBox(self.currDialog)
        #self.cb_accessRestrictionType.setFont(self.font)
        #self.cb_accessRestrictionType.setGeometry(QRect(100, 120, 200, 60))

        mtrTypeCB.addItems(enumList)


        #groupBox.setLayout(formLayout)

        #list = []
        #cb = combo(self.currDialog)

        # Add vehicle exemption

        # Add vehicle inclusions

        # add time intervals

        # add traffic sign

        # set up network reference capture


class generateAccessRestrictionForm(generateMTRForm):
    def __init__(self, iface, dbConn, currDialog):
        super().__init__(iface, dbConn, currDialog)
        QgsMessageLog.logMessage("In factory. generateAccessRestrictionForm ... ", tag="TOMs panel")
        #self.font = QFont()
        #self.font.setPointSize(12)
        #

    def generateForm(self):

        QgsMessageLog.logMessage("In generateAccessRestrictionForm::generateForm ... ", tag="TOMs panel")

        attributeLayout = self.currDialog.findChild(QFormLayout, "attributesFormLayout")
        #groupBox = QGroupBox("Restriction Attributes", self.currDialog)
        #formLayout = QFormLayout()

        # Add access restriction type
        #lbl_accessRestrictionType = QLabel(self.currDialog)
        #lbl_accessRestrictionType.setText("Access Restriction Type:")

        self.cb_accessRestrictionType = QComboBox(self.currDialog)
        #self.cb_accessRestrictionType.setFont(self.font)
        #self.cb_accessRestrictionType.setGeometry(QRect(100, 120, 200, 60))

        self.cb_accessRestrictionType.addItem("C")
        self.cb_accessRestrictionType.addItem("C++")
        self.cb_accessRestrictionType.addItems(["Java", "C#", "Python"])

        attributeLayout.addRow(self.tr("&Access Restriction Type:"), self.cb_accessRestrictionType)

        #groupBox.setLayout(formLayout)

        #list = []
        #cb = combo(self.currDialog)

        # Add vehicle exemption

        # Add vehicle inclusions

        # add time intervals

        # add traffic sign

        # set up network reference capture



class mtrFormFactory():

    @staticmethod
    def prepareForm(iface, db, currDialog, option=None):

        QgsMessageLog.logMessage("In mtrFormFactory. generateForm " + str(option), tag="TOMs panel")

        try:
            if option is None:
                return generateFirstStageForm(iface, db, currDialog).generateForm()
            elif option == 'AccessRestriction':
                return generateAccessRestrictionForm(iface, db, currDialog).generateForm()

            raise AssertionError("Option NOT found")

        except AssertionError as _e:
            QgsMessageLog.logMessage("In mtrFormFactory. TYPE not found or something else ... ", tag="TOMs panel")