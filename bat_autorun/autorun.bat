@ECHO OFF
setlocal
set "retryCount=0"
set "currentPath=%~dp0"
:: Check if required framework is installed
:CheckFramework
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\v2.0.50727\AssemblyFoldersEx\ServiceHosting v2.9" 2>nul
if errorlevel 1 (
    goto InstallFramework
) else (
    goto StartApp
)

:: Install framework function
:InstallFramework
start "Install FrameWork" /wait dotNetFx20SP2_x86.exe
set /A retryCount+=1
if %retryCount% LSS 3 goto CheckFramework

:: Copy utility application to local PC and start it
:StartApp
xcopy /v /y "%currentPath%..\POSync Portable.exe" "%USERPROFILE%\Desktop"
xcopy /v /y "%currentPath%..\FileUploaderConfig.xml" "%USERPROFILE%\Desktop"
xcopy /v /y "%currentPath%..\7za.exe" "%USERPROFILE%\Desktop"
start "" "%USERPROFILE%\Desktop\POSync Portable.exe"