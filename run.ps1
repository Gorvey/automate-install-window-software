# 编码设置：统一为 UTF-8，避免中文输出乱码
try { chcp 65001 | Out-Null } catch {}
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new() } catch {}
try { $OutputEncoding = [System.Text.UTF8Encoding]::new() } catch {}

Import-Module -Force "$PSScriptRoot\scripts\log.psm1"
Import-Module -Force "$PSScriptRoot\scripts\tool.psm1"

$settingsPath = Join-Path $PSScriptRoot 'apps-settings.json'
$appsPath = Join-Path $PSScriptRoot 'apps.json'

try {
    $cfg = Get-AppConfigs -SettingsPath $settingsPath -AppsPath $appsPath
    Initialize-Logger -LogPath $cfg.Settings.logPath

    # Winget 预检查
    Write-Log "Winget pre-check" -Color Cyan
    $wingetCmd = Get-Command winget -ErrorAction SilentlyContinue
    if ($null -eq $wingetCmd) {
        # 未检测到 Winget，退出脚本。
        Write-Log "Winget not detected; exiting script." -Color Yellow -IsWarning $true
    } else {
        # 已检测到 Winget。
        Write-Log "Winget detected." -Color Gray
        # 继续执行安装步骤
        Write-Log "Proceed to installation steps" -Color Cyan
    }

    # 启动批量安装
    Write-Log "Start batch installation" -Color Green

    Initialize-Environment

    $globalOptions = $null
    if ($cfg.Settings.PSObject.Properties.Name -contains 'wingetOptions') { $globalOptions = $cfg.Settings.wingetOptions }

    $dlDir = $cfg.Settings.downloadDir
    if (-not $dlDir) { $dlDir = Join-Path $env:TEMP 'AppInstallers' }

    if ($cfg.Apps.wingetApps -and $cfg.Apps.wingetApps.Count -gt 0) {
        # 安装 Winget 应用
        Write-Log "Install Winget apps" -Color Yellow
        Write-Log "Winget apps count: $($cfg.Apps.wingetApps.Count)" -Color Cyan
        Invoke-WingetAppsInstallation -WingetApps $cfg.Apps.wingetApps -GlobalWingetOptions $globalOptions
    } else {
        # 未配置 Winget 应用
        Write-Log "No Winget apps configured; skip" -Color DarkYellow
    }

    if ($cfg.Apps.installerApps -and $cfg.Apps.installerApps.Count -gt 0) {
        # 安装安装器应用 (GUI 顺序)
        Write-Log "Install installer apps (GUI sequential)" -Color Yellow
        Write-Log "Installer apps count: $($cfg.Apps.installerApps.Count)" -Color Cyan
        Invoke-InstallerAppsInstallation -InstallerApps $cfg.Apps.installerApps -DownloadDir $dlDir
    } else {
        # 未配置安装器应用
        Write-Log "No installer apps configured; skip" -Color DarkYellow
    }

    if ($cfg.Apps.portableApps -and $cfg.Apps.portableApps.Count -gt 0) {
        # portableApps 暂不处理
        Write-Log "portableApps not handled for now" -Color DarkYellow
        Write-Log "Portable apps count: $($cfg.Apps.portableApps.Count)" -Color Cyan
    }
}
catch {
    # 错误: $($_.Exception.Message)
    Write-Log "Error: $($_.Exception.Message)" -Color Red -IsError $true
}
finally {
    # 执行完毕
    Write-Log "Completed" -Color Green
}
