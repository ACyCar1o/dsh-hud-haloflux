# DSH × HALOFLUX live monitor — start the local data bridge (with supervisor)
# usage:  powershell -File dsh-hud/start.ps1 [-Port 7788]
param([int]$Port = 7788)
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $PSScriptRoot

# --- Job 逃逸助手 ------------------------------------------------------------
# DSH 会把每条命令的整棵进程树塞进 KILL_ON_JOB_CLOSE 的 Job：从命令里 Start-Process
# 起的常驻进程会被连带杀掉，而且 Job 不空 → 命令永远不返回（表现为会话卡住、自动更新
# 的 task inspection 超时）。实测：Start-Process / explorer.exe 都会落进 Job，
# 只有 WMI Win32_Process.Create 能逃出去（进程挂在 WmiPrvSE 下）。
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
function Test-InJob {
  try {
    Add-Type -Namespace JobChk -Name Api -MemberDefinition @"
[System.Runtime.InteropServices.DllImport("kernel32.dll", SetLastError=true)]
public static extern System.IntPtr OpenProcess(uint a, bool i, int pid);
[System.Runtime.InteropServices.DllImport("kernel32.dll", SetLastError=true)]
public static extern bool IsProcessInJob(System.IntPtr h, System.IntPtr job, out bool r);
[System.Runtime.InteropServices.DllImport("kernel32.dll", SetLastError=true)]
public static extern bool CloseHandle(System.IntPtr h);
"@ -ErrorAction SilentlyContinue
    $h = [JobChk.Api]::OpenProcess(0x0400, $false, $PID)
    if ($h -eq [IntPtr]::Zero) { return $false }
    $inJob = $false
    [void][JobChk.Api]::IsProcessInJob($h, [IntPtr]::Zero, [ref]$inJob)
    [void][JobChk.Api]::CloseHandle($h)
    return $inJob
  } catch { return $false }
}
function Test-UnderDsh {
  # 沿父进程链最多看 8 层，碰到 DeepSeek Harness 就是"被 DSH 命令拉起的"
  $cur = Get-CimInstance Win32_Process -Filter "ProcessId=$PID" -ErrorAction SilentlyContinue
  for ($i = 0; $i -lt 8; $i++) {
    if (-not $cur -or -not $cur.ParentProcessId) { return $false }
    $cur = Get-CimInstance Win32_Process -Filter "ProcessId=$($cur.ParentProcessId)" -ErrorAction SilentlyContinue
    if (-not $cur) { return $false }
    if ($cur.Name -match '^DeepSeek Harness|^dsh') { return $true }
  }
  return $false
}
# ---------------------------------------------------------------------------

# 1) 已经有别的守护在跑 → 退出；否则无论端口是否占用都留下来守护
$others = @(Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object {
  $_.ProcessId -ne $PID -and $_.CommandLine -match '-File .*dsh-hud\\start\.ps1'
})
if ($others.Count -gt 0) { exit 0 }

# 2) 如果本脚本是在 DSH 命令里被拉起的（Job 内 / DSH 环境变量存在），改为 WMI 重拉并立即退出，
#    避免把命令卡住、也避免服务被 DSH 的 Job 连带杀掉
$inDsh = Test-UnderDsh
if ($inDsh) {
  $self = '"' + $PSCommandPath + '"'
  Start-Detached -File 'powershell.exe' -Arguments ('-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ' + $self) | Out-Null
  exit 0
}
$env:HUD_PORT = "$Port"
$log = Join-Path $PSScriptRoot 'server.log'

function Log($msg) {
  $line = '[{0}] {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $msg
  Add-Content -Path $log -Value $line -Encoding UTF8
  Write-Host $line -ForegroundColor DarkGray
}

Write-Host "DSH HUD starting on http://127.0.0.1:$Port/" -ForegroundColor Cyan

# 顺手把壁纸落到正确的屏幕（iPad/spacedesk 优先，否则主屏），不再写死显示器编号
$fix = Join-Path $PSScriptRoot 'fix-wallpaper-screen.ps1'
if (Test-Path $fix) {
  Start-Detached -File 'powershell.exe' -Arguments ('-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "' + $fix + '" -Quiet -WaitLively 90') | Out-Null
}

# 解锁自动重载壁纸（只起一个）
$unlock = Join-Path $PSScriptRoot 'unlock-reload.ps1'
$running = Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object { $_.CommandLine -like '*unlock-reload.ps1*' }
if (-not $running -and (Test-Path $unlock)) {
  Start-Detached -File 'powershell.exe' -Arguments ('-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "' + $unlock + '"') | Out-Null
  Log 'unlock watcher started'
}

# 确保守护在跑（conhost --headless，无窗口）；node 由 daemon.ps1 负责看护
$daemonPath = Join-Path $PSScriptRoot 'daemon.ps1'
$daemonRun = Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object { $_.CommandLine -like '*daemon.ps1*' }
if (-not $daemonRun -and (Test-Path $daemonPath)) {
  Start-Detached -File 'conhost.exe' -Arguments ('--headless powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "' + $daemonPath + '"') | Out-Null
  Log 'daemon launched'
}
exit 0
