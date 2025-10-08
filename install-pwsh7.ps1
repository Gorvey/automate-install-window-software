# Install PowerShell 7 Script
# This script helps you install PowerShell 7 for better UTF-8 support

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "PowerShell 7 Installation Helper" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Check if PowerShell 7 is already installed
$pwsh7Paths = @(
    "C:\Program Files\PowerShell\7\pwsh.exe",
    "$env:ProgramFiles\PowerShell\7\pwsh.exe"
)

$pwsh7Installed = $false
foreach ($path in $pwsh7Paths) {
    if (Test-Path $path) {
        $pwsh7Installed = $true
        Write-Host "[OK] PowerShell 7 is already installed!" -ForegroundColor Green
        Write-Host "Path: $path" -ForegroundColor Yellow
        break
    }
}

# Check if pwsh command is available
if (Get-Command pwsh -ErrorAction SilentlyContinue) {
    $pwsh7Installed = $true
    Write-Host "[OK] PowerShell 7 is available in PATH!" -ForegroundColor Green
    $pwshVersion = pwsh -Command '$PSVersionTable.PSVersion.ToString()'
    Write-Host "Version: $pwshVersion" -ForegroundColor Yellow
}

Write-Host ""

if ($pwsh7Installed) {
    Write-Host "You can now use:" -ForegroundColor Cyan
    Write-Host "  - run-auto.bat   (推荐使用！)" -ForegroundColor White
    Write-Host "  - scripts\run-pwsh7.bat  (直接使用 PowerShell 7)" -ForegroundColor White
    Write-Host ""
    Write-Host "查看快速开始指南: docs\QUICK-START.md" -ForegroundColor Yellow
} else {
    Write-Host "[!] PowerShell 7 is not installed" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Installing PowerShell 7 via winget..." -ForegroundColor Cyan
    Write-Host ""
    
    $installResult = $false
    try {
        # Try to install using winget
        $process = Start-Process -FilePath "winget" -ArgumentList "install --id Microsoft.PowerShell --source winget --accept-package-agreements --accept-source-agreements" -Wait -PassThru -NoNewWindow
        
        if ($process.ExitCode -eq 0) {
            $installResult = $true
            Write-Host ""
            Write-Host "[SUCCESS] PowerShell 7 installed successfully!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Next steps:" -ForegroundColor Cyan
            Write-Host "1. Close this window" -ForegroundColor White
            Write-Host "2. Run: run-pwsh7.bat or run-auto.bat" -ForegroundColor White
        } else {
            Write-Host ""
            Write-Host "[FAILED] Installation failed with exit code: $($process.ExitCode)" -ForegroundColor Red
        }
    } catch {
        Write-Host ""
        Write-Host "[ERROR] Installation failed: $_" -ForegroundColor Red
    }
    
    if (-not $installResult) {
        Write-Host ""
        Write-Host "Manual Installation Instructions:" -ForegroundColor Yellow
        Write-Host "=================================" -ForegroundColor Yellow
        Write-Host "1. Visit: https://github.com/PowerShell/PowerShell/releases/latest" -ForegroundColor White
        Write-Host "2. Download: PowerShell-7.x.x-win-x64.msi" -ForegroundColor White
        Write-Host "3. Run the installer" -ForegroundColor White
        Write-Host ""
        Write-Host "Or try using winget manually:" -ForegroundColor Yellow
        Write-Host "  winget install Microsoft.PowerShell" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
$null = Read-Host "Press Enter to exit"
