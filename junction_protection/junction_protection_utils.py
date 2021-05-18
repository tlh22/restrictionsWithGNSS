#-----------------------------------------------------------
# Licensed under the terms of GNU GPL 2
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#---------------------------------------------------------------------
# Tim Hancock 2021

import os.path
import sys
sys.path.append(os.path.dirname(os.path.realpath(__file__)))

from qgis.PyQt.QtCore import (
    QObject,
    QDate,
    pyqtSignal
)

from qgis.PyQt.QtWidgets import (
    QMessageBox
)

from TOMs.core.TOMsMessageLog import TOMsMessageLog
from qgis.core import (
    Qgis,
    QgsExpressionContextUtils,
    QgsMessageLog,
    QgsFeature,
    QgsGeometry, QgsGeometryUtils,
    QgsFeatureRequest,
    QgsPoint,
    QgsPointXY,
    QgsRectangle,
    QgsVectorLayer,
    QgsProject,
    QgsWkbTypes
)

# from qgis.core import *
# from qgis.gui import *
from qgis.utils import iface

from TOMs.generateGeometryUtils import generateGeometryUtils
#from TOMs.core.TOMsGeometryElement import ElementGeometryFactory

import math
from cmath import rect, phase

class junctionProtectionUtils (QObject):

    @staticmethod
    def getHaveringMapscaleLookup(mapScaleID):
        TOMsMessageLog.logMessage("In getHaveringMapscaleLookup. Checking {}".format(mapScaleID), level=Qgis.Warning)
        HaveringMapFramesAllowableScales = QgsProject.instance().mapLayersByName("HaveringMapFramesAllowableScales")[0]
        mapScale = generateGeometryUtils.getLookupDescription(HaveringMapFramesAllowableScales,
                                                              mapScaleID)
        if mapScale:
            return mapScale
        return None

