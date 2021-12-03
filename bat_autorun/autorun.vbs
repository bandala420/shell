Set WshShell = CreateObject("WScript.Shell")
scriptDir = WshShell.CurrentDirectory
WshShell.Run chr(34) & scriptDir & "\autorun.bat" & Chr(34), 0
Set WshShell = Nothing