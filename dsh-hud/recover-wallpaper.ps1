# 丢画面快速恢复（手动入口，双击用）
# 为什么不做自动重载：setwp --file reload 会把 WebView2 播放器撕掉重建，
# 每次会遗弃一个 2~3.5GB 的 GPU 进程（杀不掉，只能重启回收）。
# 所以恢复只有两个动作：干净的「重启 Lively」+ 清理孤儿 + 重新选屏。

param([switch]$Silent)

$ErrorActionPreference = 'SilentlyContinue'

# --- Job 逃逸助手 ------------------------------------------------------------
# DSH 把每条命令的进程树放进 KILL_ON_JOB_CLOSE 的 Job：从命令里 Start-Process 起的
# 常驻进程会被连带杀掉，Job 不空还会让命令永不返回（会话卡住/自动更新超时）。
# 实测：Start-Process 和 explorer.exe 都会落进 Job；只有 WMI Win32_Process.Create 能逃出去。
function Start-Detached {
  param([string]$File, [string]$Arguments = '')
  try {
    $cmd = if ($Arguments) { '"' + $File + '" ' + $Arguments } else { '"' + $File + '"' }
    $r = ([wmiclass]'Win32_Process').Create($cmd)
    if ($r.ReturnValue -eq 0) { return $true }
  } catch {}
  try { Start-Process -FilePath $File -ArgumentList $Arguments -WindowStyle Hidden | Out-Null; return $true } catch {}
  return $false
}
# ---------------------------------------------------------------------------
$here = Split-Path -Parent $PSCommandPath
$LIVELY = 'C:\Program Files\Lively Wallpaper\Lively.exe'
if (-not (Test-Path $LIVELY)) { $LIVELY = (Get-ChildItem 'C:\Program Files*\Lively*' -Filter Lively.exe -Recurse -Depth 2 -ErrorAction SilentlyContinue | Select-Object -First 1).FullName }
$log = Join-Path $here 'recover.log'
function Say($m) {
  $line = '[{0}] {1}' -f (Get-Date -Format 'HH:mm:ss'), $m
  Add-Content -Path $log -Value $line -Encoding UTF8
  if (-not $Silent) { Write-Host $line -ForegroundColor Cyan }
}

Say '=== 恢复壁纸 ==='

# 1) 数据服务
$svc = Get-NetTCPConnection -LocalPort 7788 -State Listen -ErrorAction SilentlyContinue
if (-not $svc) {
  Say '数据服务未运行，启动中…'
  Start-Detached -File 'powershell.exe' -Arguments ('-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + (Join-Path $here 'start.ps1') + '"') | Out-Null
  Start-Sleep -Seconds 8
} else { Say '数据服务正常' }

# 2) 干净重启 Lively（不要用 reload）
Say '重启 Lively…'
Get-Process Lively -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 3
if (Test-Path $LIVELY) { Start-Detached -File $LIVELY | Out-Null }
Start-Sleep -Seconds 12

# 3) 清理本次重启前遗留的孤儿 WebView2
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $here 'cleanup-webviews.ps1') 2>&1 | Out-Null
Say '已清理孤儿 WebView2'

# 4) 重新选屏
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $here 'fix-wallpaper-screen.ps1') -Quiet 2>&1 | Out-Null
Say '已重新选屏'

# 5) 打开预览（交互模式）
if (-not $Silent) { Start-Process 'http://127.0.0.1:7788/wall' }
Say '完成'
