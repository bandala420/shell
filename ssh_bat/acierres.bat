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
set datestr=%year%-%month%-%day%
REM set datestr=%year%-%month%-%day%
echo datestr is %datestr%
if not exist "C:\scp\acierres\enviar\" mkdir C:\scp\acierres\enviar

if not exist "C:\scp\acierres\enviar\cierre" mkdir C:\scp\acierres\enviar\cierre
if not exist "C:\scp\acierres\enviar\catalogo" mkdir C:\scp\acierres\enviar\catalogo
if not exist "C:\scp\acierres\enviar\compras" mkdir C:\scp\acierres\enviar\compras
if not exist "C:\scp\acierres\enviar\desperdicio" mkdir C:\scp\acierres\enviar\desperdicio
if not exist "C:\scp\acierres\enviar\ingredientes" mkdir C:\scp\acierres\enviar\ingredientes
if not exist "C:\scp\acierres\enviar\inventario" mkdir C:\scp\acierres\enviar\inventario
if not exist "C:\scp\acierres\enviar\items" mkdir C:\scp\acierres\enviar\items
if not exist "C:\scp\acierres\enviar\recetas" mkdir C:\scp\acierres\enviar\recetas

sqlcmd -i C:\scp\acierres\vpos.sql -o C:\scp\acierres\enviar\cierre\VPOS_%rest%_%datestr%.csv -h-1 -s"|" -W
sqlcmd -i C:\scp\acierres\vmed.sql -o C:\scp\acierres\enviar\cierre\VMED_%rest%_%datestr%.csv -h-1 -s"|" -W
sqlcmd -i C:\scp\acierres\invfisico.sql -o C:\scp\acierres\enviar\inventario\INVFISICO_%rest%_%datestr%.csv -h-1 -s"|" -W
sqlcmd -i C:\scp\acierres\prod.sql -o C:\scp\acierres\enviar\items\PROD_%rest%_%datestr%.csv -h-1 -s"|" -W
sqlcmd -i C:\scp\acierres\frec.sql -o C:\scp\acierres\enviar\recetas\FREC_%rest%_%datestr%.csv -h-1 -s"|" -W
sqlcmd -i C:\scp\acierres\ing.sql -o C:\scp\acierres\enviar\ingredientes\ING_%rest%_%datestr%.csv -h-1 -s"|" -W
sqlcmd -i C:\scp\acierres\catrec.sql -o C:\scp\acierres\enviar\catalogo\CATREC_%rest%_%datestr%.csv -h-1 -s"|" -W
sqlcmd -i C:\scp\acierres\catgru.sql -o C:\scp\acierres\enviar\catalogo\CATGRU_%rest%_%datestr%.csv -h-1 -s"|" -W
sqlcmd -i C:\scp\acierres\docres.sql -o C:\scp\acierres\enviar\compras\DOCRES_%rest%_%datestr%.csv -h-1 -s"|" -W
sqlcmd -i C:\scp\acierres\doccru.sql -o C:\scp\acierres\enviar\compras\DOCCRU_%rest%_%datestr%.csv -h-1 -s"|" -W
sqlcmd -i C:\scp\acierres\desp.sql -o C:\scp\acierres\enviar\desperdicio\DESP_%rest%_%datestr%.csv -h-1 -s"|" -W

C:\scp\acierres\7za.exe a -y -tgzip C:\scp\acierres\enviar\cierre\VPOS_%rest%_%datestr%.csv.gz C:\scp\acierres\enviar\cierre\VPOS_%rest%_%datestr%.csv
C:\scp\acierres\7za.exe a -y -tgzip C:\scp\acierres\enviar\cierre\VMED_%rest%_%datestr%.csv.gz C:\scp\acierres\enviar\cierre\VMED_%rest%_%datestr%.csv
C:\scp\acierres\7za.exe a -y -tgzip C:\scp\acierres\enviar\inventario\INVFISICO_%rest%_%datestr%.csv.gz C:\scp\acierres\enviar\inventario\INVFISICO_%rest%_%datestr%.csv
C:\scp\acierres\7za.exe a -y -tgzip C:\scp\acierres\enviar\items\PROD_%rest%_%datestr%.csv.gz C:\scp\acierres\enviar\items\PROD_%rest%_%datestr%.csv
C:\scp\acierres\7za.exe a -y -tgzip C:\scp\acierres\enviar\recetas\FREC_%rest%_%datestr%.csv.gz C:\scp\acierres\enviar\recetas\FREC_%rest%_%datestr%.csv
C:\scp\acierres\7za.exe a -y -tgzip C:\scp\acierres\enviar\ingredientes\ING_%rest%_%datestr%.csv.gz C:\scp\acierres\enviar\ingredientes\ING_%rest%_%datestr%.csv
C:\scp\acierres\7za.exe a -y -tgzip C:\scp\acierres\enviar\catalogo\CATREC_%rest%_%datestr%.csv.gz C:\scp\acierres\enviar\catalogo\CATREC_%rest%_%datestr%.csv
C:\scp\acierres\7za.exe a -y -tgzip C:\scp\acierres\enviar\catalogo\CATGRU_%rest%_%datestr%.csv.gz C:\scp\acierres\enviar\catalogo\CATGRU_%rest%_%datestr%.csv
C:\scp\acierres\7za.exe a -y -tgzip C:\scp\acierres\enviar\compras\DOCRES_%rest%_%datestr%.csv.gz C:\scp\acierres\enviar\compras\DOCRES_%rest%_%datestr%.csv
C:\scp\acierres\7za.exe a -y -tgzip C:\scp\acierres\enviar\compras\DOCCRU_%rest%_%datestr%.csv.gz C:\scp\acierres\enviar\compras\DOCCRU_%rest%_%datestr%.csv
C:\scp\acierres\7za.exe a -y -tgzip C:\scp\acierres\enviar\desperdicio\DESP_%rest%_%datestr%.csv.gz C:\scp\acierres\enviar\desperdicio\DESP_%rest%_%datestr%.csv

del C:\scp\acierres\enviar\cierre\VPOS_%rest%_%datestr%.csv
del C:\scp\acierres\enviar\cierre\VMED_%rest%_%datestr%.csv
del C:\scp\acierres\enviar\inventario\INVFISICO_%rest%_%datestr%.csv
del C:\scp\acierres\enviar\items\PROD_%rest%_%datestr%.csv
del C:\scp\acierres\enviar\recetas\FREC_%rest%_%datestr%.csv
del C:\scp\acierres\enviar\ingredientes\ING_%rest%_%datestr%.csv
del C:\scp\acierres\enviar\catalogo\CATREC_%rest%_%datestr%.csv
del C:\scp\acierres\enviar\catalogo\CATGRU_%rest%_%datestr%.csv
del C:\scp\acierres\enviar\compras\DOCRES_%rest%_%datestr%.csv
del C:\scp\acierres\enviar\compras\DOCCRU_%rest%_%datestr%.csv
del C:\scp\acierres\enviar\desperdicio\DESP_%rest%_%datestr%.csv

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