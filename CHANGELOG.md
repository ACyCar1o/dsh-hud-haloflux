# 更新日志（CHANGELOG）

当前版本：**v1.19.1**（2026-11-09）
仓库：<https://github.com/ACyCar1o/dsh-hud-haloflux>

> 升级方式：`git pull` 后重启服务（或重新解压 `DSH-HUD-portable.zip` 覆盖）；
> 壁纸页会自动重连，不需要手动改 Lively。

---

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
