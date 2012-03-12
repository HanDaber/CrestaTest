@echo off
REM I know all these shifts are ugly, but it works...
echo We are in %0
set app="%1"
echo App is %app%
shift
set cmd=%1
echo Cmd is %cmd%
shift
set user_ip=%2
set file_path=%1
set scp_send=%user_ip%%file_path%
set prm1=%1 %2 %3 %4 %5 %6 %7 %8 %9
shift
shift
shift
shift
shift
shift
shift
shift
shift
set prm2=%1 %2 %3 %4 %5 %6 %7 %8 %9
shift
shift
shift
shift
shift
shift
shift
shift
shift
set prm3=%1 %2 %3 %4 %5 %6 %7 %8 %9

set prms=%prm1% %prm2% %prm3%
echo Params are %prms%
REM pause 2

if %app% == "player" goto player
if %app% == "mce" goto mce
if %app% == "devcon" goto devcon
if %app% == "7zip" goto 7zip
if %app% == "rm" goto rm
if %app% == "mk" goto mk
if %app% == "scp" goto scp
if %app% == "scp_send" goto scp_send

echo You shouldn't be seeing this.

:player
	echo Sending command to player:
	
	set dir=C:\Program Files\Crestatech\CrestaTV\Bin
	set exe=PlayerGuiMfc.exe
	set cmd="%cmd%"
	
	if %cmd% == "start" goto start
	if %cmd% == "stop" goto stop
	
:mce
	echo Sending command to media center:
	
	set dir=C:\Windows\ehome
	set exe=ehshell.exe
	REM set prms=1
	set cmd="%cmd%"
	echo cd %dir%; start /b %exe% %prms%
	REM pause 1
	if %cmd% == "start" goto start
	if %cmd% == "stop" goto stop	
	
:devcon
	echo Sending command to devcon:
	
	set dir=Utilities
	set exe=devcon32.exe
	set cmd="%cmd%"
	
	if %cmd% == "install" goto start
	if %cmd% == "remove" goto start	
	
:7zip
	echo Sending command to 7zip:
	
	set dir=.
	set exe=7za.exe
	set cmd="%cmd%"
	echo start /b %exe% %prms%
	REM pause 1
	if %cmd% == "compress" goto start
	if %cmd% == "extract" goto start	
	
:rm
	echo Sending rm command:
	
	rm %cmd% %prms%
	
	goto exit	
	
:mk
	echo Sending mkdir command:
	echo mkdir %cmd%\
	ls -l
	REM pause 1
	mkdir %cmd%\
	REM pause 1
	goto exit
			
:scp
	echo Sending scp command:
	
	scp %cmd% %prms%
	
	goto exit
	
:scp_send
	echo Sending scp command:
	echo scp %cmd% %scp_send%

	scp %cmd% %scp_send%
	REM pause 1	
	goto exit
		
REM ##############################################
		
	:start
		echo cd %dir%; START [/b] %exe% %prms%
		
		cd %dir%
		REM start /b %exe% %prms%
		start %exe% %prms%
		REM pause 1
		goto exit
		
	:stop
		echo STOP
		taskkill /f /im %exe%
		
		goto exit

REM ###############################################
		
:exit
	REM pause 1
	echo OK, %prms%
	set ret=%errorlevel%
	exit /b %ret%