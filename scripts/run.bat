@echo off
chcp 65001 >nul
echo 正在启动软件自动安装脚本...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0run.ps1"
pause

