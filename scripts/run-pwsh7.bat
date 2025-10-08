@echo off
echo ========================================
echo Windows Software Auto-Installer
echo Using PowerShell 7 (Better UTF-8 Support)
echo ========================================
echo.

REM 检查 PowerShell 7 是否安装
where pwsh >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Found PowerShell 7, starting script...
    echo.
    pwsh.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0run.ps1"
) else (
    echo PowerShell 7 not found!
    echo.
    echo Please install PowerShell 7 first:
    echo 1. Run: install-pwsh7.ps1
    echo 2. Or visit: https://github.com/PowerShell/PowerShell/releases
    echo.
)

pause

