' Start the DSH HUD server without a console window.
' Used by the shortcut placed in shell:startup (runs at every logon).
Option Explicit
Dim sh, fso, script
Set sh = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
script = fso.BuildPath(fso.GetParentFolderName(WScript.ScriptFullName), "start.ps1")
sh.Run "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File """ & script & """", 0, False
