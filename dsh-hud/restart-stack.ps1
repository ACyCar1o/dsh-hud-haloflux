# 维护脚本：重启壁纸后台（全部无窗口）
# 用法：powershell -NoProfile -ExecutionPolicy Bypass -File dsh-hud\restart-stack.ps1
# 说明：单独写成文件执行，避免从 DSH 命令里用行内模式匹配时误杀调用方自己。

$ErrorActionPreference = 'SilentlyContinue'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$self = $PID

Write-Host '=== 停止旧后台 ==='
Get-CimInstance Win32_Process | Where-Object {
  $_.ProcessId -ne $self -and (
    $_.CommandLine -like '*dsh-hud*supervise-node.vbs*' -or
    $_.CommandLine -like '*dsh-hud*watchdog.vbs*' -or
    ($_.Name -eq 'node.exe' -and $_.CommandLine -like '*dsh-hud*server.mjs*')
  )
} | ForEach-Object {
  Write-Host ("  kill {0} pid={1}" -f $_.Name, $_.ProcessId)
  Stop-Process -Id $_.ProcessId -Force
}
Start-Sleep -Seconds 3

Write-Host '=== 用开机 VBS 启动（隐藏）==='
$startup = Join-Path ([Environment]::GetFolderPath('Startup')) 'dsh-hud-start.vbs'
$vbs = @"
' DSH HUD auto start at logon (windowless)
Option Explicit
Dim sh, here
Set sh = CreateObject("WScript.Shell")
here = "$here"
sh.Run "wscript.exe """ & here & "\supervise-node.vbs""", 0, False
sh.Run "wscript.exe """ & here & "\watchdog.vbs""", 0, False
sh.Run "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File """ & here & "\fix-wallpaper-screen.ps1""", 0, False
"@
[System.IO.File]::WriteAllText($startup, $vbs, (New-Object System.Text.UnicodeEncoding))
Write-Host "已更新开机自启: $startup"

$p = Start-Process -FilePath 'wscript.exe' -ArgumentList ('"' + $startup + '"') -WindowStyle Hidden -PassThru
Start-Sleep -Seconds 12

Write-Host '=== 结果 ==='
$sup = @(Get-CimInstance Win32_Process -Filter "Name='wscript.exe'" | Where-Object { $_.CommandLine -like '*supervise-node.vbs*' })
$wd = @(Get-CimInstance Win32_Process -Filter "Name='wscript.exe'" | Where-Object { $_.CommandLine -like '*watchdog.vbs*' })
$node = @(Get-CimInstance Win32_Process -Filter "Name='node.exe'" | Where-Object { $_.CommandLine -like '*dsh-hud*server.mjs*' })
Write-Host ("supervisor={0} watchdog={1} node={2}" -f $sup.Count, $wd.Count, $node.Count)
try {
  $s = Invoke-RestMethod 'http://127.0.0.1:7788/stats' -TimeoutSec 6
  Write-Host ("service: clients={0} hidden={1} rss={2}MB" -f $s.clients, $s.pageHidden, $s.rssMB)
} catch { Write-Host 'service: DOWN' }
