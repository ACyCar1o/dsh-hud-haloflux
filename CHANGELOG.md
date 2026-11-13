# 更新日志（CHANGELOG）

当前版本：**v1.26.8**（2026-11-13）
仓库：<https://github.com/ACyCar1o/dsh-hud-haloflux>

> 升级方式：`git pull` 后重启服务（或重新解压 `DSH-HUD-portable.zip` 覆盖）；
> 壁纸页会自动重连，不需要手动改 Lively。

---

## v1.26.8 — NOTICE 补上原作 B 站/视频链接（2026-11-13）

- 修正 v1.26.7 里 NOTICE 未替换成功的一行：原作信息块现在包含
  中文网名「麦克白夫人的猫」、B 站主页 <https://space.bilibili.com/485939159>、
  原作演示视频 <https://www.bilibili.com/video/BV1dhn163E2V>。
- 项目作者仍为 竹子Away（ACyCar1o）· <https://space.bilibili.com/8124574>。

## v1.26.7 — 作者与原作身份信息补全（2026-11-13）

- 本项目作者：**竹子Away（ACyCar1o）** · B 站 <https://space.bilibili.com/8124574>
- 视觉原作补充身份：Ryder191（RYDER CODE / Ms MAIKEBAIs CAT），中文网名 **麦克白夫人的猫**；
  B 站主页 <https://space.bilibili.com/485939159>；原作演示视频 <https://www.bilibili.com/video/BV1dhn163E2V>
- 同步更新：README（中/英）、NOTICE、`dsh-hud/README.md`、`wall-proj/LivelyInfo.json`、`wall-proj/project.json`。
- `LICENSE` 保持与上游逐字节一致，未做改动。

## v1.26.6 — 按原作 LICENSE 原文校正权益说明（2026-11-13）

**重要修正（原来不合规）**
- 仓库里的 `LICENSE` 是**旧版/裁剪版**（7988 字节），缺少上游后来新增的两大章节：
  「转发到壁纸平台」与「分享视频/截图/帖子」，也不含完整 Required Notice。
- 现在 `LICENSE` 与 `haloflux/LICENSE` 都已替换为 **上游原文（10278 字符，逐字节一致）**。

**NOTICE 重写**
- 补全「商业用途」明列项：公司内部/代表公司、集成商业产品、接单有偿、出售产出（付费壁纸/模板/素材/视频）、
  商业广告与推广；原作不提供商业授权。
- 补全壁纸平台转发的 4 条硬性要求（简介两行署名、不得冒充、不得盈利、附带 LICENSE）。
- 补全社交平台分享要求（B 站/抖音/小红书/YouTube/X）：**文案/标题/简介**直接注明来源，
  不能只放评论区；无链接时写 `GitHub：Ryder191/haloflux`；未注明不在许可范围。
- 补背景音乐 CC0（cynicmusic / OpenGameArt）与「2026-10-26 前版本曾为 MIT」的说明。

**元数据**
- `wall-proj/project.json` 描述写入 Required Notice 两行（Wallpaper Engine 平台要求）。
- `wall-proj/LivelyInfo.json` 的描述也带上原作署名。

## v1.26.5 — 权益与署名补全（2026-11-13）

**补全**
- README（中/英）新增「作者与致谢」与「许可与权益」表格：明确视觉 / 脚本 / 音乐 / 数据四类权益与商用限制。
- 作者信息：ACyCar1o · B 站主页 <https://space.bilibili.com/8124574> · GitHub。
- `NOTICE.md` 增加本项目作者与仓库，并修正「画布署名行请勿移除」的过时说明
  （署名默认隐藏，`SHOW_CREDIT=true` 可恢复）。
- `wall-proj/LivelyInfo.json`：`Author` 由占位的 `dsh-hud` 改为 `ACyCar1o`，补 `Contact`(B 站) 与 `License`。
- `wall-proj/project.json`：描述里补 HALOFLUX 原作署名与仓库链接、本项目作者（Wallpaper Engine 转载要求）。
- 新增「相关项目」章节（Ryder191 / Ke-wood / Michael-ZAG / b1ub1u / agent-halo）。
- 重写 `dsh-hud/README.md`：改为当前架构（daemon / stack / agents），不再保留过期说明。

## v1.26.4 — 修掉 README 版本行过期 + 截图破缓存（2026-11-13）

**修复**
- README / README.en 顶部版本行一直停在 `v1.25.0`（发版时漏更新）：改为直接指向 `VERSION` 文件，
  以后不会再出现"版本号过期"。
- GitHub 图片 CDN（camo）会按 URL 缓存，替换同名图片后网页仍显示旧图；把 5 张截图改为
  `overview-2.png` / `panels-2.png` / `ring-2.png` / `player-2.png` / `demo-2.gif`，强制刷新。

## v1.26.3 — 清理误提交文件（2026-11-13）

- 移除仓库根目录误提交的 `安装DSH更新.cmd`（早期手动更新 DSH 用的临时脚本，与壁纸无关）。

## v1.26.2 — README 图片引用与说明文字对齐（2026-11-13）

**文档**
- 新增 `overview.png` 作为首图（此前图片没被引用）；`demo.gif` 下移为动图示例。
- 所有截图补上说明文字，明确标注「其他 AI」面板与 `CPU · GPU · 内存` 状态行。
- 开头介绍补上 Codex / WorkBuddy / Claude Code / ChatGPT 数据源。
- `README.en.md` 同步同样的图片与说明。

## v1.26.1 — 补齐截图工具（2026-11-13）

- 把 `docs-shots.mjs` / `docs-player-shot.mjs` 提交进仓库（v1.26.0 只提交了图片）。

---

## v1.26.0 — 文档截图与演示 GIF 全部重拍（2026-11-13）

**更新**
- `docs/screenshots/overview.png`：1920×1080 全屏，包含「其他 AI」面板与
  「现在任务」里的 `CPU · GPU · 内存` 系统状态行。
- `panels.png`：底部两行面板（现在任务 / 工具调用 / 事件速率 / 工具分布 +
  进度 / 用量费用 / 会话工作台 / 今日之最 / 其他 AI）。
- `ring.png`：光环主体特写（不含面板）。
- `player.png`：本地播放器面板（真实播放的曲目信息）。
- `demo.gif`：36 帧原始序列压缩为 18 帧 / 900×506 / 3.0 MB，画面是真实运行状态。

**工具**
- 新增 `dsh-hud/docs-shots.mjs`、`dsh-hud/docs-player-shot.mjs`：headless Chrome + CDP
  截图与录帧，注入宿主系统状态（headless 无 Lively 宿主 API）。

## v1.25.2 — 守护增强：严格单实例 + Lively 看护（2026-11-13）

**修复**
- 守护的单实例检查改为**严格匹配 `-File …daemon.ps1`**：之前用宽泛匹配，会被任何"命令行文本里含 daemon.ps1"
  的 PowerShell（例如调试命令）误判成"已有实例"而直接退出 → 服务起不来。
- 守护每 ~60 秒检查一次 Lively 进程：被意外关闭或崩溃会**自动重新拉起**（GUI 程序，无控制台窗口）。

**效果**
- `daemon=1 node=1` 稳定；Lively 掉线也会自愈，不再需要手动点。

## v1.25.1 — 清理残留引用（2026-11-13）

**修复**
- `start.ps1` 里还在引用已删除的 `watchdog.ps1` / `supervise-node.vbs` / `watchdog.vbs`：
  改为确保 `daemon.ps1` 在跑（同样走 `conhost --headless`，无窗口）。
- 删除已被 `stack.ps1` 取代的 `restart-stack.ps1`，以及 VBS 时代的 `watchdog.ps1`。
- 仓库内已无任何 VBS 引用。

## v1.25.0 — 仓库与文档全面同步（2026-11-13）

**同步**
- 运行时最新的 `daemon.ps1`（文件锁单实例 + 隐藏拉起 node）、`stack.ps1`（维护/自愈测试）、
  `watchdog.ps1` 已同步进仓库。
- 删除已废弃的 `launch-node.vbs` / `supervise-node.vbs` / `watchdog.vbs` / `run-node.cmd`
  （VBS 方案已由 PowerShell 守护替代）。

**文档**
- README：更新特性清单（多 AI 面板、系统状态、路径脱敏、空闲休眠、静默后台）；
  新增「后台运行与自愈」章节与启动链图；目录表补 `agents.mjs` / `workbuddy-probe.ps1` /
  `daemon.ps1` / `stack.ps1`；架构图加入 Codex/WorkBuddy/Claude 数据源；性能数据更新。
- INSTALL：安装步骤改为"写自启 + 无窗口守护"，补「后台结构与自愈」章节；
  常见问题改为 `recover-wallpaper.cmd` / `stack.ps1` 的排查路径。
- `.gitignore`：忽略日志、`daemon.lock`、探针缓存、备份文件。

## v1.24.1 — 移除已废弃的计划任务脚本（2026-11-13）

**清理**
- 删除 `setup-hud-task.cmd` / `setup-hud-task.ps1`（桌面与仓库均移除）。
  它们是为旧的 VBS 守护方案写的，且文件用 LF 换行 + 无 BOM：
  cmd 只认 CRLF，所以双击会"闪退"；PowerShell 5.1 也会把中文注释读成乱码。
- 当前启动链已不需要管理员/计划任务：登录 → 单个 ASCII `dsh-hud-start.vbs`
  → `conhost --headless powershell -File daemon.ps1`（零窗口、单实例、掉线自愈）。

## v1.24.0 — 彻底去掉 VBS / 无窗口后台（2026-11-13）

**问题**
- 之前两个 `.vbs` 文件被我写成了"缺少 BOM 的 UTF-16"，wscript 解析失败 → 每次开机弹两个
  「Windows Script Host：无效字符（800A0408）」报错框；你看到的"开机两个黑窗口"就是它。
- 另外用 `Win32_Process.Create` 启动控制台程序时，Windows 11 会在 Windows Terminal 里
  开一个可见标签页（黑色空窗口）——这是我手动重启守护时弹出的那个。

**修复**
- 删除 `supervise-node.vbs` / `watchdog.vbs` / `launch-node.vbs`，改为纯 PowerShell：
  - `dsh-hud/daemon.ps1`：单实例（mutex + 文件锁兜底），node 掉线 3 秒重启，
    输出写 `server.log` / `server.stdout.log`；
  - 开机自启只保留一个 ASCII 的 `dsh-hud-start.vbs`，用
    `conhost.exe --headless powershell.exe ... -File daemon.ps1` 启动（**零窗口**）。
- 所有 `.ps1` 统一加 UTF-8 BOM（之前有脚本因无 BOM 在 PS 5.1 下解析乱码）。

**验证**
- 可见终端窗口数 = 0；daemon 1 个、node 1 个；杀 node 后 12 秒自动拉起。

## v1.23.0 — 全静默后台：VBS 无窗口守护（2026-11-11）

**修复"弹黑窗 / 弹资源管理器"**
- 之前 node 由 `cmd /c run-node.cmd` 拉起，cmd 的控制台窗口会一直挂在那儿（node 活多久窗口留多久），
  而 node 偶尔崩溃触发重启 → 黑窗反复弹出。
- 现在改成两级 **VBS 隐藏启动**（wscript 本身没有控制台，内部 `Run cmd, 0` 再隐藏一次）：
  - `supervise-node.vbs`：node 的隐藏守护，崩溃后 3 秒拉起；
  - `watchdog.vbs`：每 30 秒 HTTP 探活，服务整体掉了就拉起守护。
- `start.ps1` 改为**一次性设置**（选屏 / 解锁监听 / 确保两个 VBS 在跑）后立即退出，不再常驻占用命令行。
- 开机自启 VBS 同步改写：只启动两个隐藏 VBS + 一次性设置，全程无窗口。
- 顺带清理桌面：更新相关临时脚本挪到 `DSH-更新留档` 文件夹。

**架构**
```
登录 → dsh-hud-start.vbs（隐藏）
        ├─ wscript supervise-node.vbs   （node 隐藏守护，崩溃3秒重启）
        ├─ wscript watchdog.vbs         （30秒 HTTP 探活，整体掉线时拉起守护）
        └─ powershell start.ps1（隐藏） （一次性：选屏 + 解锁监听）
```

## v1.22.0 — 计划任务方案（彻底独立于 DSH 进程树）（2026-11-11）

**新增**
- `dsh-hud/setup-hud-task.ps1` + `setup-hud-task.cmd`：以管理员身份注册两个 Windows 计划任务
  （`DSH-HUD-Service`、`DSH-HUD-Watchdog`），登录时启动、崩溃后每分钟自动重启；
  由任务计划托管后，壁纸服务**完全不再依赖 DSH 的进程树和 Job**。
- 修复守护脚本：端口已被占用时不再直接退出（之前会导致"没有守护"的空窗）。

**背景（这次崩溃的根因）**
- 昨夜 node 与 DSH 一起被结束（日志里 `^C`），而守护/看门狗当时也在 DSH 的进程树里，一起没了；
  于是壁纸页面报 `127.0.0.1 拒绝连接`。
- WMI 启动在部分情况下仍会挂到 DSH 的父链下，因此需要任务计划这一层兜底。

**用法**
1. 右键 `setup-hud-task.cmd` → 以管理员身份运行
2. 完成后再也不用管：DSH 退出 / 更新 / 重启都不会带走壁纸

## v1.21.3 — 守护自检改为父进程链判断（2026-11-11）

**修复**
- `start.ps1` 原来用 `DSH_SHELL`/`DSH_SESSION_ID` 环境变量判断"是否在 DSH 里"，
  但 WMI 启动的进程会**继承调用者的环境变量** → 自我重拉陷入循环、还可能出现重复守护。
- 改为沿父进程链最多查 8 层：只有祖先里真的出现 `DeepSeek Harness` 才判定"在 DSH 命令里"，
  此时才用 WMI 迁出 Job。

**结果**
- supervisor / watchdog 都是 WmiPrvSE 的子进程，父链里没有 DSH，不会再被 DSH 退出带走。

## v1.21.2 — 独立看门狗，防止"服务死了没人拉"（2026-11-10）

**新增**
- `dsh-hud/watchdog.ps1`：由 WMI 启动的独立进程（Job 外），每 30 秒检查：
  1. `7788` 是否在监听，掉线立刻用 WMI 拉起 `run-node.cmd`；
  2. 10 秒后还没起来，再用 WMI 拉起守护 `start.ps1`。
- `start.ps1` 启动时确保看门狗常驻（单实例）。三层保护：看门狗 → 守护 → node。

**背景**
- 这次壁纸崩掉是因为：一个被 DSH 命令拉起的旧守护困在 DSH 的 Job 里，
  node 停止后没被拉回来（页面报 `127.0.0.1 拒绝连接`）。看门狗和守护互相独立，
  任何一个死在 Job 里都不会让服务整夜空着。

## v1.21.1 — 守护脚本加固：用 DSH 环境变量判断"是否在 DSH 里"（2026-11-10）

**修复**
- 壁纸再次崩的直接原因：有一个守护进程被 DSH 命令拉起、困在 DSH 的 Job 内，
  既没法在 Job 外维护服务，node 停掉后也没能把它拉回来 → 页面显示"127.0.0.1 拒绝连接"。
- `start.ps1` 的 Job 自检从"只靠 IsProcessInJob 查询"改为：
  - `$env:DSH_SHELL` / `$env:DSH_SESSION_ID` 存在即判定在 DSH 会话内（更可靠）；
  - 仍保留 IsProcessInJob 兜底；
  - **先检查端口**，已在监听就直接退出，不再重复起实例。

**验证**
- 从 DSH 命令里执行 `start.ps1`：2.2 秒返回（不再卡住命令），且不会起第二个实例。

## v1.21.0 — 修复与 DSH 进程 Job 的冲突（壁纸被连带杀 / 命令卡死 / 更新超时）（2026-11-10）

**根因（已实测验证）**
- DSH 在 Windows 上把每条命令的整棵进程树放进 `KILL_ON_JOB_CLOSE` 的 Job：
  1. 从命令里 `Start-Process` / `explorer.exe` 起的常驻进程会**落进 Job**，Job 关闭时被一起杀掉（壁纸消失的直接原因）；
  2. 常驻进程不退出 → Job 永远不空 → 那条命令**永远不返回**（会话卡住一小时）；
  3. 卡住的命令还会让 DSH 自动更新前的「任务排空」检查 10 秒超时（`desktop update: task inspection timed out`）。
- 对照实验：`Start-Process` → IN_JOB；`explorer.exe` → IN_JOB；**WMI `Win32_Process.Create` → 自由（不在任何 Job）**。

**修复**
- 所有常驻进程（node 服务、Lively、解锁监听、选屏脚本）改为经 WMI `Win32_Process.Create` 启动，脱离 DSH Job；
- `start.ps1` 增加自检：如果它自己是被 DSH 命令拉起的（处于 Job 内），立刻用 WMI 重新拉起自己并退出，**不再卡住命令**；
- 监理循环改为只做端口探活 + WMI 拉起 `run-node.cmd`（不再前台 `& node`，避免长时间占用命令）；
- `recover-wallpaper.ps1` / `install.ps1` 同样改用 WMI 启动，`recover-wallpaper.cmd` 现在从任何地方跑都不会卡（实测 22 秒完成）。

**验证**
- Lively：`free`（不在 Job）；恢复脚本 22s 返回；数据服务正常、壁纸页重连成功。
- 副产物：不会再出现"退出 DSH 时连 Lively 一起被带走"。

**注意**
- 创建计划任务（Task Scheduler）需要管理员权限，本机未采用；开机自启仍走 `shell:startup` 的 VBS。

## v1.20.0 — 修 ChatGPT 历史痕迹误判 + 「现在任务」接入 ChatGPT（2026-11-10）

**修复**
- ChatGPT 对话里完成后的历史文字（`思考了 16s`、`Worked for 2m 19s`、`已处理 24s`、`Thought for …`）
  被当成"正在思考"，导致 `busy` 恒为 true、光轮一直转。现在这类**带时长数字的历史痕迹**直接跳过，
  只认现在进行时的状态词（思考中 / 正在思考 / 正在生成 / Thinking / Stop generating…）。
- 实测：空闲时 `busy=false`、面板显示"已打开"，光轮不再自转。

**新增**
- 「现在任务」在 DSH 空闲时也会显示 ChatGPT 的实时状态（`来自 ChatGPT` + 最近一句内容）。

## v1.19.1 — WorkBuddy 改为读事件流（对齐社区做法）（2026-11-09）

**参考**
- [b1ub1u/dsh-hud-haloflux-live2](https://github.com/b1ub1u/dsh-hud-haloflux-live2) 的 `workbuddy-source.mjs` 做法：
  直接 tail `~/.workbuddy/projects/<workspace>/<sessionId>.jsonl`（追加式事件日志）+ 读 `~/.workbuddy/workbuddy.db`
  的 `sessions` 表拿标题/状态，**完全不用 OCR**。

**改动**
- WorkBuddy 状态改由事件流判定：`reasoning` → 思考、`function_call` / `function_call_result` → 干活、
  `message(assistant)` → 输出、`message(user)` → 等待；最后事件时间 90 秒内算活跃。
- 移除 `external.ps1` 里每轮的 OCR 调用（省 CPU，原本约 0.75s/6s）；`workbuddy-probe.ps1` 保留作为无日志时的备用探针。
- 任意外部 Agent 活跃（Codex / WorkBuddy / Claude）都会驱动光环加速，不再只依赖窗口探针。

**实测**
- WorkBuddy 生成中：`state=输出, active=true`，摘要为真实回复内容；停止 90 秒后自动回落"空闲"。

## v1.19.0 — WorkBuddy 接入（OCR 探针）（2026-11-09）

**问题**
- WorkBuddy 是 Electron 应用，Chromium 渲染的文字 UI Automation 读不到；
  其会话 JSONL（`~/.workbuddy/projects`）只在归档时写，最后一条是 10-29，导致永远判定"未运行/空闲"。

**方案**
- 新增 `dsh-hud/workbuddy-probe.ps1`：`PrintWindow` 抓 WorkBuddy 窗口位图 + Windows OCR（zh-Hans-CN），
  识别 `思考中 / 深度思考 / 生成回复中 / 正在生成 / 处理中 / 停止生成` 等状态词，命中即 busy。
- 结果缓存 6 秒（单次约 0.75s），并行的 ChatGPT UIA 探针不受影响。
- `external.ps1` 把 WorkBuddy 加进 `apps`；看门狗逻辑把 `busy` 计入光环加速；
  `agents` 里 WorkBuddy 的状态改由探针接管（面板显示 思考中/生成中）。
- 顺便修了 WorkBuddy 摘要在对象类型上显示成 `[object Object]` 的问题。

**限制**
- WorkBuddy 窗口最小化时抓不到画面（保持窗口可见即可）；OCR 只读画面文字，不读会话内容。

## v1.18.1 — 空闲时光轮不再自转 / 修 ChatGPT 误判忙碌（2026-11-09）

**修复**
- 待命时圆环曾按 0.10 rad/s 缓慢自转（原设计"慢速漂移"），看起来像一直在转。现在 **待命时圆环完全停住**，
  只有真实活动才转。
- ChatGPT 探针把 UI 上的通用「停止」按钮误判成"生成中"（`busyHit:"停止"`），导致 `busy` 恒为 true、
  圆环一直全速。已从匹配列表移除过于宽泛的 `停止` / `Stop` / `Working`，只保留明确状态词
  （正在思考 / 正在生成 / 处理中 / Thinking / Generating / Stop generating 等）。

**验证**
- 空闲时 `GET /external` 应为 `thinking:false, busyHit:"", busy:false`。

## v1.18.0 — Codex/ChatGPT 去重 + 「现在任务」显示当前 AI（2026-11-09）

**修复**
- **Codex 与 ChatGPT 是同一个桌面程序**（ChatGPT 桌面版的 Codex 代理写入 `~/.codex/sessions`），
  之前同一份活动被显示成两行。现在 Codex 有活动时不再单列 ChatGPT；只有 Codex 未运行时才显示 ChatGPT 行。

**改进**
- **「现在任务」面板不再只显示 DSH**：当 DSH 空闲、而 Codex / WorkBuddy / Claude / ChatGPT 中有活跃者时，
  自动显示该 AI 的状态与最近内容，并在下方标注「来自 <名称>」。

## v1.17.1 — 多 Agent 移到底部面板（2026-11-09）

**调整**
- 去掉顶部新增的整行身份条（占用一行高度、打断构图）。
- 把第二行最右侧的「ChatGPT」面板改成 **「其他 AI」**：纵向列出 Codex / WorkBuddy / Claude Code，
  并把 ChatGPT 状态合并进同一块（身份色圆点 + 状态；活跃时圆点变亮、附 16 字摘要）。
- 面板高度不变，不额外占位。

## v1.17.0 — 多 Agent 接入：Codex / WorkBuddy / Claude Code（2026-11-09）

**新增**
- `dsh-hud/agents.mjs`：只读本机会话记录，归一成统一结构：
  - **Codex**：`~/.codex/sessions/**/rollout-*.jsonl`（尾部 256KB 按行解析，不整文件读取）
  - **WorkBuddy**：`~/.workbuddy/projects/*/*.jsonl`
  - **Claude Code**：`~/.claude/projects/**/*.jsonl`（本机未安装，格式按公开结构实现，未实机验证）
- 状态判定：最后事件类型（思考 / 干活 / 输出 / 空闲）+ 文件 90 秒内写入算活跃；30 分钟无写入显示"未运行"。
- 底部新增**身份条**：每个 Agent 一个身份色圆点 + 名称 + 状态；活跃时圆点变亮、附最近内容摘要（路径已脱敏）。
- `GET /state` 与 SSE 现在都带 `agents` 数组。

**实测**
- 本机 Codex 正常读到最近会话（空闲态）；WorkBuddy 显示"未运行"；Claude Code 显示"未安装"。

## v1.16.0 — 移除相位环与音频心跳（2026-11-09）

**移除**
- 相位环（叠加在光环外的状态弧）：视觉上偏抢眼，按要求去掉。
- 音频心跳（`--audio` 低频驱动光束）：去掉对应的 `livelyAudioListener` 与 `--audio` 参数。

**保留**
- Lively 系统状态行（CPU / GPU / 内存）与暂停休眠（`--system-information` / `--pause-event`）。
- 路径脱敏、空闲休眠、恢复脚本等 v1.14/v1.15 的其它改动。

## v1.15.0 — 相位环 / 系统状态 / 音频心跳 / 暂停休眠（2026-11-09）

**新增**
- **相位环**（叠加图层，不侵入原光环）：
  - 思考中 → 蓝色虚线慢呼吸弧
  - 调工具 → 白色实心弧 + 脉冲光点
  - 流式输出 → 淡蓝长弧缓慢转动
  - 等待你确认（ask_user_question）→ 橙色虚线弧
  - 空闲 → 不绘制
- **Lively 系统数据**（`LivelyInfo.json` 增加 `--system-information --audio --pause-event true`）：
  - 「现在任务」面板新增一行 `CPU xx% · GPU xx% · 内存 xx%`（Lively 原生 API，每秒刷新）
  - 音乐低频（`--audio`）驱动光环心跳，节拍更跟手
  - Lively 暂停/被全屏遮挡时停止渲染，恢复后自动继续（省电）
- 壁纸包装页现在会把宿主数据通过 `postMessage` 转给页面（跨 iframe）。

**修复**
- 路径脱敏覆盖不完整：命令串里嵌的绝对路径现在也会遮蔽（`…\wall-proj\index.html`）。

**说明**
- 系统状态行只在 Lively 里显示；浏览器预览没有宿主 API，会自动省略。

## v1.14.0 — 不再自动 reload；手动恢复入口；路径脱敏；空闲休眠（2026-11-09）

**P0：修复"自动恢复反而制造故障"**
- 依据社区实测：每次 `setwp --file reload` 都会把 WebView2 播放器撕掉重建，并遗弃一个
  2~3.5GB、`taskkill` 杀不掉的 GPU 进程，反复重建会顶到 OOM（0xE0000008）。
- 看门狗改为：**只记录 + 每小时最多一次「干净重启 Lively」**（kill + start + 清孤儿 + 重新选屏），
  不再自动 reload。页面正常时完全不干预。
- 新增 `recover-wallpaper.cmd` / `.ps1`（双击即用）：检查服务 → 干净重启 Lively →
  清理孤儿 WebView2 → 重新选屏 → 打开预览；`-Silent` 供开机静默调用。
- 解锁自动重载后 20 秒自动跑一次孤儿清理，避免解锁反复触发时累积进程。

**P1：路径脱敏**
- 面板与环带上的路径只显示末两段（`C:\Users\xxx\a\b\c.js` → `…\b\c.js`），截图分享不泄露本机结构。

**P1：空闲休眠**
- 60 秒没有任何状态推送 → 停止渲染循环（CPU 接近 0）；收到数据 1 秒内自动恢复。

**验证**：恢复脚本端到端跑通（clients=1、画面恢复运动、webview2 13 个进程）。

## v1.13.1 — 修复"思考中"识别不到（2026-11-09）

**修复**
- 探针在检测思考/生成状态前有个"忽略短于 12 字文本"的过滤，而 `正在思考`（4 字）、`思考中`（3 字）、
  `处理中`（3 字）都被提前滤掉 → ChatGPT 思考时永远判定不到忙碌。
- 现在状态词判断放在长度过滤之前；`GET /external` 新增 `busyHit` 字段（命中的原始 UI 文案）便于排查，
  `cpu` 字段仅作诊断（不作为判定，避免空闲 UI 动画造成误判）。

**验证**
- ChatGPT 思考时 `/external` 应返回 `"thinking":true,"busyHit":"正在思考","busy":true`；
  壁纸应在 2–3 秒内加速并打出光束。

## v1.13.0 — ChatGPT"思考中/处理中"也联动（2026-11-09）

**修复**
- 之前只有"文字变化"或"代理模式"才算工作中，ChatGPT 处于思考/生成初期（还没输出文字）时壁纸完全没反应。
- 现在会识别 UI 上的 `思考中 / 正在生成 / 处理中 / 运行中 / Thinking / Generating / Working / Stop generating` 等状态，
  命中即判定 busy（保持 5 秒），光环加速 + 光束爆发。
- GPT 面板状态会显示「思考中 / 执行中 / 生成中 / 已打开」。

**接口**
- `GET /external` 新增字段 `thinking`（boolean）。

## v1.12.0 — 页面缓存导致"假死" + 诊断通道（2026-11-09）

**修复**
- 壁纸包装页每次加载都用 `?t=时间戳` 强制请求新页面：之前 Lively 的 WebView 会缓存旧版 `/wall`，
  即使执行 `setwp --file reload` 也可能拿到旧 JS，表现为"画面定格、reload 无效"。
- 配合 v1.11 的解锁重载、孤儿清理，长期运行后画面卡死可自愈。

**新增（诊断）**
- 页面每 5 秒上报 `document.hidden`，JS 报错也会上报；
  `/stats` 返回 `pageHidden` / `pageErr` / `pageDbgAt`，用于快速判断"页面冻住"还是"渲染暂停"。

**排查步骤**
1. 看 `http://127.0.0.1:7788/stats` 的 `pageHidden` / `pageDbgAt`（应为 false / 最近时间）
2. 重启 Lively（不是 reload）可强制重新加载包装页
3. 仍无效时检查 `(Get-Process msedgewebview2).Count` 是否超过 30

## v1.11.0 — 锁屏/解锁与日志复发的修复（2026-11-09）

**新增**
- `unlock-reload.ps1`：订阅 Windows `SessionSwitch` 事件，解锁后自动重载壁纸（常驻后台，由 `start.ps1` 启动）。
- `cleanup-webviews.ps1`：清理"父进程已退出"的孤儿 WebView2 进程；看门狗每次重载壁纸前先跑一遍。
- 页面自愈：`bridge.js` 监听 `visibilitychange`/`pageshow`，切回前台发现数据陈旧（>60s）就自动重载页面。

**修复**
- 锁屏后再解锁，壁纸页面被 WebView 挂起、不再上报心跳 → 画面定格。
- 看门狗每 5 分钟重载一次壁纸，每次留下孤儿 WebView2 → 进程数 59、显存 7.5GB；清理后 6 个、显存回落。

**排查/使用**
```powershell
powershell -File dsh-hud\cleanup-webviews.ps1   # 手动清孤儿（会输出 total/killed）
```

## v1.10.0 — 显存泄漏修复（551ea56）

**修复**
- 看门狗在壁纸页面长时间无响应时会每 5 分钟 `reload` 一次壁纸；每次 reload 都会新起一组 WebView2 进程且旧进程不退出 →
  15 小时累积 **309 个 `msedgewebview2` 进程、显存 7.4GB**（8GB 卡接近爆显存）。
- 看门狗加入退避：reload 连续 3 次无效 → 冷却 30 分钟；重启 Lively 连续 2 次无效 → 冷却 60 分钟；页面恢复轮询后计数清零。

**效果**
- 清理后：`msedgewebview2` 309 → 7 个，显存 7460MB → **约 1.8GB**（其中 dwm 桌面合成约 1.2GB，壁纸本身 300–500MB）。

**排查方法**
```powershell
(Get-Process msedgewebview2).Count   # 正常 5–10；上百个就是踩到这个泄漏
```

---

## v1.9.0 — 服务崩溃自动拉起（075ddb4）

**新增**
- `start.ps1` 改为守护循环：node 退出后 5 秒自动重启，并防止重复实例抢端口。
- 服务输出写入 `dsh-hud/server.log`，崩溃可追溯。
- 服务端新增 `uncaughtException` / `unhandledRejection` 日志。
- 看门狗判断条件升级：不只看"有没有客户端连接"，还看页面是否还在轮询（`/external` 新鲜度），页面假死也能识别。

**修复**
- 数据服务进程意外退出后，壁纸停在"等待服务"不再恢复的问题。

---

## v1.8.0 — 壁纸冻死自动恢复（ffb5870）

**新增**
- 服务端看门狗：3 分钟无页面连接 → 自动 reload 壁纸；仍无效 → 自动重启 Lively。
- 长时间待机后 WebView 被系统挂起（画面定格、GPT 面板停更）可自愈。

---

## v1.7.0 — 构图与运镜（6b32584 / 516f961 / 9482fc1 / c198dad）

**变更**
- 镜头整体右偏（看相右移），画面整体左移 **7% 宽度**，右侧露出更多光束爆发空间；不移动光轮本身，内部粒子不被裁掉。
- 增加缓慢的镜头浮动（±7px 水平、±5px 垂直）与 ±1.5% 呼吸缩放，画面不"钉死"。
- 会话浮标（`DEFAULT-WORKSPACE · 会话名`）固定在右上角，不再随光轮乱飘。

**回退记录**
- 中途尝试过"移动光轮圆心 + 放大运镜上限"，导致内部粒子被推出画面、光束被裁，已在 `9482fc1` 回退。

---

## v1.6.0 — ChatGPT 代理模式识别 + 清理旧文件（8449fdc）

**新增**
- 识别 ChatGPT 的"操作电脑 / agent"模式窗口（`is using your computer`），直接判定为工作中：光环加速 + 每 0.7 秒一次光束。
- 枚举 ChatGPT 全部顶层窗口（含最小化/隐藏），读取最近消息内容用于"生成中"判定。

**清理**
- 删除 `index.html`、`ocr.ps1`、`capture-window.ps1`、`shot-idle.mjs`、`start-hidden.vbs`、重复的 `dsh-hud/NOTICE.md`。

---

## v1.5.0 — 过渡更顺滑（2c692e6 / f53aaa6）

**修复**
- 启动/停止时"卡顿"：活动度改为攻击 0.12 秒 / 释放 0.85 秒的包络，不再硬切。
- 时间轴速度从 `10% ↔ 100%` 跳变改为 smoothstep 连续过渡。
- 帧率预算从 `33ms ↔ 125ms` 硬切改为随活动度连续变化（32–128ms）。
- 参数平滑改为帧率无关的指数平滑（慢参数 0.42s / 快参数 0.20s）。

**变轮**
- 圆环甩动时长加长（1.6–2.4 秒）、统一 easeInOut、活动量缩放收敛（最多 ×1.5），去掉"急停"预设。
- 补间结束后的漂移速度做 0.5 秒平滑，不再顿挫。
- 待命帧率 8 → 14fps，慢速漂移更连贯。

---

## v1.4.0 — 布局与字体规范（7b5e78d … 8169647）

**布局**
- 底部面板重排为两行：第一行 现在任务 / 工具调用 / 事件速率 / 工具分布；第二行 进度 / 用量·费用 / 会话工作台 / 今日之最 / ChatGPT。
- 行高统一，列表行数按高度裁剪，避免半截被切。
- 隐藏画面上的版权行与 `independent runs · shared event bus` 副标题（署名保留在 README / NOTICE / LICENSE，`SHOW_CREDIT=true` 可恢复显示）。

**字体**
- 建立统一字号/字重规范（Display 16/800、标题 10/800、正文 9.5/400、强调 9.5/700、弱化 9.5/400）。
- 工具调用、工具分布、会话工作台等全部改为 **DOM 渲染**，canvas 只画柱状/热力，彻底解决 canvas 与 DOM 字体不一致。
- 去掉工具调用面板多余的"每完成一步就多一行"说明。

---

## v1.3.0 — 可读性修复（84e874c / aabe074 / b03d82e）

**修复**
- 小图表文字模糊：壁纸模式 `devicePixelRatio` 被压到 0.65 导致 canvas 文字缩小、`textBaseline` 未设置导致文字被裁 → canvas 固定 2.5 倍超采样 + 正确基线。
- 事件速率数字与柱子重叠 → 顶部预留标签区。
- 工具分布中文字体与面板不一致 → 统一字体栈（JetBrains Mono → MiSans → 微软雅黑）。
- 会话工作台内容底部对齐 → 统一顶部对齐。
- 光轮文字模糊 → 环带加宽、字号增大、超采样提高。

---

## v1.2.0 — 文案精简（172e525）

- 去掉"每完成一步就多一行"等冗余说明文字，把空间还给内容。

---

## v1.1.0 — 自动选屏 + 文档（3d3e53b）

**新增**
- `fix-wallpaper-screen.ps1`：读取 Lively 真实屏幕编号，自动把壁纸放到 iPad（spacedesk）优先、否则主屏，插拔显示器不用手动 `setwp`。
- 开机自启脚本按当前路径自动生成，可移植。
- 新增 `install.ps1`、`verify-after-reboot.ps1`、`NOTICE.md`、`INSTALL.md`。
- 演示 GIF `docs/screenshots/demo.gif` + 英文 README（`README.en.md`）。

---

## v1.0.0 — 首版（de50294）

- HALOFLUX 视觉与 DeepSeek Harness 实时数据打通：事件速率 → 转速、工具调用 → 光束、报错 → 闪光。
- 数据服务 `server.mjs`（零 npm 依赖）、注入桥 `bridge.js`、媒体控制 `media.ps1`、ChatGPT 读取 `external.ps1`。
- 底部真实数据面板、用量/费用、中文字体、Lively 壁纸工程。

---

## 已知注意事项

| 情况 | 说明 |
|---|---|
| 虚拟屏/高分屏被放大裁切 | Windows 缩放比例影响 WebView 尺寸；建议把那块屏设为 100% 缩放 |
| 显存突然升高 | 先数 `msedgewebview2` 进程数；异常多时重启 Lively 即可回收 |
| 多显示器各挂动态壁纸 | 每块屏都会多一组 WebView 进程，显存按屏线性增加 |
| 修改壁纸文件后 | `Lively.exe setwp --file reload` 重载即可；页面有自动重连 |
| 中文显示成方块 | 安装 MiSans 字体（缺省回退微软雅黑） |
