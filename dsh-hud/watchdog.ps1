$ErrorActionPreference = 'SilentlyContinue'
# 独立看门狗：Main 于 WMI 启动（Job 外），只做一件事——
# 每 30 秒确认 7788 在听、守护进程还在；缺了就补，避免"服务死了没人拉"。
$here = $PSScriptRoot
$log = Join-Path $here 'watchdog.log'
function Log($m) { Add-Content -Path $log -Value ('[{0}] {1}' -f (Get-Date -Format 'HH:mm:ss'), $m) -Encoding UTF8 }

function Start-Detached2([string]$File, [string]$Arguments = '') {
  try {
    $cmd = if ($Arguments) { '"' + $File + '" ' + $Arguments } else { '"' + $File + '"' }
    return (([wmiclass]'Win32_Process').Create($cmd)).ReturnValue -eq 0
  } catch { return $false }
}

# 单实例
$me = @(Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object {
  $_.ProcessId -ne $PID -and $_.CommandLine -match '-File .*dsh-hud\\watchdog\.ps1'
})
if ($me.Count -gt 0) { exit 0 }
Log 'watchdog started'

while ($true) {
  $listen = Get-NetTCPConnection -LocalPort 7788 -State Listen -ErrorAction SilentlyContinue
  if (-not $listen) {
    Log 'port 7788 down -> start run-node.cmd'
    Start-Detached2 -File 'wscript.exe' -Arguments ('"' + (Join-Path $here 'launch-node.vbs') + '"') | Out-Null
    Start-Sleep -Seconds 10
    $again = Get-NetTCPConnection -LocalPort 7788 -State Listen -ErrorAction SilentlyContinue
    if (-not $again) {
      Log 'still down -> start supervisor'
      Start-Detached2 -File 'powershell.exe' -Arguments ('-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + (Join-Path $here 'start.ps1') + '"') | Out-Null
    }
  }
  Start-Sleep -Seconds 30
}
