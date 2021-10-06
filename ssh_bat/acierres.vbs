Set WshShell = CreateObject("WScript.Shell")
WshShell.Run chr(34) & "C:\scp\acierres\acierres.bat" & Chr(34), 0
Set WshShell = Nothing