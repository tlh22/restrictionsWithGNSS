# Using model/view for demand VRM form

----- trials
# https://stackoverflow.com/questions/49752388/editable-qtableview-of-complex-sql-query

# setup relational model
# https://stackoverflow.com/questions/51962262/pyqt-add-new-record-using-qsqlrelationaltablemodel-and-qtableview
# https://stackoverflow.com/questions/18716637/how-to-filter-qsqlrelationaltablemodel-with-pyqt
# https://stackoverflow.com/questions/54299754/pyqt5-qsqlrelationaltablemodel-populate-data-with-sqlalchemy-model
# https://gist.github.com/harvimt/4699169
# https://deptinfo-ensip.univ-poitiers.fr/ENS/pyside-docs/PySide/QtSql/QSqlRelationalTableModel.html?highlight=relational

from qgis.PyQt.QtCore import (
    Qt
)
from qgis.PyQt.QtWidgets import (
QMessageBox, QWidget, QTableView, QVBoxLayout, QMainWindow,
QMdiArea, QMdiSubWindow, QApplication
)

from qgis.PyQt.QtSql import (
    QSqlDatabase, QSqlQuery, QSqlQueryModel, QSqlRelation, QSqlRelationalTableModel, QSqlRelationalDelegate
)

from .VRM_Demand_dialog import VRM_DemandDialog

def createConnection():
    con = QSqlDatabase.addDatabase("QSQLITE")
    #con.setDatabaseName("C:\\Users\\marie_000\\Documents\\MHTC\\VRM_Test.gpkg")
    con.setDatabaseName("Z:\\Tim\\SYS20-12 Zone K, Watford\\Test\\Mapping\\Geopackages\\SYS2012_Demand_VRMs.gpkg")
    # "Z:\\Tim\\SYS20-12 Zone K, Watford\\Test\\Mapping\\Geopackages\\SYS2012_Demand.gpkg"
    if not con.open():
        QMessageBox.critical(None, "Cannot open memory database",
                             "Unable to establish a database connection.\n\n"
                             "Click Cancel to exit.", QMessageBox.Cancel)
        return False
    #query = QtSql.QSqlQuery()
    return True

class testWidget(QWidget):
    def __init__(self, parent=None):
        super(testWidget, self).__init__(parent)
        # this layout_box can be used if you need more widgets
        # I used just one named WebsitesWidget
        layout_box = QVBoxLayout(self)
        #
        my_view = QTableView()
        # put view in layout_box area
        layout_box.addWidget(my_view)
        # create a table model
        """
        my_model = SqlQueryModel()
        q = QSqlQuery(query)
        my_model.setQuery(q)
        my_model.setFilter("SurveyID = 1 AND SectionID = 31")
        my_model.select()
        my_view.setModel(my_model)
        """
        my_model = QSqlRelationalTableModel(self)
        my_model.setTable("VRMs")
        #q = QSqlQuery()
        #result = q.prepare("SELECT PositionID, VRM, VehicleTypeID, RestrictionTypeID, PermitType, Notes FROM VRMs")
        #if result == False:
        #    print ('Prepare: {}'.format(q.lastError().text()))
        #my_model.setQuery(q)
        my_model.setFilter("SurveyID = 38 AND SectionID = 31")
        my_model.setSort(int(my_model.fieldIndex("PositionID")), Qt.AscendingOrder)
        my_model.setRelation(int(my_model.fieldIndex("VehicleTypeID")), QSqlRelation('VehicleTypes', 'Code', 'Description'))
        rel = my_model.relation(int(my_model.fieldIndex("VehicleTypeID")))
        if not rel.isValid():
            print ('Relation not valid ...')
        result = my_model.select()
        if result == False:
            print ('Select: {}'.format(q.lastError().text()))
        #show the view with model
        my_view.setModel(my_model)
        my_view.setColumnHidden(my_model.fieldIndex('fid'), True)
        my_view.setColumnHidden(my_model.fieldIndex('ID'), True)
        my_view.setColumnHidden(my_model.fieldIndex('SurveyID'), True)
        my_view.setColumnHidden(my_model.fieldIndex('SectionID'), True)
        my_view.setColumnHidden(my_model.fieldIndex('GeometryID'), True)
        my_view.setItemDelegate(QSqlRelationalDelegate(my_view))

    def new_line(self):
        row = my_model.rowCount()
        record = my_model.record()
        record.setGenerated('id', False)
        record.setValue('empid', self.ui.emp_id.text())
        record.setValue('weekending', self.ui.weekending.date())
        record.setValue('department', self.ui.department.currentText())
        record.setValue('pay_type', 'Regular')
        record.setValue('starttime', QDateTime.currentDateTime())
        record.setValue('endtime', QDateTime.currentDateTime())
        my_model.insertRecord(row, record)
        my_view.edit(QModelIndex(my_model.index(row, self.hours_model.fieldIndex('department'))))

class VRM_DemandForm(VRM_DemandDialog):
    def __init__(self, iface, parent=None):
        if not parent:
            parent = iface.mainWindow()
        super().__init__(parent)

        self.iface = iface

        QgsMessageLog.logMessage("In VRM_DemandForm::init", tag="TOMs panel")

        self.setupThisUi()

    def setupThisUi(self):

        self.VRMtab = self.findChild(QWidget, "VRMs")
        self.VRMtab.setWidget(testWidget())

class MainWindow(QMainWindow):
    def __init__(self, parent=None):
        super(MainWindow, self).__init__(parent)
        self.MDI = QMdiArea()
        self.setCentralWidget(self.MDI)
        SubWindow1 = QMdiSubWindow()
        SubWindow1.setWidget(testWidget())
        self.MDI.addSubWindow(SubWindow1)
        SubWindow1.show()
        # you can add more widgest
        #SubWindow2 = QtWidgets.QMdiSubWindow()



