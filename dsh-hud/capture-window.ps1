Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinCap {
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
  [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr hwnd, IntPtr hdcBlt, uint nFlags);
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }
}
"@
$targets = @(
  @{ Name = 'doubao';    Proc = 'Doubao' },
  @{ Name = 'chatgpt';   Proc = 'ChatGPT' },
  @{ Name = 'workbuddy'; Proc = 'WorkBuddy' }
)
foreach ($t in $targets) {
  $p = Get-Process -Name $t.Proc -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
  if (-not $p) { "$($t.Name): no window"; continue }
  $rect = New-Object WinCap+RECT
  [void][WinCap]::GetWindowRect($p.MainWindowHandle, [ref]$rect)
  $w = $rect.Right - $rect.Left; $h = $rect.Bottom - $rect.Top
  if ($w -le 0 -or $h -le 0) { "$($t.Name): bad rect"; continue }
  $bmp = New-Object System.Drawing.Bitmap $w, $h
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $hdc = $g.GetHdc()
  [void][WinCap]::PrintWindow($p.MainWindowHandle, $hdc, 2)
  $g.ReleaseHdc($hdc)
  $g.Dispose()
  $out = Join-Path $PSScriptRoot ("shots/other-ai-" + $t.Name + ".png")
  $bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
  "$($t.Name): pid=$($p.Id) ${w}x${h} -> $out"
}
