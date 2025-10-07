$Script:WingetInstalled = $false
$Script:RootDir = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$Script:InstallerDir = Join-Path $Script:RootDir 'installer'

function Get-JsonContent {
    param([string]$Path)
    return Get-Content $Path -Raw | ConvertFrom-Json
}

function Get-AppConfigs {
    param(
        [string]$SettingsPath,
        [string]$AppsPath
    )
    $settings = Get-JsonContent -Path $SettingsPath
    $apps = Get-JsonContent -Path $AppsPath
    return [PSCustomObject]@{ Settings = $settings; Apps = $apps }
}

function Initialize-Environment {
    if (Get-Command winget -ErrorAction SilentlyContinue) { $Script:WingetInstalled = $true } else { $Script:WingetInstalled = $false }
}

function Ensure-Dir {
    param([string]$Path)
    if (-not (Test-Path $Path)) { New-Item -Path $Path -ItemType Directory | Out-Null }
}

function Invoke-WingetAppsInstallation {
    param(
        $WingetApps,
        [string]$GlobalWingetOptions
    )
    foreach ($app in ($WingetApps | Where-Object { $_ })) {
        # 检查 Winget 应用: $($app.name) ($($app.id))
        Write-Log "Check Winget app: $($app.name) ($($app.id))" -Color White
        # 已安装检查
        $installedOutput = winget list --id $($app.id) --exact --accept-source-agreements --accept-package-agreements 2>$null | Out-String
        $escapedId = [regex]::Escape($app.id)
        $installed = $installedOutput -match "(?im)\b$escapedId\b"
        if ($installed) {
            # 已安装，跳过
            Write-Log "Already installed, skip: $($app.id)" -Color DarkGray
            continue
        }
        $base = @('install', $app.id, '--wait', '--accept-source-agreements', '--accept-package-agreements')
        $use = $null
        if ($app.options) { $use = $app.options } elseif ($GlobalWingetOptions) { $use = $GlobalWingetOptions }
        if ($use) { $base += ($use -split '\s+') }
        # 开始安装: winget $($base -join ' ')
        Write-Log "Start install: winget $($base -join ' ')" -Color DarkCyan
        winget @base
        $code = $LASTEXITCODE
        # 完成: $($app.id) / 失败: $($app.id)，退出码 $code
        if ($code -eq 0) { Write-Log "Done: $($app.id)" -Color Green } else { Write-Log "Failed: $($app.id), exit code $code" -Color Red -IsError $true }
    }
}

function Resolve-Installer-BinaryPath {
    param($App)
    if ($App.url) { return $null }
    if ($App.path) { return Join-Path $Script:InstallerDir $App.path }
    return $null
}

function Download-IfNeeded {
    param(
        $App,
        [string]$DownloadDir
    )
    Ensure-Dir -Path $DownloadDir
    if ($App.url) {
        $fileName = Split-Path -Leaf $App.url
        $dest = Join-Path $DownloadDir $fileName
        Write-Log "下载: $($App.url) -> $dest" -Color Cyan
        Invoke-WebRequest -Uri $App.url -OutFile $dest -UseBasicParsing | Out-Null
        return $dest
    }
    $local = Resolve-Installer-BinaryPath -App $App
    return $local
}

function Invoke-InstallerAppsInstallation {
    param(
        $InstallerApps,
        [string]$DownloadDir
    )
    foreach ($app in ($InstallerApps | Where-Object { $_ })) {
        # 检查安装器应用: $($app.name)
        Write-Log "Check installer app: $($app.name)" -Color White
        $bin = Download-IfNeeded -App $app -DownloadDir $DownloadDir
        # 无法解析安装包: $($app.name)
        if (-not $bin) { Write-Log "Cannot resolve installer: $($app.name)" -Color Red -IsError $true; continue }
        # 启动 GUI 安装: $bin
        Write-Log "Launch GUI installer: $bin" -Color DarkCyan
        $proc = Start-Process -FilePath $bin -PassThru -Wait
        $code = $proc.ExitCode
        # 完成: $($app.name) / 失败: $($app.name)，退出码 $code
        if ($code -eq 0) { Write-Log "Done: $($app.name)" -Color Green } else { Write-Log "Failed: $($app.name), exit code $code" -Color Red -IsError $true }
    }
}

Export-ModuleMember -Function Get-AppConfigs, Initialize-Environment, Invoke-WingetAppsInstallation, Invoke-InstallerAppsInstallation
