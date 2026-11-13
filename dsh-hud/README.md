# dsh-hud — 数据服务与视觉桥

这是 DSH × HALOFLUX 联动壁纸的**后台部分**。完整介绍、截图与安装步骤见仓库根目录
[README.md](../README.md)；每个版本改了什么见 [CHANGELOG.md](../CHANGELOG.md)。

- 作者：竹子Away（ACyCar1o） · [B 站](https://space.bilibili.com/8124574)
- 许可：脚本 **MIT**；视觉 `haloflux/` 为 **PolyForm Noncommercial 1.0.0**（详见 ../NOTICE.md）

## 组成

| 文件 | 作用 |
|---|---|
| `server.mjs` | 数据服务（127.0.0.1:7788）：会话增量解码、SSE、媒体/外部 AI/用量/多 Agent 探针 |
| `bridge.js` | 运行时注入 HALOFLUX 的桥：联动、面板、中文化、壁纸模式 |
| `agents.mjs` | 多 Agent 探针：Codex / WorkBuddy / Claude Code |
| `external.ps1` / `workbuddy-probe.ps1` | ChatGPT UIA 探针 / WorkBuddy 备用 OCR 探针 |
| `media.ps1` | 系统媒体会话读写 |
| `fix-wallpaper-screen.ps1` | 自动选屏（spacedesk/iPad 优先） |
| `daemon.ps1` | 无窗口守护：node 掉线 3–10 秒自动拉起、Lively 掉线自动重开 |
| `stack.ps1` | 后台维护：清重复实例 + 重启 + 自愈测试 |
| `start.ps1` | 一次性设置：选屏 + 解锁监听 + 确保守护在跑 |
| `recover-wallpaper.cmd` | 壁纸丢了双击恢复 |
| `wall-proj/` | Lively / Wallpaper Engine 壁纸工程 |

## 后台结构

```
登录 → %Startup%\dsh-hud-start.vbs（ASCII、无窗口）
        → conhost.exe --headless powershell -File daemon.ps1
             → 单实例守护：7788 掉线 → 隐藏启动 node server.mjs；Lively 掉线 → 重新拉起
```

> 不要把 `daemon.ps1` 放进 DSH 命令里运行（DSH 会把它当命令子进程）。
