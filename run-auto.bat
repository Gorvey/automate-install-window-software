@echo off
chcp 65001 >nul
echo ========================================
echo Windows Software Auto-Installer
echo ========================================
echo.

REM 优先尝试使用 PowerShell 7
where pwsh >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [√] Using PowerShell 7 (Best UTF-8 Support)
    echo.
    pwsh.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\run.ps1"
    goto :end
)

REM 检查是否有 PowerShell 7 在默认安装位置
if exist "C:\Program Files\PowerShell\7\pwsh.exe" (
    echo [√] Using PowerShell 7 from default location
    echo.
    "C:\Program Files\PowerShell\7\pwsh.exe" -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\run.ps1"
    goto :end
)

REM 回退到 Windows PowerShell
echo [!] PowerShell 7 not found, using Windows PowerShell
echo [!] Note: May have encoding issues with Chinese characters
echo.
echo Tip: Install PowerShell 7 for better experience
echo      Run: install-pwsh7.ps1
echo      Docs: docs\QUICK-START.md
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\run.ps1"

:end
pause

