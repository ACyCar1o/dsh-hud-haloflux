@echo off
chcp 65001 >nul
title 安装 DSH 更新 0.2.2-rc.1

echo ============================================
echo  DSH 手动更新（绕过"task inspection timed out"）
echo ============================================
echo.
echo 1) 现在会关闭所有 DeepSeek Harness 进程
echo 2) 然后启动更新安装包
echo.
pause

echo.
echo [1/2] 关闭 DSH 进程...
taskkill /IM "DeepSeek Harness.exe" /F >nul 2>&1
timeout /t 3 >nul

echo [2/2] 启动安装包...
if not exist "C:\Users\PD-Design-Bamboo\AppData\Local\@deepseek-aidsh-desktop-updater\pending\deepseek-harness-0.2.2-rc.1-win-x64.exe" (
  echo 找不到安装包：C:\Users\PD-Design-Bamboo\AppData\Local\@deepseek-aidsh-desktop-updater\pending\deepseek-harness-0.2.2-rc.1-win-x64.exe
  pause
  exit /b 1
)
start "" "C:\Users\PD-Design-Bamboo\AppData\Local\@deepseek-aidsh-desktop-updater\pending\deepseek-harness-0.2.2-rc.1-win-x64.exe"
echo.
echo 已启动安装程序，按提示完成安装即可。
timeout /t 3 >nul