# 更新日志（CHANGELOG）

当前版本：**v1.30.0**（2026-11-13）
仓库：<https://github.com/ACyCar1o/dsh-hud-haloflux>

> 版本号以仓库根目录 [`VERSION`](VERSION) 为准。
> 升级方式：`git pull` 后重启后台（`dsh-hud\stack.ps1`），或直接覆盖解压 `DSH-HUD-portable.zip`。

---

## v1.30.0 — 多平台标题卡（跟随光环 · 连线 · 统一生命周期）（2026-11-13）

**卡片**
- 卡片改为「跟随光环」：位置由相机的光环投影逐帧计算，不再是固定坐标，镜头漂移时同步移动。
- 新增「圆点 + 连线」：光环边缘的圆点用一条细线连到卡片左边缘，跟随卡片走。
- 层叠方向改为向下右（下移 64px / 右移 34px / 逐层缩小），最多 3 张，最近活跃的在最前。
- 标题改为**模型名**（如 `DEEPSEEK FLASH`、`GPT 6 1 SOL`），正文为当前会话/对话标题。
- 全部文字白色/灰白，取消了彩色字与身份色。
- **统一生命周期**：最近 10 分钟内有活动就存在；60 秒后开始淡出，10 分钟归零消失。
- GPT 卡片去重（同模型只留一张），并使用 ChatGPT 窗口的**真实当前对话名**（UIA 读取）。

**数据**
- `/state` 与 SSE 推送补上 `codexThread`（当前会话标题 + 模型），页面不再回退到旧的命名线程。
- Codex 探针：从 rollout 读取模型，从 `session_index` / `state_5` 读取当前线程标题。
- ChatGPT 探针：读取窗口 Document 名称作为当前对话标题（如「干杂活」）。
- 余额改为**估算值**：官方快照 − 快照之后的消费，不再一直显示快照数字。
- 新增页面帧率上报（`/stats` 的 `pageFps`）与页面版本标记（`pageVer`）。

## v1.29.1 — 标题卡堆叠视觉打磨（2026-11-13）

- 卡片底色改为近乎不透明（.97），不再透出后层文字。
- 后层卡片只露一条「来源标签」，像一副牌；只有最前面那张显示完整标题与状态，信息更干净。
- 层间距 24→26px、缩放 0.93→0.92，纵深更明显。

## v1.29.0 — 多平台标题卡堆叠（2026-11-13）

**新增**
- 右上角新增「多卡堆叠」：每个活跃来源一张浮动标题卡
  （DSH 会话 / Codex / WorkBuddy / Claude Code / ChatGPT / Codex Hook 事件）。
- **谁最近操作谁浮最前**（全亮原尺寸）；其余按活跃度逐层缩小、上移、压暗，形成纵深，
  最多同时显示 3 张。
- 卡片身份色与「其他 AI」面板一致；标题过长自动省略；路径经过脱敏。
- 替换原来画布上的单行 callout（已隐藏），信息更集中但不挡光环。

**工程**
- 卡片用 DOM 节点复用 + CSS transform 过渡，重排时平滑滑动，不再整块重绘。
- 新增页面尺寸上报（`/stats` 的 `pageW/pageH/pageDpr`），便于排查缩放与裁切问题。

## v1.28.1 — 修复 Codex hooks.json 的 BOM 解析错误（2026-11-13）

- PowerShell 5.1 的 `Set-Content -Encoding UTF8` 会写入 BOM，Codex（Rust）解析 hooks.json 时
  报 `expected value at line 1 column 1`。
- 安装脚本改为 **UTF-8 无 BOM** 写入；已修正本机现有 `hooks.json`，并用严格解析器验证通过。
- 事件结构：`hooks -> <Event> -> [ { hooks: [ { type: command, command, async, timeout } ] } ]`。

## v1.28.0 — Codex Hooks 接入（2026-11-13）

**新增**
- `dsh-hud/codex-hook.mjs`：Codex Hook 转发器，读 stdin 事件 → `POST /hook`，1 秒内退出。
- `server.mjs`：新增 `POST /hook`，把事件写进 `/state` 的 `hook` / `hookLog` / `hookBusyUntil`。
- `bridge.js`：收到 `PreToolUse` 立即打光束；`Stop / Interrupt / UserPromptSubmit` 双脉冲；
  事件后 3–5 秒内保持活跃地板，不再依赖 500ms 轮询。
- `install-codex-hooks.ps1`：把 8 个事件注册进 `~/.codex/hooks.json`（自动备份、可 `-Uninstall`）。

**支持事件**
`UserPromptSubmit · PreModelRequest · PostModelRequest · PreToolUse · PostToolUse · PermissionRequest · Stop · Interrupt`

**验证**
本机 Codex CLI `0.167.0-alpha.4.1`，`hooks` 特性为 stable/true；`/hook` 模拟事件已能更新
`/state`，壁纸页已加载新桥。

## v1.27.0 — 文档、权益与发布记录整理（2026-11-13）

**文档**
- README（中/英）：作者与致谢、许可与权益表格、后台运行与自愈、相关项目（区分「实际使用」与「思路参考」）。
- INSTALL：安装步骤按当前无窗口守护架构更新，新增「后台结构与自愈」。
- `dsh-hud/README.md`：改为当前架构说明（服务 / 桥 / 探针 / 守护）。

**权益**
- `LICENSE` 与上游 HALOFLUX 逐字节一致（PolyForm Noncommercial 1.0.0 + Required Notice）。
- `NOTICE.md` 补全：商业用途明列项、壁纸平台转发 4 条要求、社交平台分享署名要求、音乐 CC0、历史版本说明。
- 项目元数据：Lively 与 Wallpaper Engine 工程均写入原作署名与来源链接；作者信息更新为 竹子Away（ACyCar1o）。

**截图**
- `docs/screenshots/` 全部重拍：整体画面、底部面板（含「其他 AI」与 CPU/GPU/内存状态行）、光环特写、播放器面板、演示 GIF。

**整理**
- 1.26.x 的文档补丁合并进本版本记录，发布历史按功能里程碑重新组织。

---

## v1.25–1.26 — 静默后台与仓库同步（2026-11-13）

- 后台改为**无窗口架构**：开机启动项 → `conhost --headless` → `daemon.ps1`（单实例、node 掉线自动拉起、Lively 掉线自动重开）。
- `start.ps1` 改为一次性设置（选屏 / 解锁监听 / 确保守护在跑），不再常驻。
- 新增 `stack.ps1`：清理重复实例、重启后台、自愈测试。
- 移除 VBS 守护方案与临时维护脚本，仓库只保留当前有效文件。
- 所有 PowerShell 脚本统一 UTF-8 BOM；开机启动项改为 ASCII，避免解析问题。

## v1.21 — 与 DSH 进程管理的兼容（2026-11-10）

- 说明并规避 DSH 的 Job 机制：常驻进程不从 DSH 命令内启动，改由开机启动项托管。
- 恢复脚本与安装脚本改为不阻塞调用方，避免命令挂起。

## v1.20 — ChatGPT 状态判定修正（2026-11-09）

- 只以「进行中」状态词判定忙碌，忽略历史耗时文字（如「思考了 16s」）。
- DSH 空闲时，「现在任务」可显示 ChatGPT 的实时状态。

## v1.19 — WorkBuddy 接入（2026-11-09）

- 读取 `~/.workbuddy/projects/*/*.jsonl` 事件流判定思考 / 工具 / 输出状态。
- 保留 OCR 探针作为无日志时的备用方案。

## v1.17–1.18 — 多 Agent 面板（2026-11-09）

- 底部新增「其他 AI」面板：Codex / WorkBuddy / Claude Code / ChatGPT 的身份色与状态。
- Codex 与 ChatGPT 同源去重；DSH 空闲时「现在任务」显示最活跃的外部 AI。

## v1.16 — 视觉精简（2026-11-09）

- 移除叠加相位环与音频心跳，画面回归纯光环。

## v1.15 — 状态与宿主数据（2026-11-09）

- 相位环（思考 / 工具 / 流式 / 等待）与 Lively 系统状态行、暂停休眠。
- 壁纸工程启用 `--system-information` 与 `--pause-event`。

## v1.14 — 恢复策略与隐私（2026-11-09）

- 取消自动 `reload`，改为每小时最多一次干净重启；新增 `recover-wallpaper.cmd` 手动恢复。
- 面板路径脱敏（只显示末两段）；60 秒无数据自动休眠。

## v1.13 — ChatGPT 思考状态（2026-11-09）

- 识别「思考中 / 正在思考 / 生成中 / 处理中」等状态词，思考阶段即联动光环。

## v1.12 — 页面缓存导致的假死（2026-11-09）

- 壁纸包装页每次加载强制新 URL，避免 WebView 命中旧页面导致画面定格。
- 增加页面状态上报（`pageHidden` / `pageErr` / `pageDbgAt`）便于排查。

## v1.11 — 锁屏 / 解锁与进程回收（2026-11-09）

- 新增解锁自动重载与孤儿 WebView 清理；页面切回前台若数据陈旧则自动重载。

## v1.10 — WebView 进程回收（2026-11-05）

- 看门狗加入退避：重载失败进入冷却，避免进程与显存累积。

## v1.8–v1.9 — 后台自愈（2026-11-05）

- 数据服务守护：崩溃自动重启，输出写入 `server.log`。
- 页面掉线 / 假死时自动恢复。

## v1.7 — 构图与运镜（2026-11-04）

- 画面整体左移，右侧留出更多光束空间；镜头加缓慢浮动与呼吸缩放。

## v1.6 — ChatGPT 代理模式（2026-11-04）

- 识别「操作电脑」代理模式，执行期间保持光环联动；清理旧文件。

## v1.5 — 过渡动画（2026-11-03）

- 活动度改为攻击 / 释放包络；帧率预算与参数平滑连续化；待命 14 fps。

## v1.4 — 布局与字体规范（2026-11-02）

- 底部面板两行布局；统一字号 / 字重层级；图表文字改为 DOM 渲染。
- 隐藏画面版权行与状态副标题（署名保留在文档中）。

## v1.3 — 可读性（2026-11-01）

- canvas 固定超采样、文字基线修正、字体栈统一；图表标签与柱状不再重叠。

## v1.1–v1.2 — 自动选屏与文档（2026-10-31）

- 自动选择 iPad（spacedesk）优先，否则主屏；插拔显示器无需手动设置。
- 新增安装脚本、迁移文档、演示 GIF 与英文 README。

## v1.0 — 首版（2026-10-29）

- HALOFLUX 视觉与 DSH 会话数据打通：事件速率 → 转速、工具调用 → 光束、报错 → 闪光。
- 数据服务（零 npm 依赖）、桥接脚本、媒体控制、ChatGPT 探针、底部数据面板。

---

## 已知注意事项

| 情况 | 说明 |
|---|---|
| 虚拟屏 / 高分屏被放大裁切 | 建议将该屏 Windows 缩放设为 100% |
| WebView2 进程数异常增多 | 重启 Lively 可回收；后台守护会在服务掉线时自愈 |
| 多显示器各挂动态壁纸 | 每块屏会增加一组 WebView 进程，显存线性增加 |
| 修改页面文件后 | `Lively.exe setwp --file reload` 重载；页面有自动重连 |
| 中文显示成方块 | 安装 MiSans 字体（缺省回退微软雅黑） |

## 许可

- 视觉：HALOFLUX by Ryder191（RYDER CODE / Ms MAIKEBAIs CAT），PolyForm Noncommercial 1.0.0 — **禁止任何商业用途**
- 二次开发脚本：MIT（见 `LICENSE-MIT`）
- 完整条款见 [NOTICE.md](NOTICE.md) 与 [LICENSE](LICENSE)
