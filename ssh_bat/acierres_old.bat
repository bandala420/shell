@echo off
CLS

for /f "tokens=3delims=<>    " %%i in ('type C:\scp\config\rest_config.xml ^|find "rest"') do set "rest=%%i"
echo %rest%

for /f "tokens=3delims=<>    " %%i in ('type C:\scp\config\rest_config.xml ^|find "llave"') do set "llave=%%i"
echo %llave%

for /f "tokens=1-4 delims=/ " %%i in ("%date%") do (
     set day=%%i
     set month=%%j
     set year=%%k
     set dow=%%l
)
set datestr=%month%_%day%_%year%
REM set datestr=%year%-%month%-%day%
echo datestr is %datestr%
if not exist "C:\scp\acierres\enviar\" mkdir C:\scp\acierres\enviar

 sqlcmd -i C:\scp\acierres\vpos.sql -o C:\scp\acierres\enviar\VPOS-%rest%-%datestr%.csv -h-1  -w 800
 sqlcmd -i C:\scp\acierres\vmed.sql -o C:\scp\acierres\enviar\VMED-%rest%-%datestr%.csv -h-1  -w 999
 
  echo. > "C:\scp\acierres\log_acierres.log"
  
  
set TRIES=10
set INTERVAL=5
 
:retry
  
  
  "C:\scp\WinSCP\WinSCP.exe" /script=C:\scp\acierres\acierres.txt /parameter %rest% %llave% /log=C:\scp\acierres\log_acierres.log
  
if %ERRORLEVEL% neq 0 (
   set /A TRIES=%TRIES%-1
   if %TRIES% gtr 1 (
       echo Failed, retrying in %INTERVAL% seconds...
       timeout /t %INTERVAL%
       goto retry
   ) else (
       echo Failed, aborting
       exit /b 1
   )
)
 
echo Success
exit /b 0