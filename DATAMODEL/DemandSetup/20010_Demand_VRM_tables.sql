-- survey areas
--DROP TABLE IF EXISTS mhtc_operations."SurveyAreas";
CREATE TABLE demand."Demand_VRMs"
(
    "ID" SERIAL,
    "SurveyID" integer,
    "SectionID" integer,
    "GeometryID" character varying(12) COLLATE pg_catalog."default",
    "PositionID" integer,
    "VRM" character varying(12) COLLATE pg_catalog."default",
    "VehicleTypeID" integer,
    "RestrictionTypeID" integer,
    "PermitType" integer,
    "Notes" character varying(255) COLLATE pg_catalog."default",
    "Surveyor" character varying(255),
    CONSTRAINT "Demand_VRMs_pkey" PRIMARY KEY ("ID")
)

TABLESPACE pg_default;

ALTER TABLE demand."Demand_VRMs"
    OWNER to postgres;


----- trials
# https://stackoverflow.com/questions/49752388/editable-qtableview-of-complex-sql-query

# setup relational model
# https://stackoverflow.com/questions/51962262/pyqt-add-new-record-using-qsqlrelationaltablemodel-and-qtableview
# https://stackoverflow.com/questions/18716637/how-to-filter-qsqlrelationaltablemodel-with-pyqt
# https://stackoverflow.com/questions/54299754/pyqt5-qsqlrelationaltablemodel-populate-data-with-sqlalchemy-model
# https://gist.github.com/harvimt/4699169
# https://deptinfo-ensip.univ-poitiers.fr/ENS/pyside-docs/PySide/QtSql/QSqlRelationalTableModel.html?highlight=relational


from PyQt5 import QtWidgets, QtSql
#from PyQt5.QtSql import *
from PyQt5.QtSql import QSqlDatabase, QSqlQuery, QSqlQueryModel

def createConnection():
    con = QSqlDatabase.addDatabase("QSQLITE")
    con.setDatabaseName("C:\\Users\\marie_000\\Documents\\MHTC\\VRM_Test.gpkg")
    if not con.open():
        QtWidgets.QMessageBox.critical(None, "Cannot open memory database",
                             "Unable to establish a database connection.\n\n"
                             "Click Cancel to exit.", QtWidgets.QMessageBox.Cancel)
        return False
    #query = QtSql.QSqlQuery()
    return True

class WebsitesWidget(QtWidgets.QWidget):
    def __init__(self, parent=None):
        super(WebsitesWidget, self).__init__(parent)
        # this layout_box can be used if you need more widgets
        # I used just one named WebsitesWidget
        layout_box = QtWidgets.QVBoxLayout(self)
        #
        my_view = QtWidgets.QTableView()
        # put viwe in layout_box area
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
        my_model = QtSql.QSqlRelationalTableModel(self)
        #my_model.setTable("VRMs")
        q = QSqlQuery()
        result = q.prepare("SELECT PositionID, VRM, VehicleTypeID, RestrictionTypeID, PermitType, Notes FROM VRMs")
        if result == False:
            print ('Prepare: {}'.format(q.lastError().text()))
        my_model.setQuery(q)
        #my_model.setFilter("SurveyID = 38 AND SectionID = 31")
        result = my_model.select()
        if result == False:
            print ('Select: {}'.format(q.lastError().text()))
        #show the view with model
        my_view.setModel(my_model)
        my_view.setItemDelegate(QtSql.QSqlRelationalDelegate(my_view))


    def setLookups(self, my_model):


class SqlQueryModel(QSqlQueryModel):
    def setFilter(self, filter):
        text = (self.query().lastQuery() + " WHERE " + filter)
        self.setQuery(text)

query = '''
        SELECT "PositionID", "VRM", "VehicleTypeID", "RestrictionTypeID", "PermitType", "Notes"
	    FROM "VRMs"
        '''
class MainWindow(QtWidgets.QMainWindow):
    def __init__(self, parent=None):
        super(MainWindow, self).__init__(parent)
        self.MDI = QtWidgets.QMdiArea()
        self.setCentralWidget(self.MDI)
        SubWindow1 = QtWidgets.QMdiSubWindow()
        SubWindow1.setWidget(WebsitesWidget())
        self.MDI.addSubWindow(SubWindow1)
        SubWindow1.show()
        # you can add more widgest
        #SubWindow2 = QtWidgets.QMdiSubWindow()

if __name__ == '__main__':
    import sys
    app = QtWidgets.QApplication(sys.argv)
    if not createConnection():
        print("not connect")
        sys.exit(-1)
    w = MainWindow()
    w.show()
    sys.exit(app.exec_())




w = MainWindow()
w.show()

import os

def createConnection(path=None):
    db = QtSql.QSqlDatabase.addDatabase("QSQLITE")
    if path is None:
            db.setDatabaseName(":memory:")
    else:
        if os.path.exists(path) == False:
            raise(' file to connect to db does not exist')
        else:
            db.setDatabaseName(path)
    if not db.open():
        print('Connection failed')
        return False
    else:
        return True

mypath = r"C:Users\\marie_000\\Documents\\MHTC\\Test.gpkg"
path = os.path.join(os.getcwd(), mypath)
print(createConnection())
