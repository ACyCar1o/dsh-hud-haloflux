# 清理"孤儿" WebView2 进程（父进程已退出的壁纸 WebView）
# 反复 reload 壁纸会留下不退出的一组 WebView2 进程，长期累积会吃掉几个 GB 显存。
# 这个脚本只清理：命令行里带 Lively / dshhaloflux / 127.0.0.1:7788，且父进程已不存在的进程。

$ErrorActionPreference = 'SilentlyContinue'
$alive = @{}
Get-Process | ForEach-Object { $alive[[int]$_.Id] = $true }

$killed = 0
$total = 0
Get-CimInstance Win32_Process -Filter "Name='msedgewebview2.exe'" | ForEach-Object {
  $total++
  if ($_.CommandLine -match 'Lively|dshhaloflux|127\.0\.0\.1:7788') {
    $parentAlive = $alive.ContainsKey([int]$_.ParentProcessId)
    if (-not $parentAlive) {
      Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
      $killed++
    }
  }
}
Write-Output ("webview2 total={0} killed={1}" -f $total, $killed)
