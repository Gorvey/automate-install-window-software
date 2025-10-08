# 工具模块
Import-Module "$PSScriptRoot\log.psm1" -Force -Scope Global

function Test-WingetInstalled {
    param(
        [string]$AppId
    )
    
    try {
        $result = winget list --id $AppId 2>&1
        if ($LASTEXITCODE -eq 0 -and $result -match $AppId) {
            return $true
        }
        return $false
    }
    catch {
        return $false
    }
}

function Install-WingetApp {
    param(
        [string]$Name,
        [string]$Id,
        [string]$Options,
        [string]$DefaultOptions
    )
    
    Write-LogMessage "INFO" "开始检查 Winget 应用: $Name ($Id)"
    
    # 检查是否已安装
    if (Test-WingetInstalled -AppId $Id) {
        Write-LogMessage "WARN" "$Name 已安装，跳过"
        return $true
    }
    
    try {
        Write-LogMessage "INFO" "正在安装 $Name..."
        
        # 构建安装命令
        $installCmd = "winget install --id $Id"
        
        # 优先级：自定义 Options > 全局 DefaultOptions
        $finalOptions = ""
        if ($Options) {
            $finalOptions = $Options
            Write-LogMessage "INFO" "使用自定义选项: $Options"
        }
        elseif ($DefaultOptions) {
            $finalOptions = $DefaultOptions
            Write-LogMessage "INFO" "使用全局默认选项: $DefaultOptions"
        }
        else {
            Write-LogMessage "INFO" "无额外选项"
        }
        
        if ($finalOptions) {
            $installCmd += " $finalOptions"
        }
        
        # 打印完整的安装命令（用于调试）
        Write-LogMessage "INFO" "执行命令: $installCmd"
        
        # 构建参数数组
        $arguments = @("install", "--id", $Id)
        if ($finalOptions) {
            # 使用正则表达式解析选项，正确处理带引号的参数
            $regex = [regex]'(?:[^\s"]+|"[^"]*")+'
            $matches = $regex.Matches($finalOptions)
            foreach ($match in $matches) {
                $arg = $match.Value
                # 如果参数被双引号包围，去掉外层引号
                if ($arg.StartsWith('"') -and $arg.EndsWith('"')) {
                    $arg = $arg.Substring(1, $arg.Length - 2)
                }
                if ($arg) {
                    $arguments += $arg
                }
            }
        }
        
        # 显示解析后的参数（用于调试）
        Write-LogMessage "INFO" "参数数组: winget $($arguments -join ' ')"
        Write-LogMessage "INFO" "==================== 安装进度 ===================="
        Write-Host ""
        
        # 使用 Start-Process 执行，实时显示输出
        $process = Start-Process -FilePath "winget" -ArgumentList $arguments -Wait -NoNewWindow -PassThru
        $exitCode = $process.ExitCode
        
        Write-Host ""
        Write-LogMessage "INFO" "=================================================="
        
        if ($exitCode -eq 0) {
            Write-LogMessage "SUCCESS" "$Name 安装成功"
            return $true
        }
        else {
            Write-LogMessage "ERROR" "$Name 安装失败 (退出码: $exitCode)"
            return $false
        }
    }
    catch {
        Write-LogMessage "ERROR" "$Name 安装出错: $_"
        return $false
    }
}

function Install-InstallerApp {
    param(
        [string]$Name,
        [string]$Path,
        [string]$Url,
        [string]$DownloadDir,
        [bool]$IgnoreInstall,
        [bool]$Silent = $true
    )
    
    Write-LogMessage "INFO" "开始处理安装包应用: $Name"
    
    if ($IgnoreInstall) {
        Write-LogMessage "WARN" "$Name 设置为忽略安装，跳过"
        return $true
    }
    
    try {
        $installerPath = ""
        
        # 优先使用 URL
        if ($Url) {
            # 从URL下载
            Write-LogMessage "INFO" "检测到 URL，优先使用在线下载: $Url"
            
            # 确保下载目录存在
            if (-not (Test-Path $DownloadDir)) {
                New-Item -ItemType Directory -Path $DownloadDir -Force | Out-Null
            }
            
            # 从 URL 获取文件扩展名
            $urlFileName = [System.IO.Path]::GetFileName($Url)
            $extension = [System.IO.Path]::GetExtension($urlFileName)
            
            # 使用 name.type 格式命名
            $fileName = "$Name$extension"
            $installerPath = Join-Path $DownloadDir $fileName
            
            # 检查是否已经下载
            if (Test-Path $installerPath) {
                Write-LogMessage "SUCCESS" "发现已下载的文件，直接使用: $installerPath"
            }
            else {
                Write-LogMessage "INFO" "开始下载 $Name 从 $Url"
                
                try {
                    # 使用 WebClient 下载
                    $webClient = New-Object System.Net.WebClient
                    $webClient.DownloadFile($Url, $installerPath)
                    Write-LogMessage "SUCCESS" "下载完成: $installerPath"
                }
                catch {
                    Write-LogMessage "ERROR" "下载失败: $_"
                    return $false
                }
            }
        }
        elseif ($Path) {
            # 使用本地路径
            $installerPath = Join-Path $PSScriptRoot "..\installer\$Path"
            if (-not (Test-Path $installerPath)) {
                Write-LogMessage "ERROR" "找不到安装包: $installerPath"
                return $false
            }
            Write-LogMessage "INFO" "使用本地安装包: $installerPath"
        }
        else {
            Write-LogMessage "ERROR" "$Name 没有指定 path 或 url"
            return $false
        }
        
        # 检测安装包类型
        $extension = [System.IO.Path]::GetExtension($installerPath).ToLower()
        
        Write-LogMessage "INFO" "检测到安装包类型: $extension"
        Write-LogMessage "INFO" "静默安装设置: $($Silent -eq $true)"
        
        if ($Silent) {
            # 使用静默安装
            if ($extension -eq ".msi") {
                # MSI 文件使用 msiexec 静默安装
                Write-LogMessage "INFO" "使用 msiexec 静默安装 MSI 文件"
                $arguments = @("/i", "`"$installerPath`"", "/quiet", "/norestart")
                Write-LogMessage "INFO" "执行命令: msiexec $($arguments -join ' ')"
                
                $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -PassThru -NoNewWindow
                $exitCode = $process.ExitCode
                
                if ($exitCode -eq 0) {
                    Write-LogMessage "SUCCESS" "$Name 安装成功"
                    return $true
                } else {
                    Write-LogMessage "ERROR" "$Name 安装失败 (退出码: $exitCode)"
                    return $false
                }
            }
            elseif ($extension -eq ".exe") {
                # EXE 文件尝试常见的静默参数
                Write-LogMessage "INFO" "尝试静默安装 EXE 文件"
                
                # 尝试多种静默参数组合
                $silentArgs = @(
                    @("/VERYSILENT", "/NORESTART", "/SUPPRESSMSGBOXES"),  # Inno Setup
                    @("/S"),                                                # NSIS
                    @("/silent"),                                           # 通用
                    @("--silent"),                                          # 通用
                    @("/quiet", "/norestart")                               # 其他
                )
                
                $success = $false
                foreach ($args in $silentArgs) {
                    Write-LogMessage "INFO" "尝试参数: $($args -join ' ')"
                    Write-LogMessage "INFO" "执行命令: `"$installerPath`" $($args -join ' ')"
                    
                    try {
                        $process = Start-Process -FilePath $installerPath -ArgumentList $args -Wait -PassThru -NoNewWindow
                        $exitCode = $process.ExitCode
                        
                        if ($exitCode -eq 0) {
                            Write-LogMessage "SUCCESS" "$Name 安装成功（使用参数: $($args -join ' ')）"
                            $success = $true
                            break
                        } else {
                            Write-LogMessage "WARN" "参数 '$($args -join ' ')' 失败 (退出码: $exitCode)，尝试下一组参数..."
                        }
                    } catch {
                        Write-LogMessage "WARN" "参数 '$($args -join ' ')' 出错: $_，尝试下一组参数..."
                    }
                }
                
                if (-not $success) {
                    Write-LogMessage "WARN" "所有静默参数都失败，回退到交互式安装"
                    Write-LogMessage "INFO" "启动交互式安装程序: $installerPath"
                    Start-Process -FilePath $installerPath -Wait
                    Write-LogMessage "SUCCESS" "$Name 安装程序已完成（交互式）"
                }
                
                return $true
            }
            else {
                # 未知类型，直接启动
                Write-LogMessage "WARN" "未知安装包类型: $extension，使用交互式安装"
                Write-LogMessage "INFO" "启动安装程序: $installerPath"
                Start-Process -FilePath $installerPath -Wait
                Write-LogMessage "SUCCESS" "$Name 安装程序已完成"
                return $true
            }
        }
        else {
            # 使用交互式安装
            Write-LogMessage "INFO" "使用交互式安装（silent=false）"
            Write-LogMessage "INFO" "启动安装程序: $installerPath"
            Start-Process -FilePath $installerPath -Wait
            Write-LogMessage "SUCCESS" "$Name 安装程序已完成"
            return $true
        }
    }
    catch {
        Write-LogMessage "ERROR" "$Name 处理出错: $_"
        return $false
    }
}

function Install-PortableApp {
    param(
        [string]$Name,
        [string]$Path,
        [string]$Type,
        [string]$PortableDir,
        [bool]$IgnoreInstall
    )
    
    Write-LogMessage "INFO" "开始处理便携应用: $Name"
    
    if ($IgnoreInstall) {
        Write-LogMessage "WARN" "$Name 设置为忽略安装，跳过"
        return $true
    }
    
    try {
        $sourcePath = Join-Path $PSScriptRoot "..\$Path"
        
        if (-not (Test-Path $sourcePath)) {
            Write-LogMessage "ERROR" "找不到便携应用文件: $sourcePath"
            return $false
        }
        
        # 确保便携应用目录存在
        if (-not (Test-Path $PortableDir)) {
            New-Item -ItemType Directory -Path $PortableDir -Force | Out-Null
        }
        
        if ($Type -eq "zip") {
            Write-LogMessage "INFO" "正在解压 $Name 到 $PortableDir"
            
            # 创建应用专用目录
            $appDir = Join-Path $PortableDir $Name
            if (-not (Test-Path $appDir)) {
                New-Item -ItemType Directory -Path $appDir -Force | Out-Null
            }
            
            # 解压文件
            Expand-Archive -Path $sourcePath -DestinationPath $appDir -Force
            Write-LogMessage "SUCCESS" "$Name 已解压到 $appDir"
            return $true
        }
        else {
            Write-LogMessage "WARN" "不支持的类型: $Type，仅支持 zip"
            return $false
        }
    }
    catch {
        Write-LogMessage "ERROR" "$Name 处理出错: $_"
        return $false
    }
}

Export-ModuleMember -Function Test-WingetInstalled, Install-WingetApp, Install-InstallerApp, Install-PortableApp

