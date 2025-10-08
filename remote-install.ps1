# 远程安装脚本 - Windows 软件自动安装
# 用法: 
#   irm https://your-domain.com/remote-install.ps1 | iex
#   或
#   iwr -useb https://your-domain.com/remote-install.ps1 | iex

param(
    [string]$Branch = "main",  # 指定分支，默认为 main
    [switch]$SkipConfirm       # 跳过确认提示
)

# 设置控制台编码为 UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# GitHub 仓库信息（请修改为你的仓库地址）
$RepoOwner = "Gorvey"
$RepoName = "automate-install-window-software"
$RepoZipUrl = "https://github.com/$RepoOwner/$RepoName/archive/refs/heads/$Branch.zip"

# 临时工作目录
$TempDir = Join-Path $env:TEMP "windows-auto-install-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$ZipFile = Join-Path $TempDir "repo.zip"
$ExtractDir = Join-Path $TempDir "extracted"

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
    Write-Host "  https://github.com/$RepoOwner/$RepoName" -ForegroundColor Cyan
    Write-Host "  分支: $Branch" -ForegroundColor Cyan
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

Write-Host "[1/4] 创建临时工作目录..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
New-Item -ItemType Directory -Path $ExtractDir -Force | Out-Null
Write-Host "  ✓ 工作目录: $TempDir" -ForegroundColor Green
Write-Host ""

Write-Host "[2/4] 下载仓库..." -ForegroundColor Cyan
Write-Host "  下载地址: $RepoZipUrl" -ForegroundColor Gray
try {
    Invoke-WebRequest -Uri $RepoZipUrl -OutFile $ZipFile -UseBasicParsing -ErrorAction Stop
    $zipSize = [math]::Round((Get-Item $ZipFile).Length / 1MB, 2)
    Write-Host "  ✓ 下载完成 ($zipSize MB)" -ForegroundColor Green
}
catch {
    Write-Host "  ✗ 下载失败: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "可能的原因：" -ForegroundColor Yellow
    Write-Host "  1. 网络连接问题" -ForegroundColor Gray
    Write-Host "  2. GitHub 访问受限" -ForegroundColor Gray
    Write-Host "  3. 分支名称错误（当前分支: $Branch）" -ForegroundColor Gray
    exit 1
}
Write-Host ""

Write-Host "[3/4] 解压仓库..." -ForegroundColor Cyan
try {
    Expand-Archive -Path $ZipFile -DestinationPath $ExtractDir -Force -ErrorAction Stop
    
    # GitHub zip 解压后的目录名为 仓库名-分支名
    $RepoDir = Join-Path $ExtractDir "$RepoName-$Branch"
    
    if (-not (Test-Path $RepoDir)) {
        Write-Host "  ✗ 未找到预期的目录: $RepoDir" -ForegroundColor Red
        Write-Host "  尝试查找实际目录..." -ForegroundColor Yellow
        $actualDir = Get-ChildItem -Path $ExtractDir -Directory | Select-Object -First 1
        if ($actualDir) {
            $RepoDir = $actualDir.FullName
            Write-Host "  找到目录: $RepoDir" -ForegroundColor Green
        } else {
            Write-Host "  ✗ 解压失败" -ForegroundColor Red
            exit 1
        }
    }
    
    Write-Host "  ✓ 解压完成" -ForegroundColor Green
}
catch {
    Write-Host "  ✗ 解压失败: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
Write-Host ""

Write-Host "[4/4] 开始执行安装脚本..." -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 切换到仓库目录并执行主脚本
$RunScript = Join-Path $RepoDir "scripts\run.ps1"

if (-not (Test-Path $RunScript)) {
    Write-Host "✗ 找不到安装脚本: $RunScript" -ForegroundColor Red
    exit 1
}

Push-Location $RepoDir
try {
    & $RunScript
    $scriptExitCode = $LASTEXITCODE
}
catch {
    Write-Host ""
    Write-Host "✗ 脚本执行出错: $($_.Exception.Message)" -ForegroundColor Red
    $scriptExitCode = 1
}
finally {
    Pop-Location
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
if ($scriptExitCode -eq 0 -or $null -eq $scriptExitCode) {
    Write-Host "远程安装完成！" -ForegroundColor Green
} else {
    Write-Host "安装过程中出现错误（退出代码: $scriptExitCode）" -ForegroundColor Yellow
}
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

