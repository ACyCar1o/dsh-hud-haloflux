# 安装与依赖清单

目标环境：**Windows 10 / 11 x64**。整套东西都在本机运行，只监听 `127.0.0.1`，不联网上传。

## 一、必需依赖

| 依赖 | 用途 | 安装方式 | 是否随项目附带 |
|---|---|---|---|
| **Windows 10/11 x64** | 运行平台 | — | — |
| **Node.js ≥ 20** | 数据服务 / 静态托管 / SSE | `winget install OpenJS.NodeJS.LTS` | ❌ 需自装 |
| **PowerShell 5.1** | 媒体控制、ChatGPT 读取、OCR | 系统自带 | ✅ 系统组件 |
| **Lively Wallpaper** | 把页面变成桌面壁纸 | `winget install --id rocksdanister.LivelyWallpaper` | ❌ 需自装 |
| **Edge WebView2 Runtime** | Lively 渲染网页壁纸 | 随 Lively / Windows 自动安装 | ❌ 一般已存在 |
| **HALOFLUX** | 视觉本体 | — | ✅ 已包含 `haloflux/` |

> 服务端**零 npm 依赖**，不需要 `npm install`，只用 Node 内置模块。

## 二、可选依赖（没有也能跑，只是少对应面板）

| 依赖 | 影响的模块 | 缺失时表现 |
|---|---|---|
| **DeepSeek Harness 桌面版** | 主数据源（会话事件、进度、工具流） | 面板无数据，画面保持待命 |
| **dsh-cost-meter 插件** | 「用量 · 费用」面板、顶部花费/余额 | 显示"暂无用量数据" |
| **ChatGPT 桌面版** | ChatGPT 面板 | 显示"未运行" |
| **QQ 音乐 / Spotify 等** | 左上播放器 | 显示"未检测到播放器" |
| **MiSans / HarmonyOS Sans 字体** | 中文排版 | 回退到微软雅黑 |
| **Wallpaper Engine**（付费，可选） | 替代 Lively 作为壁纸宿主 | 用 Lively 即可 |

## 三、新电脑安装步骤

```powershell
# 0) 确认 Node 可用
node -v

# 1) 解压项目，保持目录结构：
#    <某目录>\
#      dsh-hud\
#      haloflux\
cd <解压目录>

# 2) 一键安装（检查环境 + 写开机自启 + 启动服务）
powershell -NoProfile -ExecutionPolicy Bypass -File dsh-hud\install.ps1

# 3) 健康检查
Invoke-RestMethod http://127.0.0.1:7788/stats

# 4) 装壁纸宿主并设置
winget install --id rocksdanister.LivelyWallpaper
#    Lively -> 添加壁纸 -> URL -> http://127.0.0.1:7788/wall
#    或在 Lively 里导入 dsh-hud\wall-proj 工程
```

安装脚本会：

1. 检查 Node 与 `haloflux/lab.html`
2. 在 `%APPDATA%\...\Startup\dsh-hud-start.vbs` 写入开机自启（路径取当前解压位置，可移植）
3. 后台启动 `dsh-hud\start.ps1`
4. 打印 Lively 配置步骤


## 四、自动选屏（无需手动 setwp）

`start.ps1` 启动服务后会调用 `fix-wallpaper-screen.ps1`：

- 从 `WallpaperLayout.json` 读取每块屏在 Lively 里的真实编号（`LivelyScreen.Index`）
- 目标屏 **spacedesk 虚拟屏（iPad）优先，否则主屏**
- 只在目标屏设置壁纸，其它屏自动清掉

换电脑、插拔显示器、改显示设置后都无需手动干预；想强制指定：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File dsh-hud\fix-wallpaper-screen.ps1 -Prefer primary
```

日志：`dsh-hud\wallpaper-screen.log`

## 五、多显示器 / 换屏幕

Lively 的屏幕编号与 Windows 的 `DISPLAYn` 不同，且插拔后会变：

```powershell
$exe = "C:\Program Files\Lively Wallpaper\Lively.exe"
$lib = "$env:LOCALAPPDATA\Lively Wallpaper\Library\wallpapers\dshhaloflux.001"

& $exe setwp --file $lib --monitor 3   # 示例：第 3 块屏
& $exe closewp --monitor 1             # 撤掉第 1 块屏的壁纸
& $exe setwp --file reload             # 改过页面后重载
```

确认映射：改一次后看 `%LOCALAPPDATA%\Lively Wallpaper\WallpaperLayout.json` 里的 `DeviceName`。

## 六、重启后自检

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File dsh-hud\verify-after-reboot.ps1
```

7 项检查：自启脚本 / 7788 监听 / `/stats` / `/wall` / Lively 进程 / 壁纸目标 / node 进程。
全部 `[ OK ]` 即恢复成功。

## 七、常见问题

| 现象 | 原因 | 处理 |
|---|---|---|
| 壁纸黑屏/中途出现"等待 dsh-hud 服务" | 服务没起来 | 运行 `dsh-hud\start.ps1` 看报错；端口被占会直接退出 |
| 退出 DSH 后壁纸消失 | 服务被当作 DSH 子进程启动 | 用开机自启或 `install.ps1` 启动，不要从 DSH 会话里手动起 |
| 壁纸跑到别的显示器 | Lively 屏幕编号变了 | 按上面「多显示器」重新 `setwp` |
| 画面卡顿 | 后台资源紧张 | 改 `bridge.js`：`devicePixelRatio` 0.65→0.55、帧预算 33→50、`LOAD` 0.45→0.3 |
| 中文显示成方块 | 字体缺失 | 装 MiSans 或修改 `bridge.js` 里的字体栈 |
| 没有声音 | 正常：壁纸自带 BGM 已被硬静音 | 播放器面板控制的是你系统里的音乐软件 |

## 八、目录与文件

见 [README.md](README.md#目录)。服务端只读以下本机数据：

- `~/.dsh/sessions/**`（会话日志）
- `~/.dsh/storages/cost-meter/ledger.json`（用量账本）
- 系统媒体会话（Windows SMTC）
- ChatGPT 窗口的 UI Automation 树
