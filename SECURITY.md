# 安全说明

## 数据边界

本项目是**纯本地**工具：

- 数据服务只监听 `127.0.0.1:7788`，不向任何服务器上传数据
- 只读取本机文件（DSH / Codex / WorkBuddy / Claude 会话、cost-meter 账本、系统媒体会话、Lively 布局）
- 不读取登录凭据、cookie 或密码
- 面板上的绝对路径只显示最后两段，方便截图分享

## 报告问题

如果你发现安全问题（例如：服务意外对外监听、路径穿越、命令注入、隐私泄漏），
请通过 GitHub 的 **Security → Report a vulnerability**（Private vulnerability reporting）提交，不要直接开公开 Issue。

请附上：

- 影响版本（仓库根目录 `VERSION` 或 Release 标签）
- 复现步骤
- 你观察到的实际行为

## 使用建议

- 不要把 `127.0.0.1:7788` 通过端口转发 / 内网穿透暴露到公网
- 不要在共享账号或公共电脑上运行（面板会显示会话标题）
- 安装 Codex Hooks 时只信任你确认过的条目（`~/.codex/hooks.json` 会先自动备份）
