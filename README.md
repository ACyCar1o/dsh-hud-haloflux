# DSH × HALOFLUX — 实时联动桌面壁纸

**中文** | [English](README.en.md)

把 [HALOFLUX](https://github.com/Ryder191/haloflux)（单文件 Canvas 科幻可视化）接到本机 **DeepSeek Harness** 的真实会话数据上：
轮盘转速、光束爆发、面板数字都由真实事件驱动，空闲时待命慢速、干活时爆发。

同时把**本机播放器**（QQ 音乐 / Spotify…）和 **ChatGPT 桌面版**状态接进同一画面，
最终作为 **Lively Wallpaper** 的桌面壁纸常驻。

> ⚠️ HALOFLUX 采用 **PolyForm Noncommercial** 许可：**仅限个人非商业使用**，详见 [NOTICE.md](NOTICE.md)。
> 署名默认不在画面上显示（`bridge.js` 的 `SHOW_CREDIT = true` 可重新打开）；完整版权信息见 `NOTICE.md` / `LICENSE`。

![工具运行时的联动](docs/screenshots/demo.gif)

*工具连续运行时：光束持续爆发、环带加速、面板数字滚动；空闲 4 秒后自动降为慢速待命。*

## 特性

- **真实数据驱动**：事件速率 → 转速；每次工具调用 → 一次真实光束爆发；报错 → 闪光变密
- **空闲待命**：4 秒无事件即降为慢速漂移（10% 时间轴），不空转
- **人话面板**：现在任务 / 进度 / 工具调用 / 会话工作台 / 今日之最 / ChatGPT / 事件速率 / 工具分布
- **用量费用**：今日 tokens、花费、余额、缓存命中、峰谷剩余（读 `dsh-cost-meter` 账本）
- **本地播放器**：读取系统媒体会话，可上一首 / 播放暂停 / 下一首，面板可收起
- **自动选屏**：优先 iPad（spacedesk 虚拟屏），否则主屏；插拔显示器不用手动改编号
- **中文界面**：MiSans 中文 + JetBrains Mono 英文数字
- **壁纸化**：Lively / Wallpaper Engine 专用工程，断线自动重试

![面板](docs/screenshots/panels.png)

![圆环数据带](docs/screenshots/ring.png)

![本地播放器](docs/screenshots/player.png)


## 字体规范

全站统一：**JetBrains Mono（数字/英文）→ MiSans → HarmonyOS Sans SC → 微软雅黑**。

| 层级 | 用途 | 字号 | 字重 | 颜色 |
|---|---|---|---|---|
| Display | 「现在任务」动词、「进度」主数字 | 16px | 800 | `#ffffff` |
| 面板标题 | 各面板标题 | 10px（小窗 8.5px） | 800 | `#e8eaee` / 小窗 `#9aa0aa` |
| 正文 | 列表行、描述 | 9.5px | 400 | `#b9bec7` |
| 强调 | 动词、关键数值 | 9.5px | 700 | `#ffffff` |
| 弱化 | 时间戳、单位、辅助说明 | 9.5px | 400 | `#8d939c` |
| 图表标签 | 工具分布、环带卡片 | 9.5px | 700 | `#e8eaee` |
| 统计数字 | 事件速率、计数 | 9.5–11px（等宽） | 700 | `#ffffff` |
| 环带 | 圆环上的数据卡（受带宽限制） | 9px / 6px | 800 / 500 | 白 100% / 90% |

原则：**同一层级只能有一个字号和字重**；正文里的动词/数值统一加粗提白，辅助信息统一压灰。

所有文字（含图表标签、计数、事件速率数值）都用 **DOM 渲染**，canvas 只画柱状/热力等图形，从根上保证字体与面板完全一致。

## 快速开始

```powershell
# 1. 装 Node.js 20+（只需要它，服务端零第三方依赖）
winget install OpenJS.NodeJS.LTS

# 2. 解压本项目，运行安装脚本（自动写开机自启 + 启动服务）
powershell -NoProfile -ExecutionPolicy Bypass -File dsh-hud\install.ps1

# 3. 装 Lively Wallpaper
winget install --id rocksdanister.LivelyWallpaper

# 4. Lively -> 添加壁纸 -> URL -> http://127.0.0.1:7788/wall
```

详见 [INSTALL.md](INSTALL.md)。

## 目录

| 路径 | 说明 |
|---|---|
| `dsh-hud/server.mjs` | 数据服务：会话增量解码、SSE、媒体/外部 AI/用量代理 |
| `dsh-hud/bridge.js` | 注入 HALOFLUX 的桥：联动、面板、中文化、壁纸模式 |
| `dsh-hud/fix-wallpaper-screen.ps1` | 自动选择壁纸屏幕（spacedesk/iPad 优先，否则主屏） |
| `dsh-hud/media.ps1` | 系统媒体会话读写（上下曲/播放暂停） |
| `dsh-hud/external.ps1` | ChatGPT 桌面版状态（UI Automation） |
| `dsh-hud/wall-proj/` | Lively / Wallpaper Engine 壁纸工程 |
| `dsh-hud/install.ps1` | 一键安装（自启 + 启动 + 自动选屏） |
| `dsh-hud/capture-gif.mjs` | 演示 GIF 录制（CDP 截帧） |
| `dsh-hud/verify-after-reboot.ps1` | 重启后自检 |
| `haloflux/` | HALOFLUX 原始视觉（未改动，服务端运行时注入 bridge） |

## 架构

```
~/.dsh/sessions/<workspace>/session-*.jsonl.zstd
        │ 每 500ms 增量解码（多帧 zstd）
        ▼
dsh-hud/server.mjs  (127.0.0.1:7788)
        │ SSE /stream · JSON /state /usage /media /external
        ▼
haloflux/lab.html + 运行时注入 bridge.js
        │ setParam() / onBeat() 驱动内部参数
        ▼
Lively Wallpaper（WebView2）→ 桌面壁纸
```

## 性能（本机实测，3840×2160 / i9-14900KF）

| 场景 | CPU | 内存 |
|---|---|---|
| 数据服务 | ≈0.3% 单核 | 60–110 MB |
| 壁纸 · 待命 | ≈4% 单核 | ≈1.0–1.2 GB |
| 壁纸 · 工作中 | ≈30–41% 单核 | ≈1.2–1.3 GB |

> 内存大头是 Lively/WebView2 基线（换任何壁纸都差不多）。
> 可在 `bridge.js` 调 `devicePixelRatio`、帧率、`LOAD` 进一步降载。

## 许可

- 视觉：HALOFLUX by Ryder191，PolyForm Noncommercial（**禁止商业用途**）
- 二次开发脚本：MIT（见 `LICENSE-MIT`），分发请保留非商业性质与署名
