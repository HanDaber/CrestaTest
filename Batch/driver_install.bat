@echo off

REM devinstapp.exe install HYBRID.inf

echo "---------------------------------------------------------------"
echo [CTC_DEBUG]: The InstallDriversSources.bat is executed on client machine
taskkill /F /FI "IMAGENAME eq ehrecvr.exe"
taskkill /F /FI "IMAGENAME eq ehshell.exe"
taskkill /F /FI "IMAGENAME eq msiexec.exe.exe"

set option=%1
shift
set driversSourcesInstaller_bat_name=%1
shift
set driversSources_path=%1
shift
:loop
	if [%1] == [] goto afterloop
	set driversSources_path=%driversSources_path% %1
	shift
goto loop
:afterloop

cd %driversSources_path%/DriversSources
echo We are in %driversSources_path%/DriversSources

set binDIR=binx64

IF EXIST "C:\Program Files (x86)" GOTO OS_64bit
set binDIR=bin

:OS_64bit
echo And the bin dir is %binDIR%

cd %binDIR%/release

echo Installing Drivers Sources on client, please wait...
set command=%driversSourcesInstaller_bat_name% 
echo %command% 
%command%
set ret_code=%errorlevel%
echo [CTC_DEBUG]: The InstallDriversSources.bat is executed completely (%retcode%)
echo "---------------------------------------------------------------"
exit /B %ret_code%
