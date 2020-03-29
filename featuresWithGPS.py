# -*- coding: utf-8 -*-
"""
/***************************************************************************
 Test5Class
                                 A QGIS plugin
 Start of TOMs
                              -------------------
        begin                : 2017-01-01
        git sha              : $Format:%H$
        copyright            : (C) 2017 by TH
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

"""
from PyQt4.QtCore import *
from PyQt4.QtGui import *
from qgis.core import *
from qgis.gui import *

# Initialize Qt resources from file resources.py
import resources

# Import the code for the dialog
from TOMs.core.proposalsManager import TOMsProposalsManager

from .expressions import registerFunctions, unregisterFunctions
#from TOMs.test5_module_dialog import Test5ClassDialog

from .proposals_panel import proposalsPanel
from .search_bar import searchBar

from .manage_restriction_details import manageRestrictionDetails

import os.path
import time
import datetime
"""

from qgis.PyQt.QtWidgets import (
    QMessageBox,
    QAction,
    QDialogButtonBox,
    QLabel,
    QDockWidget
)

from qgis.PyQt.QtGui import (
    QIcon,
    QPixmap
)

from qgis.PyQt.QtCore import (
    QObject, QTimer, pyqtSignal,
    QTranslator,
    QSettings,
    QCoreApplication,
    qVersion, QThread
)

from qgis.core import (
    QgsExpressionContextUtils,
    QgsExpression,
    QgsFeatureRequest,
    # QgsMapLayerRegistry,
    QgsMessageLog, QgsFeature, QgsGeometry,
    QgsTransaction, QgsTransactionGroup,
    QgsProject,
    QgsApplication
)

from .manage_feature_creation import captureGPSFeatures

import os.path
import time
import datetime


class featuresWithGPS:
    """QGIS Plugin Implementation."""

    def __init__(self, iface):

        QgsMessageLog.logMessage("Starting featuresWithGPS ... ", tag="TOMs panel")

        """Constructor.
        
        :param iface: An interface instance that will be passed to this class
            which provides the hook by which you can manipulate the QGIS
            application at run time.
        :type iface: QgsInterface
        """
        # Save reference to the QGIS interface
        self.iface = iface
        # initialize plugin directory
        self.plugin_dir = os.path.dirname(__file__)
        # initialize locale
        locale = QSettings().value('locale/userLocale')[0:2]
        locale_path = os.path.join(
            self.plugin_dir,
            'i18n',
            'Test5Class_{}.qm'.format(locale))

        if os.path.exists(locale_path):
            self.translator = QTranslator()
            self.translator.load(locale_path)

            if qVersion() > '4.3.3':
                QCoreApplication.installTranslator(self.translator)

        # Declare instance attributes
        self.actions = []   # ?? check - assume it initialises array of actions
        
        # self.menu = self.tr(u'&Test5')
        # TODO: We are going to let the user set this up in a future iteration

        # Set up log file and collect any relevant messages
        logFilePath = os.environ.get('QGIS_LOGFILE_PATH')

        if logFilePath:

            QgsMessageLog.logMessage("LogFilePath: " + str(logFilePath), tag="TOMs panel")

            logfile = 'qgis_' + datetime.date.today().strftime("%Y%m%d") + '.log'
            self.filename = os.path.join(logFilePath, logfile)
            QgsMessageLog.logMessage("Sorting out log file" + self.filename, tag="TOMs panel")
            QgsApplication.instance().messageLog().messageReceived.connect(self.write_log_message)

        QgsMessageLog.logMessage("Finished init", tag="TOMs panel")
        #self.toolbar = self.iface.addToolBar(u'Test5Class')
        #self.toolbar.setObjectName(u'Test5Class')


    def write_log_message(self, message, tag, level):
        #filename = os.path.join('C:\Users\Tim\Documents\MHTC', 'qgis.log')
        with open(self.filename, 'a') as logfile:
            logfile.write('{dateDetails}:: {message}\n'.format(dateDetails= time.strftime("%Y%m%d:%H%M%S"), message=message))

    # noinspection PyMethodMayBeStatic
    def tr(self, message):
        """Get the translation for a string using Qt translation API.

        We implement this ourselves since we do not inherit QObject.

        :param message: String for translation.
        :type message: str, QString

        :returns: Translated version of message.
        :rtype: QString
        """
        # noinspection PyTypeChecker,PyArgumentList,PyCallByClass
        return QCoreApplication.translate('Test5Class', message)

    def initGui(self):
        """Create the menu entries and toolbar icons inside the QGIS GUI."""
        QgsMessageLog.logMessage("Registering expression functions ... ", tag="TOMs panel")

        self.hideMenusToolbars()

        # set up menu. Is there a generic way to do this? from an xml file?

        QgsMessageLog.logMessage("Adding toolbar", tag="TOMs panel")

        # Add toolbar 
        self.featuresWithGPSToolbar = self.iface.addToolBar("featuresWithGPS Toolbar")
        self.featuresWithGPSToolbar.setObjectName("featuresWithGPSToolbar Toolbar")

        self.actionGPSToolbar = QAction(QIcon(":/plugins/featureswithgps/resources/GPS.png"),
                               QCoreApplication.translate("MyPlugin", "Start GPS Tools"), self.iface.mainWindow())
        self.actionGPSToolbar.setCheckable(True)

        self.featuresWithGPSToolbar.addAction(self.actionGPSToolbar)

        self.actionGPSToolbar.triggered.connect(self.onInitGPSTools)

        #self.currGPSManager = gpsManager(self.iface)
        #self.tableNames = self.gpsManager.tableNames

        # Now set up the toolbar

        self.gpsTools = captureGPSFeatures(self.iface, self.featuresWithGPSToolbar)
        #self.gpsTools.disableFeaturesWithGPSToolbarItems()

    def onInitGPSTools(self):
        """Filter main layer based on date and state options"""

        QgsMessageLog.logMessage("In onInitGPSTools", tag="TOMs panel")

        # print "** STARTING ProposalPanel"

        # dockwidget may not exist if:
        #    first run of plugin
        #    removed on close (see self.onClosePlugin method)

        # self.TOMSLayers.TOMsStartupFailure.connect(self.setCloseTOMsFlag)
        # self.RestrictionTypeUtilsMixin.tableNames.TOMsStartupFailure.connect(self.closeTOMsTools)

        if self.actionGPSToolbar.isChecked():

            QgsMessageLog.logMessage("In onInitGPSTools. Activating ...", tag="TOMs panel")

            self.openGPSTools()

        else:

            QgsMessageLog.logMessage("In onInitGPSTools. Deactivating ...", tag="TOMs panel")

            self.closeGPSTools()

        pass

    def openGPSTools(self):
        # actions when the Proposals Panel is closed or the toolbar "start" is toggled

        QgsMessageLog.logMessage("In openGPSTools. Activating ...", tag="TOMs panel")
        self.closeGPSToolsFlag = False

        # Check that tables are present
        QgsMessageLog.logMessage("In openGPSTools. Checking tables", tag="TOMs panel")
        #self.tableNames.TOMsLayersNotFound.connect(self.setCloseTOMsFlag)

        #self.tableNames.getLayers()

        if self.closeGPSToolsFlag:
            QMessageBox.information(self.iface.mainWindow(), "ERROR", ("Unable to start GPSTools ..."))
            self.actionGPSToolbar.setChecked(False)
            return

        self.gpsTools.enableFeaturesWithGPSToolbarItems()


    def setCloseGPSToolsFlag(self):
        self.closeGPSToolsFlag = True

    def closeGPSTools(self):
        # actions when the Proposals Panel is closed or the toolbar "start" is toggled

        QgsMessageLog.logMessage("In closeGPSTools. Deactivating ...", tag="TOMs panel")

        # TODO: Delete any objects that are no longer needed

        #self.proposalTransaction.rollBackTransactionGroup()
        #del self.proposalTransaction  # There is another call to this function from the dock.close()

        # Now disable the items from the Toolbar

        self.gpsTools.disableFeaturesWithGPSToolbarItems()

        pass

    def unload(self):
        """Removes the plugin menu item and icon from QGIS GUI."""

        # remove the toolbar
        QgsMessageLog.logMessage("Clearing toolbar ... ", tag="TOMs panel")
        self.featuresWithGPSToolbar.clear()
        QgsMessageLog.logMessage("Deleting toolbar ... ", tag="TOMs panel")
        del self.featuresWithGPSToolbar
        #self.restoreMenusToolbars()

        QgsMessageLog.logMessage("Unload comnpleted ... ", tag="TOMs panel")

    def hideMenusToolbars(self):
        ''' Remove the menus and toolbars that we don't want (e.g., the Edit menu)
            There should be a more elegant way to do this by checking the collection of menu items and removing certain ones.
            This will do for the moment  !?! - See http://gis.stackexchange.com/questions/227876/finding-name-of-qgis-toolbar-in-python
        '''

        # Menus not required are Processing, Raster, Vector, Layer and Edit

        # databaseMenu = self.iface.databaseMenu()
        # databaseMenu.menuAction().setVisible( False )

        #rasterMenu = self.iface.rasterMenu()
        #rasterMenu.menuAction().setVisible( False )

        # Toolbars not required are Vector, Managing Layers, File, Digitizing, Attributes, 
        #digitizeToolBar = self.iface.digitizeToolBar()
        #digitizeToolBar.setVisible( False )

        #advancedDigitizeToolBar = self.iface.advancedDigitizeToolBar()
        #advancedDigitizeToolBar.setVisible( False )

        # Panels not required are Browser, Layer Order
		
        for x in self.iface.mainWindow().findChildren(QDockWidget):
            QgsMessageLog.logMessage("Dockwidgets: " + str(x.objectName()), tag="TOMs panel")

        # for x in self.iface.mainWindow().findChildren(QMenu): 
        #     QgsMessageLog.logMessage("Menus: " + str(x.objectName()), tag="TOMs panel")

        # rasterMenu = self.iface.rasterMenu()
        # databaseMenu.menuAction().setVisible( False )
        pass


    def restoreMenusToolbars(self):
        ''' Remove the menus and toolbars that we don't want (e.g., the Edit menu)
            There should be a more elegant way to do this by checking the collection of menu items and removing certain ones.
            This will do for the moment  !?! - See http://gis.stackexchange.com/questions/227876/finding-name-of-qgis-toolbar-in-python
        '''

        # Menus not required are Processing, Raster, Vector, Layer and Edit

        databaseMenu = self.iface.databaseMenu()
        databaseMenu.menuAction().setVisible( True )

        rasterMenu = self.iface.rasterMenu()
        rasterMenu.menuAction().setVisible( True )

        # Toolbars not required are Vector, Managing Layers, File, Digitizing, Attributes, 
        digitizeToolBar = self.iface.digitizeToolBar()
        digitizeToolBar.setVisible( True )

        advancedDigitizeToolBar = self.iface.advancedDigitizeToolBar()
        advancedDigitizeToolBar.setVisible( True )

        # Panels not required are Browser, Layer Order
		
        for x in self.iface.mainWindow().findChildren(QDockWidget): 
            QgsMessageLog.logMessage("Dockwidgets: " + str(x.objectName()), tag="TOMs panel")

        # for x in self.iface.mainWindow().findChildren(QMenu): 
        #     QgsMessageLog.logMessage("Menus: " + str(x.objectName()), tag="TOMs panel")

        # rasterMenu = self.iface.rasterMenu()
        # databaseMenu.menuAction().setVisible( True )


