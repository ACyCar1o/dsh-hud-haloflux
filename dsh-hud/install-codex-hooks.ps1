# 把 dsh-hud 注册成 Codex 的 Hook（用户级，可回滚）
# 用法：powershell -NoProfile -ExecutionPolicy Bypass -File dsh-hud\install-codex-hooks.ps1
#
# 作用：在 %USERPROFILE%\.codex\hooks.json 里追加 dsh-hud 的 Hook 组，
#       Codex 的 PreToolUse / PostToolUse / Stop 等事件会调用 codex-hook.mjs，
#       再把事件转发给 127.0.0.1:7788/hook，壁纸据此即时响应。
#
# 回滚：
#   - 本脚本会先把原 hooks.json 备份成 hooks.json.bak-<时间戳>
#   - 或运行本脚本 -Uninstall 移除 dsh-hud 的条目

param([switch]$Uninstall)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME '.codex' }
$hooksPath = Join-Path $codexHome 'hooks.json'
$hookScript = Join-Path $here 'codex-hook.mjs'

$node = (Get-Command node.exe -ErrorAction SilentlyContinue).Source
if (-not $node) { throw '找不到 node.exe，请先安装 Node.js（本项目需要）' }
if (-not (Test-Path $hookScript)) { throw "找不到 $hookScript" }
if (-not (Test-Path $codexHome)) { throw "找不到 Codex 目录：$codexHome（先打开一次 Codex）" }

$events = @('UserPromptSubmit','PreModelRequest','PostModelRequest','PreToolUse','PostToolUse','PermissionRequest','Stop','Interrupt')
$command = '"{0}" "{1}"' -f $node, $hookScript
$marker = 'codex-hook.mjs'

# 读现有 hooks.json（可能不存在）
$doc = $null
if (Test-Path $hooksPath) {
  $raw = Get-Content $hooksPath -Raw -Encoding UTF8
  if ($raw.Trim()) {
    try { $doc = $raw | ConvertFrom-Json } catch { throw "现有 hooks.json 不是合法 JSON：$_" }
  }
}
if (-not $doc) { $doc = [pscustomobject]@{} }
if (-not $doc.PSObject.Properties['hooks']) {
  $doc | Add-Member -NotePropertyName hooks -NotePropertyValue ([pscustomobject]@{})
}

# 先备份
if (Test-Path $hooksPath) {
  $backup = $hooksPath + '.bak-' + (Get-Date -Format 'yyyyMMdd-HHmmss')
  Copy-Item $hooksPath $backup -Force
  Write-Host "已备份：$backup"
}

function Test-OurGroup($group) {
  foreach ($h in $group.hooks) {
    if ($h.command -and ($h.command -match [regex]::Escape($marker))) { return $true }
  }
  return $false
}

if ($Uninstall) {
  foreach ($ev in $events) {
    if (-not $doc.hooks.PSObject.Properties[$ev]) { continue }
    $kept = @()
    foreach ($g in $doc.hooks.$ev) { if (-not (Test-OurGroup $g)) { $kept += $g } }
    if ($kept.Count -eq 0) { $doc.hooks.PSObject.Properties.Remove($ev) }
    else { $doc.hooks.$ev = $kept }
  }
  ($doc | ConvertTo-Json -Depth 20) | Set-Content -Path $hooksPath -Encoding UTF8
  Write-Host '已移除 dsh-hud 的 Codex Hooks。'
  Write-Host '（Codex 里可能需要重新加载一次会话）'
  exit 0
}

# 追加：每个事件一个 matcher 组，组内一个 command handler
$added = 0
foreach ($ev in $events) {
  if (-not $doc.hooks.PSObject.Properties[$ev]) {
    $doc.hooks | Add-Member -NotePropertyName $ev -NotePropertyValue @()
  }
  $existing = @($doc.hooks.$ev)
  $ours = $existing | Where-Object { Test-OurGroup $_ }
  if ($ours) { continue }   # 已存在，不重复加
  $group = [pscustomobject]@{
    hooks = @([pscustomobject]@{
      type = 'command'
      command = $command
      async = $true
      timeout = 1
    })
  }
  $doc.hooks.$ev = @($existing + $group)
  $added++
}

($doc | ConvertTo-Json -Depth 20) | Set-Content -Path $hooksPath -Encoding UTF8
Write-Host "已写入 $hooksPath（新增 $added 个事件组）"
Write-Host ''
Write-Host '下一步（只需一次）：'
Write-Host '  1. 打开 Codex 桌面版 → 设置 → Hooks'
Write-Host '  2. 找到 dsh-hud 的条目，点“信任 / Trust”'
Write-Host '  3. 新开一个 Codex 会话，随便跑个工具，壁纸应立即有反应'
Write-Host ''
Write-Host '回滚：powershell -File dsh-hud\install-codex-hooks.ps1 -Uninstall'
