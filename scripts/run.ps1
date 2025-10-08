# Windows 软件自动安装脚本
# 需要管理员权限运行

# 设置控制台编码为 UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# 设置执行策略
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# 导入模块（使用 Global 作用域确保在 PowerShell 7 中正常工作）
Import-Module "$PSScriptRoot\log.psm1" -Force -Scope Global
Import-Module "$PSScriptRoot\tool.psm1" -Force -Scope Global

# 读取配置文件
$appsConfig = Get-Content "$PSScriptRoot\..\config\apps.json" -Raw -Encoding UTF8 | ConvertFrom-Json
$settingsConfig = Get-Content "$PSScriptRoot\..\config\apps-settings.json" -Raw -Encoding UTF8 | ConvertFrom-Json

# 初始化日志
Initialize-Log -LogDirectory $settingsConfig.logPath

Write-LogMessage "INFO" "=========================================="
Write-LogMessage "INFO" "Windows 软件自动安装脚本开始运行"
Write-LogMessage "INFO" "=========================================="
Write-LogMessage "INFO" "下载目录: $($settingsConfig.downloadDir)"
Write-LogMessage "INFO" "便携应用目录: $($settingsConfig.portableAppsDir)"
Write-LogMessage "INFO" "日志目录: $($settingsConfig.logPath)"

# 配置代理（如果启用）
if ($settingsConfig.proxy -and $settingsConfig.proxy.enabled) {
    Write-LogMessage "INFO" "代理已启用"
    
    if ($settingsConfig.proxy.http) {
        $env:HTTP_PROXY = $settingsConfig.proxy.http
        Write-LogMessage "INFO" "HTTP 代理: $($settingsConfig.proxy.http)"
    }
    
    if ($settingsConfig.proxy.https) {
        $env:HTTPS_PROXY = $settingsConfig.proxy.https
        Write-LogMessage "INFO" "HTTPS 代理: $($settingsConfig.proxy.https)"
    }
    
    # 同时设置小写版本（某些工具需要）
    if ($settingsConfig.proxy.http) {
        $env:http_proxy = $settingsConfig.proxy.http
    }
    if ($settingsConfig.proxy.https) {
        $env:https_proxy = $settingsConfig.proxy.https
    }
} else {
    Write-LogMessage "INFO" "代理未启用"
}

Write-LogMessage "INFO" ""

# 检查 winget 是否已安装（如果配置了 winget 应用）
if ($appsConfig.wingetApps -and $appsConfig.wingetApps.Count -gt 0) {
    Write-LogMessage "INFO" "检查 Winget 是否已安装..."
    
    $wingetInstalled = $false
    try {
        $wingetVersion = winget --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            $wingetInstalled = $true
            Write-LogMessage "SUCCESS" "Winget 已安装: $wingetVersion"
        }
    }
    catch {
        $wingetInstalled = $false
    }
    
    if (-not $wingetInstalled) {
        Write-LogMessage "ERROR" "=========================================="
        Write-LogMessage "ERROR" "未检测到 Winget！"
        Write-LogMessage "ERROR" "=========================================="
        Write-LogMessage "ERROR" "配置文件中包含 $($appsConfig.wingetApps.Count) 个 Winget 应用，但系统未安装 Winget。"
        Write-LogMessage "ERROR" ""
        Write-LogMessage "INFO" "安装 Winget 的方法："
        Write-LogMessage "INFO" "1. 从 Microsoft Store 安装 '应用安装程序' (App Installer)"
        Write-LogMessage "INFO" "2. 访问: https://github.com/microsoft/winget-cli/releases"
        Write-LogMessage "INFO" "3. 下载并安装最新版本的 .msixbundle 文件"
        Write-LogMessage "ERROR" ""
        Write-LogMessage "ERROR" "脚本将终止运行！"
        Write-LogMessage "ERROR" "=========================================="
        
        # 保存日志
        $logFile = Save-Log
        if ($logFile) {
            Write-Host "`n日志文件路径: $logFile" -ForegroundColor Magenta
        }
        
        Write-Host "`n按任意键退出..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
    
    Write-LogMessage "INFO" ""
}

# 检查 installerApps 的 path 是否存在
if ($appsConfig.installerApps -and $appsConfig.installerApps.Count -gt 0) {
    Write-LogMessage "INFO" "检查 Installer 应用的本地文件..."
    
    $missingPaths = @()
    
    foreach ($app in $appsConfig.installerApps) {
        # 只检查有 path 属性的应用（有 url 的应用会自动下载，不需要检查本地文件）
        if ($app.path -and -not $app.url) {
            $installerPath = Join-Path $PSScriptRoot "..\installer\$($app.path)"
            
            if (-not (Test-Path $installerPath)) {
                $missingPaths += @{
                    Name = $app.name
                    Path = $app.path
                    FullPath = $installerPath
                }
            }
        }
    }
    
    if ($missingPaths.Count -gt 0) {
        Write-LogMessage "ERROR" "=========================================="
        Write-LogMessage "ERROR" "检测到缺失的 Installer 文件！"
        Write-LogMessage "ERROR" "=========================================="
        Write-LogMessage "ERROR" "以下 $($missingPaths.Count) 个应用的安装文件不存在："
        Write-LogMessage "ERROR" ""
        
        foreach ($missing in $missingPaths) {
            Write-LogMessage "ERROR" "应用名称: $($missing.Name)"
            Write-LogMessage "ERROR" "配置路径: $($missing.Path)"
            Write-LogMessage "ERROR" "完整路径: $($missing.FullPath)"
            Write-LogMessage "ERROR" ""
        }
        
        Write-LogMessage "ERROR" "请检查以下内容："
        Write-LogMessage "INFO" "1. 确认安装文件已下载到 installer 目录"
        Write-LogMessage "INFO" "2. 检查配置文件中的 path 路径是否正确"
        Write-LogMessage "INFO" "3. 如果需要自动下载，请在配置中添加 url 属性"
        Write-LogMessage "ERROR" ""
        Write-LogMessage "ERROR" "脚本将终止运行！"
        Write-LogMessage "ERROR" "=========================================="
        
        # 保存日志
        $logFile = Save-Log
        if ($logFile) {
            Write-Host "`n日志文件路径: $logFile" -ForegroundColor Magenta
        }
        
        Write-Host "`n按任意键退出..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
    
    Write-LogMessage "SUCCESS" "所有 Installer 应用的本地文件检查通过"
    Write-LogMessage "INFO" ""
}

# 统计信息（使用列表存储应用名称）
$stats = @{
    WingetSuccess = @()
    WingetFailed = @()
    WingetSkipped = @()
    InstallerSuccess = @()
    InstallerFailed = @()
    InstallerSkipped = @()
    PortableSuccess = @()
    PortableFailed = @()
    PortableSkipped = @()
}

# 1. 安装 Winget 应用
Write-LogMessage "INFO" "=========================================="
Write-LogMessage "INFO" "阶段 1: 安装 Winget 应用"
Write-LogMessage "INFO" "=========================================="

if ($appsConfig.wingetApps -and $appsConfig.wingetApps.Count -gt 0) {
    foreach ($app in $appsConfig.wingetApps) {
        Write-LogMessage "INFO" ""
        $result = Install-WingetApp -Name $app.name -Id $app.id -Options $app.options -DefaultOptions $settingsConfig.defaultWingetOptions
        
        if ($result) {
            # 检查是否跳过
            if (Test-WingetInstalled -AppId $app.id) {
                $stats.WingetSkipped += $app.name
            } else {
                $stats.WingetSuccess += $app.name
            }
        }
        else {
            $stats.WingetFailed += $app.name
        }
        
        Start-Sleep -Seconds 2
    }
}
else {
    Write-LogMessage "INFO" "没有配置 Winget 应用"
}

# 2. 安装 Installer 应用
Write-LogMessage "INFO" ""
Write-LogMessage "INFO" "=========================================="
Write-LogMessage "INFO" "阶段 2: 安装 Installer 应用"
Write-LogMessage "INFO" "=========================================="

if ($appsConfig.installerApps -and $appsConfig.installerApps.Count -gt 0) {
    foreach ($app in $appsConfig.installerApps) {
        Write-LogMessage "INFO" ""
        
        if ($app.ignoreInstall) {
            $stats.InstallerSkipped += $app.name
        }
        
        $result = Install-InstallerApp -Name $app.name -Path $app.path -Url $app.url `
                                       -DownloadDir $settingsConfig.downloadDir `
                                       -IgnoreInstall $app.ignoreInstall `
                                       -Silent $app.silent
        
        if ($result -and -not $app.ignoreInstall) {
            $stats.InstallerSuccess += $app.name
        }
        elseif (-not $result -and -not $app.ignoreInstall) {
            $stats.InstallerFailed += $app.name
        }
        
        Start-Sleep -Seconds 2
    }
}
else {
    Write-LogMessage "INFO" "没有配置 Installer 应用"
}

# 3. 安装 Portable 应用
Write-LogMessage "INFO" ""
Write-LogMessage "INFO" "=========================================="
Write-LogMessage "INFO" "阶段 3: 安装 Portable 应用"
Write-LogMessage "INFO" "=========================================="

if ($appsConfig.portableApps -and $appsConfig.portableApps.Count -gt 0) {
    foreach ($app in $appsConfig.portableApps) {
        Write-LogMessage "INFO" ""
        
        if ($app.ignoreInstall) {
            $stats.PortableSkipped += $app.name
        }
        
        $result = Install-PortableApp -Name $app.name -Path $app.path -Type $app.type `
                                       -PortableDir $settingsConfig.portableAppsDir `
                                       -IgnoreInstall $app.ignoreInstall
        
        if ($result -and -not $app.ignoreInstall) {
            $stats.PortableSuccess += $app.name
        }
        elseif (-not $result -and -not $app.ignoreInstall) {
            $stats.PortableFailed += $app.name
        }
        
        Start-Sleep -Seconds 2
    }
}
else {
    Write-LogMessage "INFO" "没有配置 Portable 应用"
}

# 辅助函数：格式化应用列表
function Format-AppList {
    param([array]$Apps)
    if ($Apps.Count -eq 0) {
        return "无"
    }
    return ($Apps -join ", ")
}

# 输出统计信息
Write-LogMessage "INFO" ""
Write-LogMessage "INFO" "=========================================="
Write-LogMessage "INFO" "安装完成 - 统计信息"
Write-LogMessage "INFO" "=========================================="

# Winget 应用统计
Write-LogMessage "INFO" "Winget 应用: 成功=$($stats.WingetSuccess.Count), 失败=$($stats.WingetFailed.Count), 跳过=$($stats.WingetSkipped.Count)"
if ($stats.WingetSuccess.Count -gt 0) {
    Write-LogMessage "SUCCESS" "  成功: $(Format-AppList $stats.WingetSuccess)"
}
if ($stats.WingetFailed.Count -gt 0) {
    Write-LogMessage "ERROR" "  失败: $(Format-AppList $stats.WingetFailed)"
}
if ($stats.WingetSkipped.Count -gt 0) {
    Write-LogMessage "WARN" "  跳过: $(Format-AppList $stats.WingetSkipped)"
}

# Installer 应用统计
Write-LogMessage "INFO" "Installer 应用: 成功=$($stats.InstallerSuccess.Count), 失败=$($stats.InstallerFailed.Count), 跳过=$($stats.InstallerSkipped.Count)"
if ($stats.InstallerSuccess.Count -gt 0) {
    Write-LogMessage "SUCCESS" "  成功: $(Format-AppList $stats.InstallerSuccess)"
}
if ($stats.InstallerFailed.Count -gt 0) {
    Write-LogMessage "ERROR" "  失败: $(Format-AppList $stats.InstallerFailed)"
}
if ($stats.InstallerSkipped.Count -gt 0) {
    Write-LogMessage "WARN" "  跳过: $(Format-AppList $stats.InstallerSkipped)"
}

# Portable 应用统计
Write-LogMessage "INFO" "Portable 应用: 成功=$($stats.PortableSuccess.Count), 失败=$($stats.PortableFailed.Count), 跳过=$($stats.PortableSkipped.Count)"
if ($stats.PortableSuccess.Count -gt 0) {
    Write-LogMessage "SUCCESS" "  成功: $(Format-AppList $stats.PortableSuccess)"
}
if ($stats.PortableFailed.Count -gt 0) {
    Write-LogMessage "ERROR" "  失败: $(Format-AppList $stats.PortableFailed)"
}
if ($stats.PortableSkipped.Count -gt 0) {
    Write-LogMessage "WARN" "  跳过: $(Format-AppList $stats.PortableSkipped)"
}

Write-LogMessage "INFO" ""

# 总计
$totalSuccess = $stats.WingetSuccess.Count + $stats.InstallerSuccess.Count + $stats.PortableSuccess.Count
$totalFailed = $stats.WingetFailed.Count + $stats.InstallerFailed.Count + $stats.PortableFailed.Count
$totalSkipped = $stats.WingetSkipped.Count + $stats.InstallerSkipped.Count + $stats.PortableSkipped.Count

Write-LogMessage "SUCCESS" "总计: 成功=$totalSuccess, 失败=$totalFailed, 跳过=$totalSkipped"

# 保存日志
Write-LogMessage "INFO" ""
$logFile = Save-Log
if ($logFile) {
    Write-Host "`n日志文件路径: $logFile" -ForegroundColor Magenta
}

Write-LogMessage "INFO" "脚本执行完成！"
Write-Host "`n按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

