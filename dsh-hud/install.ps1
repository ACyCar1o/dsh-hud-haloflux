# DSH HUD 一键安装（换电脑/重装用）
# 用法：在解压后的目录里运行
#   powershell -NoProfile -ExecutionPolicy Bypass -File dsh-hud\install.ps1
# 作用：
#   1. 检查 Node.js 与 haloflux 目录
#   2. 写入开机自启（shell:startup\dsh-hud-start.vbs，自动使用当前路径）
#   3. 立即启动服务
#   4. 打印 Lively 壁纸设置步骤

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $PSCommandPath
$root = Split-Path -Parent $here
$halo = Join-Path $root 'haloflux'

Write-Host '== DSH HUD 安装 ==' -ForegroundColor Cyan

$node = Get-Command node -ErrorAction SilentlyContinue
if (-not $node) {
  Write-Host '找不到 node。请先安装 Node.js 20+：https://nodejs.org' -ForegroundColor Red
  exit 1
}
Write-Host "node: $($node.Source)"

if (-not (Test-Path (Join-Path $halo 'lab.html'))) {
  Write-Host '缺少 haloflux 目录。请保持 dsh-hud 与 haloflux 在同一个父目录下。' -ForegroundColor Red
  exit 1
}

$startup = [Environment]::GetFolderPath('Startup')
$vbsPath = Join-Path $startup 'dsh-hud-start.vbs'
$vbs = @"
' DSH HUD auto start at logon
Option Explicit
Dim sh
Set sh = CreateObject("WScript.Shell")
sh.Run "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File ""$here\start.ps1""", 0, False
"@
Set-Content -Path $vbsPath -Value $vbs -Encoding ASCII
Write-Host "已写入开机自启：$vbsPath"

Start-Process -FilePath 'powershell.exe' `
  -ArgumentList '-NoProfile', '-WindowStyle', 'Hidden', '-ExecutionPolicy', 'Bypass', '-File', "`"$here\start.ps1`"" `
  -WindowStyle Hidden
Start-Sleep -Seconds 4

try {
  $s = Invoke-RestMethod 'http://127.0.0.1:7788/stats' -TimeoutSec 6
  Write-Host "服务已启动：rss=$($s.rssMB)MB" -ForegroundColor Green
} catch {
  Write-Host '服务未响应。请单独运行 dsh-hud\start.ps1 查看报错。' -ForegroundColor Yellow
}

Write-Host ''
Write-Host '接下来设置壁纸：' -ForegroundColor Cyan
Write-Host '  1) 安装 Lively Wallpaper：winget install --id rocksdanister.LivelyWallpaper'
Write-Host '  2) Lively -> 添加壁纸 -> URL -> http://127.0.0.1:7788/wall'
Write-Host '     （或使用 dsh-hud\wall-proj 作为壁纸工程）'
Write-Host '  3) 想换屏幕：Lively.exe setwp --file "<Lively库路径>" --monitor <编号>'
Write-Host ''
Write-Host '预览：http://127.0.0.1:7788/'
