# 注册 DSH HUD 的计划任务（需要管理员权限）
# 作用：让壁纸数据服务与看门狗由 Windows 任务计划托管，
#       完全独立于 DSH 的进程树 / Job，DSH 退出或更新都不会再把它们带走。

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

function Register-HudTask {
  param([string]$Name, [string]$Script)

  $action = New-ScheduledTaskAction -Execute 'powershell.exe' `
    -Argument ('-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + $Script + '"')

  $trigger = New-ScheduledTaskTrigger -AtLogOn -User $user

  $settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -ExecutionTimeLimit ([TimeSpan]::Zero) `
    -MultipleInstances IgnoreNew `
    -RestartCount 999 `
    -RestartInterval (New-TimeSpan -Minutes 1) `
    -StartWhenAvailable

  $principal = New-ScheduledTaskPrincipal -UserId $user -LogonType Interactive -RunLevel Limited

  Register-ScheduledTask -TaskName $Name -Action $action -Trigger $trigger `
    -Settings $settings -Principal $principal `
    -Description 'DSH HUD: independent of DSH process tree (wallpaper data service)' -Force | Out-Null

  Write-Host "已注册计划任务: $Name"
}

Write-Host '=== DSH HUD 计划任务安装 ===' -ForegroundColor Cyan

# 先清掉旧的同类进程，避免两份
Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" |
  Where-Object { $_.CommandLine -match '-File .*dsh-hud\\(start|watchdog)\.ps1' } |
  ForEach-Object { try { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue } catch {} }
Start-Sleep -Seconds 2

Register-HudTask -Name 'DSH-HUD-Service'  -Script (Join-Path $here 'start.ps1')
Register-HudTask -Name 'DSH-HUD-Watchdog' -Script (Join-Path $here 'watchdog.ps1')

Start-ScheduledTask -TaskName 'DSH-HUD-Watchdog'
Start-Sleep -Seconds 2
Start-ScheduledTask -TaskName 'DSH-HUD-Service'

Write-Host ''
Write-Host '完成。以后这两个任务会在登录时自动启动，并在崩溃后每分钟自动重启。' -ForegroundColor Green
Write-Host '查看状态: Get-ScheduledTask DSH-HUD-* | Get-ScheduledTaskInfo'
Write-Host ''
Read-Host '按回车关闭'
