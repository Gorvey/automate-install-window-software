# 远程安装脚本 - Windows 软件自动安装
# 用法: 
#   irm https://your-domain.com/remote-install.ps1 | iex
#   或
#   iwr -useb https://your-domain.com/remote-install.ps1 | iex

param(
    [string]$ConfigUrl = "",  # 自定义配置文件URL
    [switch]$SkipConfirm      # 跳过确认提示
)

# 设置控制台编码为 UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# GitHub 仓库地址（请修改为你的仓库地址）
$RepoUrl = "https://raw.githubusercontent.com/Gorvey/automate-install-window-software/main"

# 临时工作目录
$TempDir = Join-Path $env:TEMP "windows-auto-install-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Windows 软件自动安装 - 远程执行模式" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 检查是否以管理员身份运行
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[警告] 未以管理员身份运行！" -ForegroundColor Yellow
    Write-Host "某些应用可能需要管理员权限才能安装。" -ForegroundColor Yellow
    Write-Host ""
    
    if (-not $SkipConfirm) {
        $continue = Read-Host "是否继续？(Y/N)"
        if ($continue -ne "Y" -and $continue -ne "y") {
            Write-Host "已取消安装。" -ForegroundColor Red
            exit 1
        }
    }
}

# 显示安全提示
if (-not $SkipConfirm) {
    Write-Host "[安全提示]" -ForegroundColor Yellow
    Write-Host "此脚本将从以下地址下载并执行代码：" -ForegroundColor White
    Write-Host "  $RepoUrl" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "请确认你信任此来源！" -ForegroundColor Yellow
    Write-Host ""
    $confirm = Read-Host "是否继续？(Y/N)"
    if ($confirm -ne "Y" -and $confirm -ne "y") {
        Write-Host "已取消安装。" -ForegroundColor Red
        exit 1
    }
    Write-Host ""
}

Write-Host "[1/6] 创建临时工作目录..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
Write-Host "工作目录: $TempDir" -ForegroundColor Gray
Write-Host ""

# 下载文件的辅助函数
function Download-File {
    param(
        [string]$Url,
        [string]$OutputPath,
        [string]$Description
    )
    
    try {
        Write-Host "  下载: $Description" -ForegroundColor Gray
        Invoke-WebRequest -Uri $Url -OutFile $OutputPath -UseBasicParsing -ErrorAction Stop
        Write-Host "  ✓ 完成: $Description" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  ✗ 失败: $Description" -ForegroundColor Red
        Write-Host "    错误: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

Write-Host "[2/6] 下载配置文件..." -ForegroundColor Cyan
$configDir = Join-Path $TempDir "config"
New-Item -ItemType Directory -Path $configDir -Force | Out-Null

# 如果提供了自定义配置URL，使用它；否则使用默认的
if ($ConfigUrl) {
    $appsConfigUrl = $ConfigUrl
} else {
    $appsConfigUrl = "$RepoUrl/config/apps.json"
}
$settingsConfigUrl = "$RepoUrl/config/apps-settings.json"

$success = $true
$success = (Download-File -Url $appsConfigUrl -OutputPath "$configDir\apps.json" -Description "apps.json") -and $success
$success = (Download-File -Url $settingsConfigUrl -OutputPath "$configDir\apps-settings.json" -Description "apps-settings.json") -and $success

if (-not $success) {
    Write-Host ""
    Write-Host "[错误] 配置文件下载失败！" -ForegroundColor Red
    exit 1
}
Write-Host ""

Write-Host "[3/6] 下载脚本模块..." -ForegroundColor Cyan
$scriptsDir = Join-Path $TempDir "scripts"
New-Item -ItemType Directory -Path $scriptsDir -Force | Out-Null

$success = $true
$success = (Download-File -Url "$RepoUrl/scripts/log.psm1" -OutputPath "$scriptsDir\log.psm1" -Description "log.psm1") -and $success
$success = (Download-File -Url "$RepoUrl/scripts/tool.psm1" -OutputPath "$scriptsDir\tool.psm1" -Description "tool.psm1") -and $success

if (-not $success) {
    Write-Host ""
    Write-Host "[错误] 脚本模块下载失败！" -ForegroundColor Red
    exit 1
}
Write-Host ""

Write-Host "[4/6] 下载主脚本..." -ForegroundColor Cyan
$success = Download-File -Url "$RepoUrl/scripts/run.ps1" -OutputPath "$scriptsDir\run.ps1" -Description "run.ps1"

if (-not $success) {
    Write-Host ""
    Write-Host "[错误] 主脚本下载失败！" -ForegroundColor Red
    exit 1
}
Write-Host ""

Write-Host "[5/6] 创建必要的目录..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path "$TempDir\installer" -Force | Out-Null
New-Item -ItemType Directory -Path "$TempDir\portable" -Force | Out-Null
Write-Host "  ✓ installer/ 目录已创建" -ForegroundColor Green
Write-Host "  ✓ portable/ 目录已创建" -ForegroundColor Green
Write-Host ""

Write-Host "[6/6] 开始执行安装脚本..." -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 切换到临时目录并执行主脚本
Push-Location $TempDir
try {
    & "$scriptsDir\run.ps1"
}
finally {
    Pop-Location
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "远程安装完成！" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "临时文件位置: $TempDir" -ForegroundColor Gray
Write-Host "如需保留日志文件，请从上述目录复制。" -ForegroundColor Gray
Write-Host ""

# 询问是否清理临时文件
if (-not $SkipConfirm) {
    $cleanup = Read-Host "是否删除临时文件？(Y/N)"
    if ($cleanup -eq "Y" -or $cleanup -eq "y") {
        try {
            Remove-Item -Path $TempDir -Recurse -Force
            Write-Host "✓ 临时文件已清理" -ForegroundColor Green
        }
        catch {
            Write-Host "✗ 清理失败: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "请手动删除: $TempDir" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "感谢使用！" -ForegroundColor Cyan

