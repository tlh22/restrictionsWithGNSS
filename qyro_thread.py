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

# https://www.opengis.ch/2016/09/07/using-threads-in-qgis-python-plugins/
# https://snorfalorpagus.net/blog/2013/12/07/multithreading-in-qgis-python-plugins/

from qgis.PyQt.QtCore import (
    QObject,
    QDate,
    pyqtSignal,
    QCoreApplication, pyqtSlot, QThread
)

from qgis.PyQt.QtGui import (
    QIcon,
    QPixmap, QColor
)

from qgis.PyQt.QtWidgets import (
    QMessageBox,
    QAction,
    QDialogButtonBox,
    QLabel,
    QDockWidget, QComboBox, QActionGroup
)

from qgis.core import (
    Qgis,
    QgsExpressionContextUtils,
    QgsProject,
    QgsMessageLog,
    QgsFeature,
    QgsGeometry,
    QgsApplication, QgsCoordinateTransform, QgsCoordinateReferenceSystem,
    QgsGpsDetector, QgsGpsConnection, QgsGpsInformation, QgsPoint, QgsPointXY,
    QgsDataSourceUri
)

from qgis.gui import (
    QgsVertexMarker,
    QgsMapToolEmitPoint
)

from TOMs.core.TOMsMessageLog import TOMsMessageLog
import os, time
import serial, io

class gyro_Thread(QObject):

    #https://gis.stackexchange.com/questions/307209/accessing-gps-via-pyqgis

    gyroActivated = pyqtSignal(QgsGpsConnection)
    """ signal will be emitted when gyro is activated"""
    gyroDeactivated = pyqtSignal()
    gyroError = pyqtSignal(Exception)
    gyroPosition = pyqtSignal(object, object)

    def __init__(self, dest_crs, gyroPort):
        #self.prj=QgsProject().instance()
        #self.connectionRegistry = QgsApplication.gpsConnectionRegistry()
        super(gyro_Thread, self).__init__()
        try:
            self.gyro_active = False
            # set up transformation
            #self.dest_crs = self.prj.crs()
            #self.transformation = QgsCoordinateTransform(QgsCoordinateReferenceSystem("EPSG:4326"), self.dest_crs,
                                                         QgsProject.instance())
            #self.gpsCon = None

            TOMsMessageLog.logMessage("In Gyro_Thread.__init__ - initialised ... ",
                                     level=Qgis.Info)
            self.retry_attempts = 0
        except Exception as e:
            TOMsMessageLog.logMessage(("In GPS_Thread.__init__ - exception: " + str(e)), level=Qgis.Warning)
            self.gyroError.emit(e)

        self.gyroPort = gyroPort

    def startGyro(self):

        try:
            TOMsMessageLog.logMessage("In GPS_Thread.startGPS - running ... ",
                                     level=Qgis.Info)
            #self.gpsCon = None
            #self.port = "COM3"  # TODO: Add menu to select port
            #self.gpsDetector = QgsGpsDetector(self.gyroPort)
            #self.gpsDetector.detected[QgsGpsConnection].connect(self.connection_succeed)
            #self.gpsDetector.detectionFailed.connect(self.connection_failed)


            #self.serialport = serial.Serial()
            #self.serialport.port = self.gyroPort
            #self.serialport.baudrate = 9600

            self.serialport = serial.serial_for_url(self.gyroPort, timeout=1)
            sio = io.TextIOWrapper(io.BufferedRWPair(self.serialport, self.serialport))
            self.serialport.baudrate = 115200
            self.serialport.timeout = 10
            #self.serialport.parity = serial.PARITY_NONE
            #self.serialport.stopbits = serial.STOPBITS_ONE
            #self.serialport.bytesize = serial.EIGHTBITS

            self.serialport.open()
            #self.gpsDetector.advance()

        except Exception as e:
            TOMsMessageLog.logMessage(("In GPS_Thread.startGPS - exception: " + str(e)),
                                     level=Qgis.Warning)
            self.gyroError.emit(e)

    def endGPS(self):
        TOMsMessageLog.logMessage(("In GPS_Thread.endGPS ...."),
                                  level=Qgis.Warning)
        self.gyro_active = False

        # shutdown the receiver
        self.serialport.close()
        #if self.gpsCon is not None:
        #    self.gpsCon.close()
        TOMsMessageLog.logMessage(("In gryo_Thread.status_changed - deactivating gyro ... "),
                                  level=Qgis.Warning)
        #self.connectionRegistry.unregisterConnection(self.gpsCon)
        self.gyroDeactivated.emit()

    def connection_succeed(self, connection):
        try:
            TOMsMessageLog.logMessage(("In GPS_Thread.connection_succeed - GPS connected ...."),
                                     level=Qgis.Warning)
            self.gyro_active = True
            #self.gpsCon = connection
            #self.connectionRegistry.registerConnection(connection)
            #self.gyroActivated.emit(connection)

            #self.gpsCon.stateChanged.connect(self.status_changed)

        except Exception as e:
            TOMsMessageLog.logMessage(("In GPS_Thread.connection_succeed - exception: " + str(e)),
                                     level=Qgis.Warning)
            self.gyroError.emit(e)

            """while self.gps_active:
            TOMsMessageLog.logMessage(
                "In GPS_Thread:connection_succeed: checking status ... {}".format(self.attempts),
                level=Qgis.Warning)
            time.sleep(1.0)
            self.attempts = self.attempts + 1
            if self.attempts > 5:
                TOMsMessageLog.logMessage(
                    ("In GPS_Thread:status_changed: problem receiving gnss position ... exiting ... "),
                    level=Qgis.Warning)
                self.endGPS()"""

    def getDataPacket(self):

        # for this device, the packet header is hex55
        thisPacket = []
        readingPacket = True
        while readingPacket is True:
            b = self.serialport.read(1)

            if b.hex() == 55:
                readingPacket = False
            else:
                thisPacket = thisPacket.append(b)

        return thisPacket

    def readData(self):
        # read data from device - and interpret ...
        keepOnReading = True

        try:
            while keepOnReading:

                thisPacket = self.getDataPacket()
                if len(thisPacket == 0):
                    keepOnReading is False
                    break
                # source - ...
                # Assuming the packet data is for acceleration, angular velocity and angle Data
                # (Ignoring the packet header and flag bit)
                hex_data = [ord(el) for el in thisPacket[2:]]
                # It is requirement of the manufacturer to cast all values to signed short values,
                # but python doesnt have this data type, thats why the following transformation exists
                transformed_hex_values = [val if val <= 127 else (256 - val) * -1 for val in hex_data]
                for i in range(0, 3):
                    if i == 0:
                        # "Acceleration"
                        self.ax = float(
                            (int(transformed_hex_values[i + 1]) << 8) | (int(transformed_hex_values[i]) & 255)) / 32768 * (
                                              16 * 9.8)
                        self.ay = float(
                            (int(transformed_hex_values[i + 3]) << 8) | (int(transformed_hex_values[i + 2]) & 255)) / 32768 * (
                                              16 * 9.8)
                        self.az = float(
                            (int(transformed_hex_values[i + 5]) << 8) | (int(transformed_hex_values[i + 4]) & 255)) / 32768 * (
                                              16 * 9.8)

                    if i == 1:
                        # "Angular Velocity"
                        self.wx = float((int(transformed_hex_values[i + 6]) << 8) | (
                                    int(transformed_hex_values[i + 5]) & 255)) / 32768 * 2000
                        self.wy = float((int(transformed_hex_values[i + 8]) << 8) | (
                                    int(transformed_hex_values[i + 7]) & 255)) / 32768 * 2000
                        self.wz = float((int(transformed_hex_values[i + 10]) << 8) | (
                                    int(transformed_hex_values[i + 9]) & 255)) / 32768 * 2000

                    if i == 2:
                        # "Angles"
                        self.rollx = float((int(transformed_hex_values[i + 11]) << 8) | (
                                    int(transformed_hex_values[i + 10]) & 255)) / 32768 * 180
                        self.pitchy = float((int(transformed_hex_values[i + 13]) << 8) | (
                                    int(transformed_hex_values[i + 12]) & 255)) / 32768 * 180
                        self.yawz = float((int(transformed_hex_values[i + 15]) << 8) | (
                                    int(transformed_hex_values[i + 14]) & 255)) / 32768 * 180

                print ()
                print("accel in Y: {}, velocity in x: {}, roll: {}".format(self.ay, self.wx, self.rollx))
                time.sleep(10)

        except KeyboardInterrupt:
            print('interrupted!')

    def connection_failed(self):
        TOMsMessageLog.logMessage(("In GPS_Thread.connection_failed - GPS connection failed ...."),
                                  level=Qgis.Warning)
        self.endGPS()

    def status_changed(self,gpsInfo):
        TOMsMessageLog.logMessage(("In GPS_Thread.status_changed ...."),
                                  level=Qgis.Info)
        if self.gyro_active:
            try:
                #self.retry_attempts = self.retry_attempts + 1
                if self.gpsCon.status() == 3: #data received
                    """TOMsMessageLog.logMessage(("In GPS - fixMode:" + str(gpsInfo.fixMode)),
                                             level=Qgis.Info)
                    TOMsMessageLog.logMessage(("In GPS - pdop:" + str(gpsInfo.pdop)),
                                             level=Qgis.Info)
                    TOMsMessageLog.logMessage(("In GPS - satellitesUsed:" + str(gpsInfo.satellitesUsed)),
                                             level=Qgis.Info)
                    TOMsMessageLog.logMessage(("In GPS - longitude:" + str(gpsInfo.longitude)),
                                             level=Qgis.Info)
                    TOMsMessageLog.logMessage(("In GPS - latitude:" + str(gpsInfo.latitude)),
                                             level=Qgis.Info)
                    TOMsMessageLog.logMessage(("In GPS - ====="),
                                             level=Qgis.Info)"""
                    wgs84_pointXY = QgsPointXY(gpsInfo.longitude, gpsInfo.latitude)
                    wgs84_point = QgsPoint(wgs84_pointXY)
                    wgs84_point.transform(self.transformation)
                    x = wgs84_point.x()
                    y = wgs84_point.y()
                    mapPointXY = QgsPointXY(x, y)
                    self.gpsPosition.emit(mapPointXY, gpsInfo)
                    time.sleep(1)

                    TOMsMessageLog.logMessage(("In GPS - location:" + mapPointXY.asWkt()),
                                             level=Qgis.Info)
                    self.attempts = 0

                    """else:
                    TOMsMessageLog.logMessage(("In GPS_Thread:status_changed: problem receiving gnss position ... "),
                                              level=Qgis.Info)
                    if self.retry_attempts > 5:
                        TOMsMessageLog.logMessage(("In GPS_Thread:status_changed: problem receiving gnss position ... exiting ... "),
                                                  level=Qgis.Info)
                        self.gps_active = False"""

            except Exception as e:
                TOMsMessageLog.logMessage(("In GPS_Thread.status_changed - exception: " + str(e)),
                                         level=Qgis.Warning)
                self.gyroError.emit(e)
            return

    def getLocationFromGPS(self):
        TOMsMessageLog.logMessage(
            "In CreateFeatureWithGPSTool - addPointFromGPS",
            level=Qgis.Info)
        # assume that GPS is connected and get current co-ords ...
        GPSInfo = self.gpsCon.currentGPSInformation()
        lon = GPSInfo.longitude
        lat = GPSInfo.latitude
        TOMsMessageLog.logMessage(
            "In CreateFeatureWithGPSTool:addPointFromGPS - lat: " + str(lat) + " lon: " + str(lon),
            level=Qgis.Info)
        # ** need to be able to convert from lat/long to Point
        gpsPt = self.transformation.transform(QgsPointXY(lon,lat))

        #self.gpsPosition.emit(gpsPt)

        # opportunity to add details about GPS point to another table

        return gpsPt
