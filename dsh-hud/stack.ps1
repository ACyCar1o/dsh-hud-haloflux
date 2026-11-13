# 维护脚本 v2：用 conhost --headless 启动守护（真正无窗口）
# 背景：Win32_Process.Create 启动控制台程序会在 Windows Terminal 里开一个可见标签页，
#       conhost --headless 不会创建任何窗口。
$ErrorActionPreference = 'SilentlyContinue'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$daemon = Join-Path $here 'daemon.ps1'
$self = $PID

Add-Type @"
using System;
using System.Text;
using System.Runtime.InteropServices;
public class WQ {
  [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc cb, IntPtr p);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassName(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll")] public static extern bool PostMessage(IntPtr h, uint msg, IntPtr w, IntPtr l);
  public delegate bool EnumProc(IntPtr h, IntPtr p);
}
"@

function Get-TerminalWindows {
  $list = New-Object System.Collections.ArrayList
  $cb = [WQ+EnumProc]{
    param($h, $l)
    $cls = New-Object System.Text.StringBuilder 256
    [void][WQ]::GetClassName($h, $cls, 256)
    $c = $cls.ToString()
    if (($c -match 'CASCADIA|ConsoleWindowClass') -and [WQ]::IsWindowVisible($h)) {
      $t = New-Object System.Text.StringBuilder 512
      [void][WQ]::GetWindowText($h, $t, 512)
      $pid2 = 0
      [void][WQ]::GetWindowThreadProcessId($h, [ref]$pid2)
      [void]$list.Add([pscustomobject]@{ hwnd=$h; pid=$pid2; cls=$c; title=$t.ToString() })
    }
    return $true
  }
  [void][WQ]::EnumWindows($cb, [IntPtr]::Zero)
  return $list
}

Write-Host '=== 停掉 daemon / node ==='
Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" |
  Where-Object { $_.ProcessId -ne $self -and $_.CommandLine -like '*daemon.ps1*' } |
  ForEach-Object { Write-Host ("  kill daemon pid=" + $_.ProcessId); Stop-Process -Id $_.ProcessId -Force }
Get-CimInstance Win32_Process -Filter "Name='node.exe'" |
  Where-Object { $_.CommandLine -like '*dsh-hud*server.mjs*' } |
  ForEach-Object { Write-Host ("  kill node pid=" + $_.ProcessId); Stop-Process -Id $_.ProcessId -Force }
Start-Sleep -Seconds 3

Write-Host '=== 关闭残留的可见终端窗口（只关空标签/我们的）==='
Get-TerminalWindows | ForEach-Object {
  Write-Host ("  窗口: pid={0} cls={1} title='{2}'" -f $_.pid, $_.cls, $_.title)
}

Write-Host '=== 用 conhost --headless 启动守护（无窗口）==='
$cmd = 'conhost.exe --headless powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "' + $daemon + '"'
$r = ([wmiclass]'Win32_Process').Create($cmd)
Write-Host ("  start -> " + $r.ReturnValue)
Start-Sleep -Seconds 12

Write-Host '=== 结果 ==='
$ds = @(Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object { $_.CommandLine -like '*daemon.ps1*' })
$nodes = @(Get-CimInstance Win32_Process -Filter "Name='node.exe'" | Where-Object { $_.CommandLine -like '*dsh-hud*server.mjs*' })
Write-Host ("daemon={0} node={1}" -f $ds.Count, $nodes.Count)
$l = Get-NetTCPConnection -LocalPort 7788 -State Listen -ErrorAction SilentlyContinue
if ($l) {
  Write-Host ("7788 up pid=" + $l.OwningProcess)
  try {
    $s = Invoke-RestMethod 'http://127.0.0.1:7788/stats' -TimeoutSec 6
    Write-Host ("service: clients={0} hidden={1}" -f $s.clients, $s.pageHidden)
  } catch { Write-Host 'stats FAIL' }
} else { Write-Host '7788 DOWN' }
Write-Host '=== 可见终端窗口（应为 0）==='
Get-TerminalWindows | ForEach-Object { Write-Host ("  仍有: pid={0} title='{1}'" -f $_.pid, $_.title) }
