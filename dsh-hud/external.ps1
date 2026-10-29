param([string]$OutFile = '')
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
Add-Type -AssemblyName System.Runtime.WindowsRuntime
Add-Type @"
using System;
using System.Text;
using System.Collections.Generic;
using System.Runtime.InteropServices;
public class ExtWin2 {
  public delegate bool EnumProc(IntPtr hWnd, IntPtr lParam);
  [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc cb, IntPtr lp);
  [DllImport("user32.dll")] public static extern int GetClassName(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr hwnd, IntPtr hdcBlt, uint nFlags);
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L, T, R, B; }
  public static List<string> Windows(uint[] pids) {
    var set = new HashSet<uint>(pids);
    var list = new List<string>();
    EnumWindows((h, l) => {
      uint p; GetWindowThreadProcessId(h, out p);
      if (!set.Contains(p)) return true;
      var cn = new StringBuilder(128); GetClassName(h, cn, 128);
      RECT r; GetWindowRect(h, out r);
      int w = r.R - r.L, hh = r.B - r.T;
      if (cn.ToString().StartsWith("Chrome_WidgetWin") && w > 500 && hh > 300)
        list.Add(h.ToInt64() + "|" + w + "|" + hh + "|" + IsWindowVisible(h));
      return true;
    }, IntPtr.Zero);
    return list;
  }
}
"@

$asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object {
    $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'
  })[0]
function Await($WinRtTask, $ResultType) {
  $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
  $netTask = $asTask.Invoke($null, @($WinRtTask))
  $netTask.Wait(-1) | Out-Null
  $netTask.Result
}
[Windows.Storage.StorageFile, Windows.Storage, ContentType = WindowsRuntime] | Out-Null
[Windows.Graphics.Imaging.BitmapDecoder, Windows.Graphics.Imaging, ContentType = WindowsRuntime] | Out-Null
[Windows.Media.Ocr.OcrEngine, Windows.Foundation, ContentType = WindowsRuntime] | Out-Null
$ocrEngine = $null
try { $ocrEngine = [Windows.Media.Ocr.OcrEngine]::TryCreateFromUserProfileLanguages() } catch {}

function Get-OcrText([string]$file) {
  if (-not $ocrEngine) { return '' }
  $f = Await ([Windows.Storage.StorageFile]::GetFileFromPathAsync($file)) ([Windows.Storage.StorageFile])
  $stream = Await ($f.OpenAsync([Windows.Storage.FileAccessMode]::Read)) ([Windows.Storage.Streams.IRandomAccessStream])
  $dec = Await ([Windows.Graphics.Imaging.BitmapDecoder]::CreateAsync($stream)) ([Windows.Graphics.Imaging.BitmapDecoder])
  $bmp = Await ($dec.GetSoftwareBitmapAsync()) ([Windows.Graphics.Imaging.SoftwareBitmap])
  $res = Await ($ocrEngine.RecognizeAsync($bmp)) ([Windows.Media.Ocr.OcrResult])
  return (($res.Lines | ForEach-Object { $_.Text }) -join "`n")
}

function Capture-Window([IntPtr]$hwnd, [string]$file) {
  $rect = New-Object ExtWin2+RECT
  [void][ExtWin2]::GetWindowRect($hwnd, [ref]$rect)
  $w = $rect.R - $rect.L; $h = $rect.B - $rect.T
  if ($w -le 0 -or $h -le 0) { return $false }
  $bmp = New-Object System.Drawing.Bitmap $w, $h
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $hdc = $g.GetHdc()
  [void][ExtWin2]::PrintWindow($hwnd, $hdc, 2)
  $g.ReleaseHdc($hdc); $g.Dispose()
  $bmp.Save($file, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
  return $true
}

$BLOCK = '^(返回|前进|跳转到内容|隐藏侧边栏|显示侧边栏|应用程序菜单|文件|编辑|视图|帮助|应用导航|首页|图像|定时任务|资料库|插件|探索|代码审查|GPT|地图|站点|项目|用量|有可用更新|打开个人资料菜单|切换模式.*|询问 ChatGPT|选择 ChatGPT 模型|ChatGPT 可能会出错.*|为项目、作品集.*|关闭 ChatGPT 信标横幅|新建聊天|搜索|.*创建新聊天|已归档.*|跳转.*)$'

function Get-ChatGptInfo {
  $pids = @(Get-Process -Name ChatGPT -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Id)
  if ($pids.Count -eq 0) { return [ordered]@{ name='ChatGPT'; running=$false; state='未运行'; snippet=''; work='' } }
  $wins = [ExtWin2]::Windows([uint32[]]$pids)
  $fg = [ExtWin2]::GetForegroundWindow().ToInt64()
  $best = $wins | Sort-Object { [int](($_ -split '\|')[1]) } -Descending | Select-Object -First 1
  $state = '后台'
  if ($best) {
    $parts = $best -split '\|'
    if ($parts[3] -eq 'True') { $state = '已打开' }
    if ($parts[0] -eq "$fg") { $state = '使用中' }
  }
  $snippet = ''; $work = ''
  if ($best) {
    try {
      $h = [IntPtr][int64](($best -split '\|')[0])
      $el = [System.Windows.Automation.AutomationElement]::FromHandle($h)
      $all = $el.FindAll([System.Windows.Automation.TreeScope]::Descendants, [System.Windows.Automation.Condition]::TrueCondition)
      $kept = New-Object System.Collections.ArrayList
      for ($i = 0; $i -lt $all.Count; $i++) {
        $n = $all[$i].Current.Name
        if (-not $n) { continue }
        $n = ($n -replace '\s+', ' ').Trim()
        if ($n.Length -lt 12) { continue }
        if ($n -match $BLOCK) { continue }
        if ($n -match '^Worked for (.+)$') { $work = $Matches[1]; continue }
        [void]$kept.Add($n)
      }
      $tail = @($kept | Select-Object -Last 2)
      $snippet = ($tail -join ' / ')
      if ($snippet.Length -gt 120) { $snippet = $snippet.Substring(0, 118) + '...' }
    } catch {}
  }
  return [ordered]@{ name='ChatGPT'; running=$true; state=$state; snippet=$snippet; work=$work }
}

$apps = @()
try { $apps += Get-ChatGptInfo } catch { $apps += [ordered]@{ name='ChatGPT'; running=$false; state='读取失败'; snippet=''; work='' } }

$json = [ordered]@{ at = [DateTimeOffset]::Now.ToUnixTimeMilliseconds(); apps = $apps } | ConvertTo-Json -Depth 6 -Compress
if ($OutFile) {
  [System.IO.File]::WriteAllText($OutFile, $json, (New-Object System.Text.UTF8Encoding($false)))
} else {
  Write-Output $json
}
