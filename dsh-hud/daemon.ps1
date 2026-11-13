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

while ($true) {
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
