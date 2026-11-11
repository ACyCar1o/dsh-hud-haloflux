' 隐藏启动 node（不弹任何黑窗）
' 由 start.ps1 / watchdog.ps1 通过 wscript.exe 调用：wscript 本身没有控制台窗口，
' 内部再用 WindowStyle=0 运行 cmd，所以整个过程完全静默。
Option Explicit
Dim sh, fso, here, root, cmd
Set sh = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
here = fso.GetParentFolderName(WScript.ScriptFullName)
root = fso.GetParentFolderName(here)
cmd = "cmd /c chcp 65001 >nul & node """ & here & "\server.mjs"" """ & root & """ >> """ & here & "\server.log"" 2>&1"
sh.Run cmd, 0, False
