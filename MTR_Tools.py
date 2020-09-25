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
    QMenu
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
    QgsWkbTypes, QgsProject,
    QgsRectangle, QgsFeature, QgsFeatureRequest, QgsGeometry
)

from qgis.gui import (
    QgsMapToolIdentify
)

#from .formUtils import demandFormUtils

from TOMs.core.TOMsMessageLog import TOMsMessageLog

#############################################################################

class getLinkDetailsMapTool(QgsMapToolIdentify):

    notifyLinkFound = pyqtSignal(QgsGeometry, QgsFeature, float)  # link feature and distance along link for point

    def __init__(self, iface):
        QgsMapToolIdentify.__init__(self, iface.mapCanvas())
        self.iface = iface

    def canvasReleaseEvent(self, event):
        # Return point under cursor

        QgsMessageLog.logMessage(("In Info - canvasReleaseEvent."), tag="TOMs panel")
        QgsMessageLog.logMessage(("In Info - canvasReleaseEvent." + str(event.pos())), tag="TOMs panel")
        self.event = event

        self.linkLayer = QgsProject.instance().mapLayersByName("OS_RAMI_RoadLink")[0]
        linkFeature = None
        distance = None
        nearestPt, linkFeature, distanceAlongLink = self.findNearestPointOnLink(event.pos())

        # If link is found, emit signal

        if linkFeature:
            QgsMessageLog.logMessage("In MTR::canvasReleaseEvent. Link found", tag="TOMs panel")
            self.notifyLinkFound.emit(nearestPt, linkFeature, distanceAlongLink)

    def transformCoordinates(self, screenPt):
        """ Convert a screen coordinate to map and layer coordinates.

            returns a (mapPt,layerPt) tuple.
        """
        return (self.toMapCoordinates(screenPt))

    def findNearestPointOnLink(self, pos):
        #  def findFeatureAt(self, pos, excludeFeature=None):
        # http://www.lutraconsulting.co.uk/blog/2014/10/17/getting-started-writing-qgis-python-plugins/ - generates "closest feature" function

        """ Find the feature close to the given position.

            'pos' is the position to check, in canvas coordinates.

            if 'excludeFeature' is specified, we ignore this feature when
            finding the clicked-on feature.

            If no feature is close to the given coordinate, we return None.
        """
        mapPt = self.transformCoordinates(pos)

        tolerance = 1.0
        searchRect = QgsRectangle(mapPt.x() - tolerance,
                                  mapPt.y() - tolerance,
                                  mapPt.x() + tolerance,
                                  mapPt.y() + tolerance)

        request = QgsFeatureRequest()
        request.setFilterRect(searchRect)
        request.setFlags(QgsFeatureRequest.ExactIntersect)

        shortestDistance = float("inf")
        closestFeature = None

        # Loop through all features in the layer to find the closest feature
        for f in self.linkLayer.getFeatures(request):

            dist = f.geometry().distance(QgsGeometry.fromPointXY(mapPt))
            if dist < shortestDistance:
                shortestDistance = dist
                closestFeature = f

        if closestFeature:
            # Find distance from start of feature
            distanceAlongLink = closestFeature.geometry().lineLocatePoint(QgsGeometry.fromPointXY(mapPt))
            nearestPt = closestFeature.geometry().nearestPoint(QgsGeometry.fromPointXY(mapPt))
            return nearestPt, closestFeature, distanceAlongLink

        return mapPt, None, None

