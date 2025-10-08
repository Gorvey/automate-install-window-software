# 日志模块
$script:LogMessages = @()
$script:LogPath = ""

function Initialize-Log {
    param(
        [string]$LogDirectory
    )
    
    $script:LogPath = $LogDirectory
    
    # 确保日志目录存在
    if (-not (Test-Path $LogDirectory)) {
        New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null
    }
    
    $script:LogMessages = @()
    Write-LogMessage "INFO" "日志系统已初始化"
}

function Write-LogMessage {
    param(
        [string]$Level,
        [string]$Message
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    # 添加到日志集合
    $script:LogMessages += $logEntry
    
    # 根据级别使用不同颜色输出到控制台
    switch ($Level) {
        "INFO" { Write-Host $logEntry -ForegroundColor Green }
        "WARN" { Write-Host $logEntry -ForegroundColor Yellow }
        "ERROR" { Write-Host $logEntry -ForegroundColor Red }
        "SUCCESS" { Write-Host $logEntry -ForegroundColor Cyan }
        default { Write-Host $logEntry }
    }
}

function Save-Log {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $logFileName = "install_log_$timestamp.txt"
    $logFilePath = Join-Path $script:LogPath $logFileName
    
    try {
        $script:LogMessages | Out-File -FilePath $logFilePath -Encoding UTF8
        Write-LogMessage "SUCCESS" "日志已保存到: $logFilePath"
        return $logFilePath
    }
    catch {
        Write-Host "保存日志失败: $_" -ForegroundColor Red
        return $null
    }
}

Export-ModuleMember -Function Initialize-Log, Write-LogMessage, Save-Log

