# DSH × HALOFLUX live monitor — start the local data bridge
# usage:  pwsh -File dsh-hud/start.ps1 [-Port 7788]
param([int]$Port = 7788)
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $PSScriptRoot
$env:HUD_PORT = "$Port"
Write-Host "DSH HUD starting on http://127.0.0.1:$Port/" -ForegroundColor Cyan

# 顺手把壁纸落到正确的屏幕（iPad/spacedesk 优先，否则主屏），不再写死显示器编号
$fix = Join-Path $PSScriptRoot 'fix-wallpaper-screen.ps1'
if (Test-Path $fix) {
  Start-Process -FilePath 'powershell.exe' `
    -ArgumentList @('-NoProfile', '-WindowStyle', 'Hidden', '-ExecutionPolicy', 'Bypass', '-File', "`"$fix`"", '-Quiet', '-WaitLively', '90') `
    -WindowStyle Hidden | Out-Null
}

node (Join-Path $PSScriptRoot 'server.mjs') $here
