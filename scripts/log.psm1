$Script:OperationLogPath = $null
$Script:ErrorLogPath = $null

function Initialize-Logger {
    param(
        [string]$LogPath
    )
    $Timestamp = (Get-Date -Format "yyyyMMdd_HHmmss")
    $null = New-Item -ItemType Directory -Force -Path $LogPath 2>$null
    $Script:OperationLogPath = Join-Path $LogPath "AppDeploy_OperationLog_$Timestamp.txt"
    $Script:ErrorLogPath = Join-Path $LogPath "AppDeploy_ErrorLog_$Timestamp.txt"
    # --- 初始化操作日志 ($Timestamp) ---
    "--- Initialize operation log ($Timestamp) ---" | Out-File $Script:OperationLogPath -Append -Encoding UTF8
    # --- 初始化错误日志 ($Timestamp) ---
    "--- Initialize error log ($Timestamp) ---" | Out-File $Script:ErrorLogPath -Append -Encoding UTF8
}

function Write-Log {
    param(
        [string]$Message,
        [string]$Color = "White",
        [bool]$IsError = $false,
        [bool]$IsWarning = $false
    )
    $Time = Get-Date -Format 'HH:mm:ss'
    $Line = "$Time :: $Message"
    Write-Host $Line -ForegroundColor $Color
    if ($Script:OperationLogPath) { $Line | Out-File $Script:OperationLogPath -Append -Encoding UTF8 }
    if ($IsError -or $IsWarning) {
        $prefix = ''
        if ($IsError) { $prefix = '[ERROR] ' } else { $prefix = '[WARNING] ' }
        $ErrLine = "$Time :: $prefix$Message"
        if ($Script:ErrorLogPath) { $ErrLine | Out-File $Script:ErrorLogPath -Append -Encoding UTF8 }
    }
}

Export-ModuleMember -Function Initialize-Logger, Write-Log
