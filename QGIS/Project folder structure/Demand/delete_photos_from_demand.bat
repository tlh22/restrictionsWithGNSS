REM  delete_photos_from_demand "Z:\WSP24-07 Bermondsey, Southwark\Demand\EoD"

@echo off

SET CURR_DIR=%cd%
SET DATA_FOLDER=%1

REM echo %DATA_FOLDER%

cd /d %DATA_FOLDER%

SETLOCAL ENABLEDELAYEDEXPANSION
SET count=0
for /r %%i in (*.png *.jpg *.zip) do (
	set full_fname=%%i
    REM echo DEL /Q !full_fname!
    DEL /Q "!full_fname!"
	set /a count+=1
)
echo files deleted: %count%
cd %CURR_DIR%