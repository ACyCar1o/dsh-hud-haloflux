@echo off
chcp 65001 >nul
title DSH HUD 计划任务安装（需要管理员）
echo ==========================================
echo  DSH HUD - 注册计划任务（独立于 DSH）
echo ==========================================
echo.
echo 会弹出 UAC，请点“是”。
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File','\"%~dp0setup-hud-task.ps1\"'"
echo.
echo 已请求管理员权限，请在蓝色窗口里按提示完成。
pause
