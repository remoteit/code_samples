@echo off

echo.
echo -----------------------------
echo Upgrade remote.it CLI.
echo Older versions to be upgraded include:
echo v1.4.x, v1.5.x, v1.6.x, v1.7.x, v1.8.x, v2.0.x
echo -----------------------------
echo.

rem Set the current dir to the working dir where this batch file is to be executed.
cd /d %~dp0

rem Set the variable.
set CLI_DIR="C:\Program Files\remoteit"
set CLI="C:\Program Files\remoteit\remoteit.exe"
set BIN_DIR="C:\Program Files\remoteit-bin"
set CONNECTD="C:\Program Files\remoteit-bin\connectd.exe"
set MUXER="C:\Program Files\remoteit-bin\muxer.exe"
set DEMUXER="C:\Program Files\remoteit-bin\demuxer.exe"
set CONFIG="C:\ProgramData\remoteit\config.json"
set LOG_DIR="C:\ProgramData\remoteit\log"

rem Upgrade to
set VERSION=v3.0.33

rem Check for the existence of each file and directory.
echo.
echo.
echo Checking if the binary file and log directory exists in the proper location.....
for %%i in (%CLI% %CONNECTD% %MUXER% %DEMUXER% %CONFIG% %LOG_DIR%) do (
 if exist %%i (
    echo.
    echo %%i is exist.
 ) else (
    echo.
    echo %%i is not exist.
    echo Terminates processing of upgraging.
    echo Please contact support.
    echo support@remote.it
    pause
    exit /b 1
 )
)

rem Check if the installed version is supported with this script.
for /f "usebackq delims=" %%A in (`"%CLI%" version`) do set INSTALLED_VERSION=%%A
echo.
echo.
echo The currently installed version of the remote.it CLI is v%INSTALLED_VERSION%.
for %%F in (v1.4 v1.5 v1.6 v1.7 v1.8 v2.0) do (
    echo.
    echo v%INSTALLED_VERSION% | findstr %%F >NUL
    if %errorlevel%==0 goto :BREAK01
)
goto BREAK02

:BREAK01
echo This is the version to be upgraded.
goto NEXT01

:BREAK02
echo This is not the version to be upgraded.
echo Please contact support.
echo support@remote.it
pause
exit /b 1

:NEXT01

rem Create the working folder for upgrading process.
md %~dp0\r3_cli_upgrade\backup\bin
md %~dp0\r3_cli_upgrade\backup\config
md %~dp0\r3_cli_upgrade\backup\log
md %~dp0\r3_cli_upgrade\tmp

rem Backup files
copy %CLI% %~dp0\r3_cli_upgrade\backup\bin >NUL
copy %CONNECTD% %~dp0\r3_cli_upgrade\backup\bin >NUL
copy %MUXER% %~dp0\r3_cli_upgrade\backup\bin >NUL
copy %DEMUXER% %~dp0\r3_cli_upgrade\backup\bin >NUL
copy %CONFIG% %~dp0\r3_cli_upgrade\backup\config >NUL
copy %LOG_DIR%\* %~dp0\r3_cli_upgrade\backup\log >NUL

rem Detect the cpu architecture for this device. (AMD64/IA64/ARM64/x86)
set TRUE_FALSE=FALSE
if %PROCESSOR_ARCHITECTURE%==AMD64 set TRUE_FALSE=TRUE
if %PROCESSOR_ARCHITECTURE%==IA64 set TRUE_FALSE=TRUE
if %TRUE_FALSE%==TRUE (
    set ARCH=x86_64
) else if %PROCESSOR_ARCHITECTURE%==ARM64 (
    set ARCH=aarch64
) else if %PROCESSOR_ARCHITECTURE%==x86 (
    set ARCH=x86
) else (
    echo.
    echo CPU architecture could not be detected.
    echo Please contact support.
    echo support@remote.it
    pause
    exit /b 1
)
echo.
echo.
echo Arch is %ARCH%.

rem Download the latest CLI.
echo.
echo.
echo Downloading remoteit CLI %VERSION%.....
start /wait bitsadmin /transfer CLIDOWNLOAD https://downloads.remote.it/cli/%VERSION%/remoteit.%ARCH%-win.exe %~dp0\r3_cli_upgrade\tmp\remoteit.exe
if not %errorlevel%==0 (
    echo.
    echo Download of the latest remote.it CLI failed due to some problem.
    echo Please contact support.
    echo support@remote.it
    pause
    exit /b 1
)
echo Download complete.

echo.
echo.
echo -----------------------------
echo It will stop the service of the old remote.it CLI.
echo This takes the target device offline and also disconnects
echo the initiator connection if it has one.
echo -----------------------------

set /P selected="Continue? (Y=YES / N=NO)?"
if /i %selected%==y goto :YES01
if /i %selected%==yes goto :YES01

echo.
echo Stopping upgrading process.....
pause
exit /b 1

:YES01

rem Stop the it.remote.cli service.
echo.
echo Stopping the it.remote.cli service.....
%CLI% agent stop
if not %errorlevel%==0 (
    echo.
    echo Failed to stop the it.remote.cli service.
    echo Please contact support.
    echo support@remote.it
    pause
    exit /b 1
)

rem Uninstall the it.remote.cli service.
echo.
echo Uninstalling the it.remote.cli service.....
%CLI% agent uninstall
if not %errorlevel%==0 (
    echo.
    echo Failed to uninstall the it.remote.cli service.
    echo Please contact support.
    echo support@remote.it
    pause
    exit /b 1
)

rem If any processes remain, terminate them.
echo.
echo If the process remains, it is terminated......
tasklist |find "remoteit.exe" >NUL
if %errorlevel%==0 (
    taskkill /f /im remoteit.exe >NUL
)
tasklist |find "connectd.exe" >NUL
if %errorlevel%==0 (
    taskkill /f /im connectd.exe >NUL
)
tasklist |find "muxer.exe" >NUL
if %errorlevel%==0 (
    taskkill /f /im muxer.exe >NUL
)
tasklist |find "demuxer.exe" >NUL
if %errorlevel%==0 (
    taskkill /f /im demuxer.exe >NUL
)

rem Copy the latest CLI.
copy %~dp0\r3_cli_upgrade\tmp\remoteit.exe %CLI_DIR% >NUL

rem Install and start the latest CLI.
cd %CLI_DIR%
%CLI% agent install --yes
%CLI% agent restart
if not %errorlevel%==0 (
    echo.
    echo Failed to install the new it.remote.cli service.
    echo Start to rollback to the old version.
    goto ROLLBACK
)
cd %~dp0
goto FINISH

rem Below is the rollback process in case the latest CLI did not start. Restore from a backed up file.
:ROLLBACK
echo.
echo Rollbacking.....
%CLI% agent stop
%CLI% agent uninstall
echo.
echo If the process remains, it is terminated......
tasklist |find "remoteit.exe" >NUL
if %errorlevel%==0 (
    taskkill /f /im remoteit.exe >NUL
)
tasklist |find "connectd.exe" >NUL
if %errorlevel%==0 (
    taskkill /f /im connectd.exe >NUL
)
tasklist |find "muxer.exe" >NUL
if %errorlevel%==0 (
    taskkill /f /im muxer.exe >NUL
)
tasklist |find "demuxer.exe" >NUL
if %errorlevel%==0 (
    taskkill /f /im demuxer.exe >NUL
)
del "C:\Program Files\remoteit\remoteit.exe" >NUL
del "C:\Program Files\remoteit\connectd.exe" >NUL
del "C:\Program Files\remoteit\muxer.exe" >NUL
del "C:\Program Files\remoteit\demuxer.exe" >NUL
del %CONFIG%
copy %~dp0\r3_cli_upgrade\backup\bin\remoteit.exe %CLI_DIR% >NUL
copy %~dp0\r3_cli_upgrade\backup\config\config.json "C:\ProgramData\remoteit" >NUL
%CLI% agent install
%CLI% agent restart

cmd /k
pause

:FINISH
cmd /k
pause