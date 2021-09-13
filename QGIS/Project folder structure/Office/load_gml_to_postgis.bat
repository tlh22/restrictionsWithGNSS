REM  load_gml_to_postgis "Z:\Tim\PC21-08 Runnymede\Office\Mapping\Geopackages\OSMasterMapHighwaysRoad_2021-09-03\data" "PC2108_Runnymede"

SET DATA_FOLDER=%1
SET DB_NAME=%2
echo %DATA_FOLDER% %DB_NAME%
@echo off
SET CURRENT_FOLDER=%cd%
echo %CURRENT_FOLDER%
SET PGPASSWORD=password
cd /d %DATA_FOLDER%
call :treeProcess
cd %CURRENT_FOLDER%
goto :eof

:treeProcess
for /R %%f in (*.gml) do (
    REM echo -- %cd% %%f
    echo %%f
    ogr2ogr -update -append -f "PostgreSQL" PG:"host=localhost port=5433 dbname=%DB_NAME% user=postgres active_schema=gml" "%%f" -progress
)