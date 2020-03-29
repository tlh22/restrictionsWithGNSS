#-----------------------------------------------------------
# Licensed under the terms of GNU GPL 2
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#---------------------------------------------------------------------
# Tim Hancock/Matthias Kuhn 2017

from qgis.PyQt.QtCore import (
    QObject,
    QDate,
    pyqtSignal, pyqtSlot
)

from qgis.PyQt.QtWidgets import (
    QMessageBox,
    QAction
)

from qgis.core import (
    QgsExpressionContextUtils,
    # QgsMapLayerRegistry,
    QgsMessageLog, QgsFeature, QgsGeometry,
    QgsFeatureRequest,
    QgsProject, QgsRectangle
)

from ..restrictionTypeUtilsClass import RestrictionTypeUtilsMixin, TOMSLayers
from ..proposalTypeUtilsClass import ProposalTypeUtilsMixin
from ..constants import (
    ProposalStatus,
    RestrictionAction,
    singleton
)
from ..core.TOMsProposal import (TOMsProposal)
from .TOMsProposalElement import *

@singleton
class gpsManager(QObject):
    """
    Manages what is currently shown to the user.

     - Current date
     - Current proposal
    """


    gpsActivated = pyqtSignal()
    """ signal will be emitted when gps is activated"""


    def __init__(self, iface):

        QObject.__init__(self)
        #ProposalTypeUtilsMixin.__init__(self)

        self.tableNames = TOMSLayers(self.iface)
        #self.tableNames.TOMsLayersSet.connect(self.setRestrictionLayers)

        self.__date = QDate.currentDate()

        self.canvas = self.iface.mapCanvas()

        self.setGPStoolsActivated = False

        gpsTool = GPS(iface)
        iface.mapCanvas().setMapTool(gpsTool)

# https://gis.stackexchange.com/questions/307209/accessing-gps-via-pyqgis/339728#339728

