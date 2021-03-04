# -----------------------------------------------------------
# Licensed under the terms of GNU GPL 2
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ---------------------------------------------------------------------
# Tim Hancock 2020

# https://stackoverflow.com/questions/48116698/zoom-qimage-on-qpixmap-in-qlabel
# to install - https://stackoverflow.com/questions/22528418/replace-qwidget-objects-at-runtime
# also ... https://stackoverflow.com/questions/35508711/how-to-enable-pan-and-zoom-in-a-qgraphicsview/35514531#35514531
# ... and https://stackoverflow.com/questions/20942586/controlling-the-pan-to-anchor-a-point-when-zooming-into-an-image

from PyQt5 import QtWidgets, QtCore, QtGui

from qgis.core import (
    Qgis,
    QgsMessageLog,
    QgsExpressionContextUtils
)
from TOMs.core.TOMsMessageLog import TOMsMessageLog

ZOOM_LIMIT = 10

class imageLabel(QtWidgets.QLabel):

    pixmapUpdated = QtCore.pyqtSignal(QtGui.QPixmap)

    def __init__(self, parent):
        TOMsMessageLog.logMessage("In imageLabel.init ... ", level=Qgis.Info)
        QtWidgets.QLabel.__init__(self, parent)
        self._empty = True
        self.top_left_corner = QtCore.QPoint(0, 0)
        self._displayed_pixmap = QtGui.QPixmap()

        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.MinimumExpanding, QtWidgets.QSizePolicy.MinimumExpanding)
        self.setScaledContents(True)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        self.setSizePolicy(sizePolicy)
        self.setAutoFillBackground(True)
        self.setMouseTracking(True)
        self.setGeometry(QtCore.QRect(0, 0, 600, 360))

    def set_Pixmap(self, image):
        TOMsMessageLog.logMessage("In imageLabel.set_Pixmap ... ", level=Qgis.Info)
        self.origImage = image
        self._zoom = 0
        if image and not image.isNull():
            self._empty = False
            TOMsMessageLog.logMessage("In imageLabel.setPixmap ... called update 1...", level=Qgis.Info)
            #self.update_image (image)
            self.update_image(self.origImage.scaled(self.width(), self.height(), QtCore.Qt.KeepAspectRatio,
                                                    transformMode=QtCore.Qt.SmoothTransformation))
            TOMsMessageLog.logMessage("In imageLabel.setPixmap ... called update 2...", level=Qgis.Info)

    """def setPixmap(self, image):
        TOMsMessageLog.logMessage("In imageLabel.setPixmap ... ", level=Qgis.Info)
        self.top_left_corner = QtCore.QPoint(0, 0)
        self._displayed_pixmap = image.scaled(self.width(), self.height(), QtCore.Qt.KeepAspectRatio,
                                                    transformMode=QtCore.Qt.SmoothTransformation)
        super().setPixmap(image)"""

    def hasPhoto(self):
        return not self._empty

    def wheelEvent(self, event):
        TOMsMessageLog.logMessage("In imageLabel.wheelEvent ... new ", level=Qgis.Info)
        super(imageLabel, self).wheelEvent(event)

        modifiers = QtWidgets.QApplication.keyboardModifiers()

        if modifiers == QtCore.Qt.ControlModifier:  # need to hold down Ctl and use the wheel for the zoom to take effect

            if self.hasPhoto() and abs(self._zoom) < ZOOM_LIMIT:
                TOMsMessageLog.logMessage("In imageLabel.wheelEvent ... acting ", level=Qgis.Info)
                if event.angleDelta().y() > 0:
                    TOMsMessageLog.logMessage("In imageLabel.wheelEvent ... zooming in ", level=Qgis.Info)
                    self.factor = 1.25
                    self._zoom += 1
                else:
                    TOMsMessageLog.logMessage("In imageLabel.wheelEvent ... zooming out ", level=Qgis.Info)
                    self.factor = 0.8
                    self._zoom -= 1

                self.screenpoint = self.mapFromGlobal(QtGui.QCursor.pos())
                self.curr_x, self.curr_y = self.screenpoint.x(), self.screenpoint.y()

                self._zoomActivity()

    def mousePressEvent(self, event):
        self.pixMapCentre = event.pos()
        TOMsMessageLog.logMessage(
            "In imageLabel.pressEvent ... pressed {}:{}. ".format(self.pixMapCentre.x(), self.pixMapCentre.y()),
            level=Qgis.Info)

        if event.button() == QtCore.Qt.LeftButton:
            TOMsMessageLog.logMessage("In imageLabel.pressEvent ... zooming in ", level=Qgis.Info)
            self.factor = 1.25
            self._zoom += 1
        else:
            TOMsMessageLog.logMessage("In imageLabel.pressEvent ... zooming out ", level=Qgis.Info)
            self.factor = 0.8
            self._zoom -= 1

        self.screenpoint = self.mapFromGlobal(QtGui.QCursor.pos())
        self.curr_x, self.curr_y = self.screenpoint.x(), self.screenpoint.y()

        self._zoomActivity()

    def _zoomInButton(self):
        TOMsMessageLog.logMessage("In imageLabel.wheelEvent ... acting ", level=Qgis.Info)
        if self.hasPhoto() and abs(self._zoom) < ZOOM_LIMIT:

            TOMsMessageLog.logMessage("In imageLabel._zoomInButton ... zooming in ", level=Qgis.Info)
            self.factor = 1.25
            self._zoom += 1

            image_size = self._displayed_pixmap.size()
            self.curr_x, self.curr_y = image_size.width() / 2, image_size.height() / 2

            self._zoomActivity()

    def _zoomOutButton(self):

        TOMsMessageLog.logMessage("In imageLabel.wheelEvent ... acting ", level=Qgis.Info)
        if self.hasPhoto() and abs(self._zoom) < ZOOM_LIMIT:

            TOMsMessageLog.logMessage("In imageLabel._zoomInButton ... zooming in ", level=Qgis.Info)
            self.factor = 0.8
            self._zoom -= 1

            image_size = self._displayed_pixmap.size()
            self.curr_x, self.curr_y = image_size.width() / 2, image_size.height() / 2

            self._zoomActivity()

    def _zoomActivity(self):

        if abs(self._zoom) < ZOOM_LIMIT:

            image_size = self._displayed_pixmap.size()
            TOMsMessageLog.logMessage(
                "In imageLabel.wheelEvent ... dimensions {}:{}. Resized to {}:{} ".format(image_size.width(),
                                                                                          image_size.height(),
                                                                                          image_size.width() * self.factor,
                                                                                          image_size.height() * self.factor),
                level=Qgis.Info)
            if (self._zoom) == 0:
                image_size.setWidth(image_size.width())
                image_size.setHeight(image_size.height())
            else:
                image_size.setWidth(image_size.width() * self.factor)
                image_size.setHeight(image_size.height() * self.factor)

            TOMsMessageLog.logMessage(
                "In imageLabel.wheelEvent ... zoom:factor {}:{}".format(self._zoom, self.factor),
                level=Qgis.Info)
            TOMsMessageLog.logMessage(
                "In imageLabel.wheelEvent ... screenpoint {}:{}".format(self.curr_x, self.curr_y),
                level=Qgis.Info)

            if self._zoom == 0:
                self.top_left_corner.setX(0)
                self.top_left_corner.setY(0)
            else:
                self.top_left_corner.setX(self.top_left_corner.x() * self.factor + self.curr_x - (self.curr_x * self.factor))
                self.top_left_corner.setY(self.top_left_corner.y() * self.factor + self.curr_y - (self.curr_y * self.factor))

            TOMsMessageLog.logMessage(
                "In imageLabel.zoom ... tl new 2 {}:{}".format(self.top_left_corner.x(),
                                                                     self.top_left_corner.y()),
                level=Qgis.Info)

            self.update_image(self.origImage.scaled(image_size, QtCore.Qt.KeepAspectRatio,
                                                    transformMode=QtCore.Qt.SmoothTransformation))

            TOMsMessageLog.logMessage("In imageLabel.setPixmap ... called update zoom...", level=Qgis.Info)

        else:
            if self._zoom > 0:
                self._zoom -= 1
            else:
                self._zoom += 1

    def update_image(self, image):
        self._displayed_pixmap = image
        self.pixmapUpdated.emit(self._displayed_pixmap)

    def paintEvent(self, paint_event):
        TOMsMessageLog.logMessage("In imageLabel::paintEvent ... ", level=Qgis.Info)
        #super().paintEvent(paint_event)
        painter = QtGui.QPainter(self)

        painter.drawPixmap(self.top_left_corner.x(), self.top_left_corner.y(), self._displayed_pixmap)
        #painter.drawPixmap(self.top_left_corner.x(), self.top_left_corner.y(), self._displayed_pixmap.scaled(self.width(), self.height()))
