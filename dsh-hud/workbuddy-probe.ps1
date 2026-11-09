# WorkBuddy 状态探针（OCR）
# WorkBuddy 是 Electron 应用，界面走 Chromium 渲染，UI Automation 读不到文字。
# 这里用 PrintWindow 抓窗口位图 + Windows OCR，识别「思考中 / 深度思考 / 生成回复中」等状态。
# 输出单行 JSON：{ name, running, state, busy, hit, visible }

$ErrorActionPreference = 'SilentlyContinue'
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Runtime.WindowsRuntime

Add-Type @"
using System;
using System.Text;
using System.Runtime.InteropServices;
public class WbCap {
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr h, IntPtr hdc, uint flags);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr h);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc cb, IntPtr p);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  public delegate bool EnumProc(IntPtr h, IntPtr p);
  public struct RECT { public int Left, Top, Right, Bottom; }
}
"@

function Out-Json($o) { $o | ConvertTo-Json -Compress -Depth 4 }

$pids = @(Get-Process WorkBuddy -ErrorAction SilentlyContinue | ForEach-Object { $_.Id })
if ($pids.Count -eq 0) { Out-Json ([ordered]@{ name='WorkBuddy'; running=$false; state='未运行'; busy=$false; hit=''; visible=$false }); exit 0 }

# 找可见的 WorkBuddy 主窗口
$script:best = $null
$cb = [WbCap+EnumProc]{
  param($h, $l)
  $pid2 = 0
  [void][WbCap]::GetWindowThreadProcessId($h, [ref]$pid2)
  if ($pids -contains [int]$pid2 -and [WbCap]::IsWindowVisible($h)) {
    $sb = New-Object System.Text.StringBuilder 512
    [void][WbCap]::GetWindowText($h, $sb, 512)
    if ($sb.ToString() -eq 'WorkBuddy') {
      $r = New-Object WbCap+RECT
      [void][WbCap]::GetWindowRect($h, [ref]$r)
      $w = $r.Right - $r.Left; $hh = $r.Bottom - $r.Top
      if ($w -gt 400 -and $hh -gt 300) { $script:best = @{ h = $h; w = $w; h2 = $hh } }
    }
  }
  return $true
}
[void][WbCap]::EnumWindows($cb, [IntPtr]::Zero)

if (-not $script:best) {
  Out-Json ([ordered]@{ name='WorkBuddy'; running=$true; state='窗口不可见'; busy=$false; hit=''; visible=$false })
  exit 0
}

# 抓图（PrintWindow flag=2 对 Chromium 有效）
$r = New-Object WbCap+RECT
[void][WbCap]::GetWindowRect($script:best.h, [ref]$r)
$w = $r.Right - $r.Left; $hh = $r.Bottom - $r.Top
if ($w -lt 200 -or $hh -lt 200) { Out-Json ([ordered]@{ name='WorkBuddy'; running=$true; state='窗口过小'; busy=$false; hit=''; visible=$true }); exit 0 }
$bmp = New-Object System.Drawing.Bitmap $w, $hh
$g = [System.Drawing.Graphics]::FromImage($bmp)
$hdc = $g.GetHdc()
$ok = [WbCap]::PrintWindow($script:best.h, $hdc, 2)
$g.ReleaseHdc($hdc)
$g.Dispose()
$tmp = Join-Path $env:TEMP ('wb-probe-' + [guid]::NewGuid().ToString('N').Substring(0, 8) + '.png')
$bmp.Save($tmp, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
if (-not $ok) { Remove-Item $tmp -Force -ErrorAction SilentlyContinue }

# OCR
$text = ''
try {
  $asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object {
      $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'
    })[0]
  function Await($t, $rt) { $asTask = $asTaskGeneric.MakeGenericMethod($rt); $nt = $asTask.Invoke($null, @($t)); $nt.Wait(-1) | Out-Null; $nt.Result }
  [Windows.Storage.StorageFile, Windows.Storage, ContentType = WindowsRuntime] | Out-Null
  [Windows.Graphics.Imaging.BitmapDecoder, Windows.Graphics.Imaging, ContentType = WindowsRuntime] | Out-Null
  [Windows.Media.Ocr.OcrEngine, Windows.Foundation, ContentType = WindowsRuntime] | Out-Null
  $engine = [Windows.Media.Ocr.OcrEngine]::TryCreateFromUserProfileLanguages()
  if ($engine) {
    $file = Await ([Windows.Storage.StorageFile]::GetFileFromPathAsync($tmp)) ([Windows.Storage.StorageFile])
    $stream = Await ($file.OpenAsync([Windows.Storage.FileAccessMode]::Read)) ([Windows.Storage.Streams.IRandomAccessStream])
    $decoder = Await ([Windows.Graphics.Imaging.BitmapDecoder]::CreateAsync($stream)) ([Windows.Graphics.Imaging.BitmapDecoder])
    $sbmp = Await ($decoder.GetSoftwareBitmapAsync()) ([Windows.Graphics.Imaging.SoftwareBitmap])
    $res = Await ($engine.RecognizeAsync($sbmp)) ([Windows.Media.Ocr.OcrResult])
    $text = ($res.Lines | ForEach-Object { $_.Text }) -join ''
  }
} catch {}
Remove-Item $tmp -Force -ErrorAction SilentlyContinue

# CJK 之间常有空格，去掉再匹配
$norm = $text -replace '\s+', ''
$BUSY = '思考中|正在思考|深度思考|生成回复中|正在生成|生成中|处理中|正在处理|正在运行|停止生成|运行代码中'
$hit = ''
if ($norm -match $BUSY) { $hit = $Matches[0] }
$busy = [bool]$hit
$state = '空闲'
if ($hit) { $state = if ($hit -match '思考') { '思考中' } elseif ($hit -match '回复|生成') { '生成中' } else { '处理中' } }

# 附一点最近内容，便于面板显示
$detail = ''
$m = [regex]::Match($norm, '需要我做点什么.{0,30}')
if (-not $m.Success) { $m = [regex]::Match($norm, '已完成[\dSs]{0,4}') }
if ($m.Success) { $detail = $m.Value }

Out-Json ([ordered]@{ name='WorkBuddy'; running=$true; state=$state; busy=$busy; hit=$hit; visible=$true; detail=$detail })
