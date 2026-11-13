# DSH HUD daemon: keep the wallpaper data service (node server.mjs) alive.
# Windowless by design: launched at logon via
#   conhost.exe --headless powershell.exe -NoProfile -WindowStyle Hidden -File daemon.ps1
# All output goes to server.log.

$ErrorActionPreference = 'SilentlyContinue'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$log = Join-Path $here 'server.log'
$lock = Join-Path $here 'daemon.lock'

function Log([string]$m) {
  try { Add-Content -Path $log -Value ('[{0}] {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $m) -Encoding UTF8 } catch {}
}

# single instance: another daemon.ps1 process already running -> exit
$others = @(Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object {
  $_.ProcessId -ne $PID -and $_.CommandLine -match '-File\s+"?[^"]*daemon\.ps1'
})
if ($others.Count -gt 0) { exit 0 }

# single instance: exclusive file lock
try {
  $script:lockStream = [System.IO.File]::Open($lock, 'OpenOrCreate', 'ReadWrite', 'None')
} catch {
  exit 0
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

# one-shot: assign the wallpaper to the right screen (hidden)
$fix = Join-Path $here 'fix-wallpaper-screen.ps1'
if (Test-Path $fix) {
  try {
    Start-Process -FilePath 'conhost.exe' `
      -ArgumentList @('--headless', 'powershell.exe', '-NoProfile', '-WindowStyle', 'Hidden', '-ExecutionPolicy', 'Bypass', '-File', $fix, '-Quiet', '-WaitLively', '60') `
      -WindowStyle Hidden | Out-Null
  } catch {}
}

$livelyExe = 'C:\Program Files\Lively Wallpaper\Lively.exe'
$livelyTick = 0

while ($true) {
  # 每 ~60 秒确认 Lively 还在；被关掉或崩溃就拉起来（GUI 程序，无控制台窗口）
  $livelyTick++
  if (($livelyTick % 15) -eq 0 -and (Test-Path $livelyExe)) {
    if (-not (Get-Process Lively -ErrorAction SilentlyContinue)) {
      Log 'Lively not running -> start it'
      try { Start-Process -FilePath $livelyExe | Out-Null } catch { Log ('lively start failed: ' + $_.Exception.Message) }
    }
  }
  if (-not (PortBusy)) {
    Log 'starting server.mjs (daemon)'
    $root = Split-Path -Parent $here
    $cmdline = '/c node "' + (Join-Path $here 'server.mjs') + '" "' + $root + '" >> "' + $log + '" 2>&1'
    try {
      Start-Process -FilePath 'cmd.exe' -ArgumentList $cmdline -WorkingDirectory $here -WindowStyle Hidden | Out-Null
    } catch { Log ('spawn failed: ' + $_.Exception.Message) }
    Start-Sleep -Seconds 10
  } else {
    Start-Sleep -Seconds 4
  }
}
