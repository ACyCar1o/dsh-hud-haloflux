# 锁屏解锁后自动重载壁纸
# 由 start.ps1 以隐藏窗口方式启动一次，常驻后台。
# 原理：订阅 Windows 的 SessionSwitch 事件，检测到 SessionUnlock 就重载 Lively 壁纸，
# 避免锁屏后 WebView 被挂起、解锁回来画面定格。

$ErrorActionPreference = 'SilentlyContinue'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$log = Join-Path $PSScriptRoot 'unlock-reload.log'
function Log($m) {
  Add-Content -Path $log -Value ('[{0}] {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $m) -Encoding UTF8
}

$LIVELY = 'C:\Program Files\Lively Wallpaper\Lively.exe'
Log 'unlock watcher started'

[Microsoft.Win32.SystemEvents]::add_SessionSwitch({
  param($sender, $e)
  try {
    Log ("session switch: " + $e.Reason)
    if ($e.Reason -eq [Microsoft.Win32.SessionSwitchReason]::SessionUnlock) {
      Start-Sleep -Seconds 2
      if (Test-Path $LIVELY) {
        & $LIVELY setwp --file reload 2>&1 | Out-Null
        Log 'wallpaper reloaded after unlock'
        # reload 会遗留 WebView2 进程，等 20 秒后清掉
        Start-Sleep -Seconds 20
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'cleanup-webviews.ps1') 2>&1 | Out-Null
        Log 'orphan webviews cleaned after unlock'
      }
    }
  } catch { Log ('error: ' + $_.Exception.Message) }
})

# 没有消息泵时 SystemEvents 不会派发，这里手动泵一下
while ($true) {
  [System.Windows.Forms.Application]::DoEvents()
  Start-Sleep -Milliseconds 400
}
