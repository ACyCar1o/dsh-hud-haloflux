# DSH × HALOFLUX live monitor — start the local data bridge
# usage:  pwsh -File dsh-hud/start.ps1 [-Port 7788]
param([int]$Port = 7788)
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $PSScriptRoot
$env:HUD_PORT = "$Port"
Write-Host "DSH HUD starting on http://127.0.0.1:$Port/" -ForegroundColor Cyan
node (Join-Path $PSScriptRoot 'server.mjs') $here
