REM  copy_photos_from_demand "Z:\Tim\PC21-13 Rye Parking Study\Demand\Mapping\EoD\Saturday" "Z:\Tim\PC21-13 Rye Parking Study\Demand\Mapping\Photos"

SET DATA_FOLDER=%1
SET PHOTOS_FOLDER=%2
echo %DATA_FOLDER% %PHOTOS_FOLDER%
@echo off
cd /d %DATA_FOLDER%
call :treeProcess
goto :eof

:treeProcess
for %%f in (*.png *.jpg) do If Not Exist  %PHOTOS_FOLDER%\%%f (
    echo %%f %PHOTOS_FOLDER%
    COPY /Y %%f %PHOTOS_FOLDER%
)
for /D %%d in (*) do (
    cd /d %%d
    REM echo -- %%d
    call :treeProcess
    cd ..
)