@echo off
chcp 65001 >nul
rem launched via WMI by start.ps1 (outside DSH job; else it gets killed with the job)
node "%~dp0server.mjs" "%~dp0.." >> "%~dp0server.log" 2>&1
