# DSH HUD 守护（纯 PowerShell，无 VBS、无窗口）
# 职责：
#   1) 单实例（同名 mutex），重复启动会立刻退出
#   2) node 没在跑就在后台隐藏启动它，输出追加到 server.log
#   3) node 退出 3 秒后自动重启
# 由开机启动项或计划任务以 -WindowStyle Hidden 调用。

$ErrorActionPreference = 'SilentlyContinue'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$log = Join-Path $here 'server.log'
$nodeExe = (Get-Command node.exe -ErrorAction SilentlyContinue).Source
if (-not $nodeExe) { $nodeExe = 'C:\Program Files\nodejs\node.exe' }
$serverJs = Join-Path $here 'server.mjs'
$root = Split-Path -Parent $here

function Log($m) {
  try { Add-Content -Path $log -Value ('[{0}] {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $m) -Encoding UTF8 } catch {}
}

# 单实例
$mutex = $null
try { $mutex = New-Object System.Threading.Mutex($false, 'DSH-HUD-Daemon') } catch {}
if ($mutex) {
  if (-not $mutex.WaitOne(0)) { exit 0 }
} else {
  # 兜底：用文件锁避免重复实例
  $lock = Join-Path $here 'daemon.lock'
  try {
    $fs = [System.IO.File]::Open($lock, 'OpenOrCreate', 'ReadWrite', 'None')
    $script:lockStream = $fs
  } catch { exit 0 }
}

function PortBusy {
  try {
    $c = New-Object System.Net.Sockets.TcpClient
    $c.Connect('127.0.0.1', 7788)
    $c.Close()
    return $true
  } catch { return $false }
}

Log 'daemon started'

# 一次性：把壁纸放到正确屏幕（后台隐藏）
$fix = Join-Path $here 'fix-wallpaper-screen.ps1'
if (Test-Path $fix) {
  Start-Process -FilePath 'powershell.exe' -WindowStyle Hidden -ArgumentList @(
    '-NoProfile', '-WindowStyle', 'Hidden', '-ExecutionPolicy', 'Bypass', '-File', "`"$fix`"", '-Quiet', '-WaitLively', '60'
  ) -WindowStyle Hidden | Out-Null
}

# 守护循环
while ($true) {
  if (-not (PortBusy)) {
    Log 'starting server.mjs (daemon)'
    try {
      Start-Process -FilePath $nodeExe -ArgumentList @("`"$serverJs`"", "`"$root`"") `
        -WorkingDirectory $here -WindowStyle Hidden -NoNewWindow:$false `
        -RedirectStandardOutput (Join-Path $here 'server.stdout.log') `
        -RedirectStandardError (Join-Path $here 'server.stderr.log') | Out-Null
    } catch { Log ('spawn failed: ' + $_.Exception.Message) }
    Start-Sleep -Seconds 8
  } else {
    Start-Sleep -Seconds 4
  }
}
