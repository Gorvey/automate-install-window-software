# 前置依赖和环境准备

本文档详细说明在新环境中使用本脚本所需的前置依赖和必须的准备步骤。

## 📋 目录

- [系统要求](#系统要求)
- [前置依赖](#前置依赖)
- [必须的准备步骤](#必须的准备步骤)
- [完整检查清单](#完整检查清单)
- [最小化依赖场景](#最小化依赖场景)
- [常见问题](#常见问题)

---

## 🖥️ 系统要求

### 操作系统
- ✅ Windows 10 或更高版本
- ✅ Windows Server 2016 或更高版本
- ⚠️ 不支持 Windows 7/8/8.1

### 硬件要求
- 💾 硬盘空间：至少 1GB 可用空间（取决于安装的应用数量）
- 🌐 网络：稳定的网络连接（如果需要下载应用）

---

## 🔧 前置依赖

### 1. PowerShell 环境（必须）

#### 选项 A：Windows PowerShell（系统自带）

**优点：**
- ✅ Windows 10/11 默认安装，无需额外配置
- ✅ 开箱即用

**缺点：**
- ⚠️ 可能有中文乱码问题
- ⚠️ UTF-8 支持不完善

**版本要求：**
- PowerShell 5.1 或更高版本

**检查命令：**
```powershell
$PSVersionTable.PSVersion
```

---

#### 选项 B：PowerShell 7（强烈推荐）⭐

**优点：**
- ✅ 完美支持中文，无乱码
- ✅ 性能更好，功能更强
- ✅ 跨平台支持
- ✅ 与 Windows PowerShell 完全兼容

**缺点：**
- 需要额外安装（约 100MB）

**安装方式：**

**方法 1：使用项目自带脚本（推荐）**
```cmd
powershell -ExecutionPolicy Bypass -File install-pwsh7.ps1
```

**方法 2：使用 winget**
```powershell
winget install Microsoft.PowerShell
```

**方法 3：手动下载安装**
1. 访问：https://github.com/PowerShell/PowerShell/releases/latest
2. 下载：`PowerShell-7.x.x-win-x64.msi`
3. 运行安装程序

**检查命令：**
```powershell
pwsh -Version
```

---

### 2. 执行策略设置（必须）

PowerShell 默认禁止运行脚本，需要修改执行策略。

**设置方法：**

```powershell
# 方式 1：为当前用户设置（推荐）
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

# 方式 2：为当前进程设置（临时）
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

**查看当前策略：**
```powershell
Get-ExecutionPolicy -List
```

**执行策略说明：**
- `RemoteSigned`：本地脚本可以运行，下载的脚本需要签名（推荐）
- `Bypass`：所有脚本都可以运行，无任何限制
- `Restricted`：不允许运行任何脚本（默认值）

---

### 3. Winget（条件依赖）

**什么时候需要：**
- ✅ 配置文件中有 `wingetApps` 且不为空时必须安装
- ❌ 只使用 `installerApps` 和 `portableApps` 时不需要

**检查是否已安装：**
```cmd
winget --version
```

**安装方式：**

**方法 1：从 Microsoft Store 安装（推荐）**
1. 打开 Microsoft Store
2. 搜索"应用安装程序"（App Installer）
3. 点击安装/更新

**方法 2：手动下载安装**
1. 访问：https://github.com/microsoft/winget-cli/releases/latest
2. 下载：`Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle`
3. 双击安装

**方法 3：通过 PowerShell 安装**
```powershell
# 需要 Windows 10 1809 或更高版本
Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
```

---

### 4. 网络连接（条件依赖）

**什么时候需要：**

| 场景 | 是否需要网络 |
|------|-------------|
| 使用 winget 安装应用 | ✅ 必须 |
| installerApps 配置了 `url` 下载 | ✅ 必须 |
| 只使用本地安装包（`path`） | ❌ 不需要 |
| 安装 PowerShell 7 | ✅ 必须（首次） |

**网络问题解决方案：**
- 配置代理：在 `config/apps-settings.json` 中启用代理配置
- 使用本地安装包：将文件下载好后放入 `installer/` 目录

---

### 5. 管理员权限（条件依赖）

**什么时候需要：**
- 安装到 `Program Files` 目录的应用
- 使用 `--scope machine` 安装 winget 应用
- 需要修改系统设置的应用（如驱动程序）

**如何以管理员身份运行：**
1. 右键点击批处理文件（如 `run-auto.bat`）
2. 选择"以管理员身份运行"

**不需要管理员权限的场景：**
- 便携应用（portable）解压到用户目录
- 用户级别的应用安装
- 只使用 `--scope user` 的 winget 应用

---

## 📝 必须的准备步骤

### 第 1 步：获取项目文件

**方式 1：使用 Git 克隆（推荐）**
```bash
git clone <项目仓库地址>
cd automate-install-window-software
```

**方式 2：手动下载**
1. 下载项目压缩包
2. 解压到本地目录
3. 记住项目路径

---

### 第 2 步：配置应用列表

编辑 `config/apps.json` 文件：

```json
{
  "wingetApps": [
    {
      "name": "Git",
      "id": "Git.Git",
      "options": "--scope machine"  // 可选，会覆盖全局默认选项
    }
  ],
  "installerApps": [
    {
      "name": "应用名称",
      "path": "app.exe",           // 本地文件路径（相对于 installer/ 目录）
      "silent": true,              // 静默安装
      "ignoreInstall": false       // 是否跳过安装
    },
    {
      "name": "在线应用",
      "url": "https://example.com/app.exe",  // 在线下载地址
      "silent": true,
      "ignoreInstall": false
    }
  ],
  "portableApps": [
    {
      "name": "便携应用",
      "path": "portable/app.zip",  // 相对于项目根目录
      "type": "zip",               // 目前仅支持 zip
      "ignoreInstall": false
    }
  ]
}
```

**配置说明：**

#### wingetApps 配置
- `name`：应用名称（用于日志显示）
- `id`：Winget 应用 ID（必须精确）
  - 查询 ID：`winget search <应用名>`
- `options`：安装选项（可选）
  - 如果不设置，使用全局默认选项

#### installerApps 配置
- `name`：应用名称
- `path`：本地安装包路径（相对于 `installer/` 目录）
- `url`：在线下载地址（与 `path` 二选一）
- `silent`：是否静默安装
  - `true`：自动安装，无需用户交互
  - `false`：显示安装向导，需要手动点击
- `ignoreInstall`：是否跳过安装
  - `true`：只下载不安装
  - `false`：正常安装

#### portableApps 配置
- `name`：应用名称
- `path`：压缩包路径（相对于项目根目录）
- `type`：压缩类型（目前仅支持 `zip`）
- `ignoreInstall`：是否跳过安装

---

### 第 3 步：配置全局设置

编辑 `config/apps-settings.json` 文件：

```json
{
  "downloadDir": "C:\\Temp\\downloads",
  "logPath": "C:\\Temp\\logs",
  "portableAppsDir": "C:\\Temp\\portable",
  "defaultWingetOptions": "-e -h --scope machine --accept-package-agreements --accept-source-agreements",
  "proxy": {
    "enabled": false,
    "http": "http://127.0.0.1:7890",
    "https": "http://127.0.0.1:7890"
  }
}
```

**配置项说明：**

| 配置项 | 说明 | 默认值 | 建议 |
|--------|------|--------|------|
| `downloadDir` | 在线下载的安装包保存目录 | `C:\Temp\downloads` | 使用有足够空间的目录 |
| `logPath` | 日志文件保存目录 | `C:\Temp\logs` | 可自定义 |
| `portableAppsDir` | 便携应用解压目录 | `C:\Temp\portable` | 可自定义 |
| `defaultWingetOptions` | Winget 全局默认选项 | 见下方说明 | 根据需求调整 |
| `proxy.enabled` | 是否启用代理 | `false` | 网络慢时启用 |
| `proxy.http` | HTTP 代理地址 | - | 格式：`http://host:port` |
| `proxy.https` | HTTPS 代理地址 | - | 格式：`http://host:port` |

**defaultWingetOptions 常用选项：**

| 选项 | 说明 | 推荐 |
|------|------|------|
| `-e` | 精确匹配应用 ID | ✅ 推荐 |
| `-h` 或 `--silent` | 静默安装 | ✅ 推荐 |
| `--scope machine` | 为所有用户安装 | ⚠️ 需要管理员权限 |
| `--scope user` | 仅为当前用户安装 | ✅ 无需管理员权限 |
| `--accept-package-agreements` | 自动接受软件许可 | ✅ 推荐 |
| `--accept-source-agreements` | 自动接受源协议 | ✅ 推荐 |

---

### 第 4 步：准备安装文件（条件步骤）

#### 如果使用 installerApps 的 `path` 属性：

1. 创建 `installer/` 目录（如果不存在）
2. 将安装包文件放入该目录

```
项目根目录/
├── installer/
│   ├── app1.exe
│   ├── app2.msi
│   └── httrack_x64-3.49.2.exe
```

**文件命名建议：**
- 使用有意义的文件名
- 包含版本号（如 `app-v1.2.3.exe`）
- 与 `config/apps.json` 中的 `path` 保持一致

#### 如果使用 portableApps：

1. 将压缩包放入指定位置（如 `portable/` 目录）
2. 确保文件路径与配置一致

```
项目根目录/
├── portable/
│   ├── App1.zip
│   └── Cheat Engine 7.6.zip
```

---

### 第 5 步：设置 PowerShell 执行策略

**必须在首次运行前执行！**

```powershell
# 以管理员身份运行 PowerShell
# 然后执行以下命令：
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

**验证设置：**
```powershell
Get-ExecutionPolicy -Scope CurrentUser
# 应该显示：RemoteSigned
```

---

### 第 6 步：（推荐）安装 PowerShell 7

**强烈推荐安装，可避免中文乱码问题。**

**使用项目脚本安装（最简单）：**
```cmd
# 双击运行
install-pwsh7.ps1

# 或在命令行执行
powershell -ExecutionPolicy Bypass -File install-pwsh7.ps1
```

**验证安装：**
```cmd
pwsh -Version
```

---

## 🚀 运行脚本

准备工作完成后，运行脚本：

### 推荐方式（自动选择最佳 PowerShell）
```cmd
run-auto.bat
```

### 使用 PowerShell 7（如果已安装）
```cmd
scripts\run-pwsh7.bat
```

### 使用 Windows PowerShell
```cmd
scripts\run.bat
```

---

## ✅ 完整检查清单

在新环境中运行脚本前，请逐项确认：

### 基础环境
- [ ] Windows 10 或更高版本
- [ ] 至少 1GB 可用磁盘空间
- [ ] （推荐）以管理员身份运行

### PowerShell 环境
- [ ] 已设置执行策略：`Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned`
- [ ] 能够运行 PowerShell 脚本
- [ ] （推荐）已安装 PowerShell 7

### 配置文件
- [ ] 已编辑 `config/apps.json`
- [ ] 已编辑 `config/apps-settings.json`
- [ ] 配置的目录路径有效且有写入权限

### Winget（如果使用）
- [ ] 已安装 winget：`winget --version` 能正常输出
- [ ] 能够搜索应用：`winget search git`
- [ ] winget 应用 ID 配置正确

### 安装文件（如果使用）
- [ ] 本地安装包已放入 `installer/` 目录
- [ ] 便携应用压缩包已放入指定目录
- [ ] 文件路径与配置一致
- [ ] **新增检查**：脚本运行时会自动检查 installerApps 的 path 是否存在

### 网络（如果需要）
- [ ] 网络连接稳定
- [ ] 能够访问下载源（GitHub、Microsoft Store 等）
- [ ] （如需要）已配置代理

---

## 🎯 最小化依赖场景

如果你想用最少的依赖运行脚本：

### 场景 1：仅安装本地安装包

**配置示例：**
```json
{
  "wingetApps": [],
  "installerApps": [
    {
      "name": "MyApp",
      "path": "myapp.exe",
      "silent": true,
      "ignoreInstall": false
    }
  ],
  "portableApps": []
}
```

**需要的依赖：**
- ✅ Windows PowerShell（系统自带）
- ✅ 执行策略已设置
- ✅ 本地安装包文件（放在 `installer/` 目录）

**不需要：**
- ❌ Winget
- ❌ PowerShell 7（但推荐）
- ❌ 网络连接
- ❌ 管理员权限（取决于应用）

---

### 场景 2：仅安装便携应用

**配置示例：**
```json
{
  "wingetApps": [],
  "installerApps": [],
  "portableApps": [
    {
      "name": "PortableApp",
      "path": "portable/app.zip",
      "type": "zip",
      "ignoreInstall": false
    }
  ]
}
```

**需要的依赖：**
- ✅ Windows PowerShell
- ✅ 执行策略已设置
- ✅ 压缩包文件

**不需要：**
- ❌ Winget
- ❌ 网络连接
- ❌ 管理员权限

---

### 场景 3：仅使用 Winget

**配置示例：**
```json
{
  "wingetApps": [
    {
      "name": "Git",
      "id": "Git.Git"
    }
  ],
  "installerApps": [],
  "portableApps": []
}
```

**需要的依赖：**
- ✅ Windows PowerShell
- ✅ 执行策略已设置
- ✅ Winget 已安装
- ✅ 网络连接

**不需要：**
- ❌ 本地安装包文件

---

## ❓ 常见问题

### Q1: 必须安装 PowerShell 7 吗？

**A:** 不是必须的，但**强烈推荐**。

- Windows PowerShell 5.1 可以运行脚本，但可能有中文显示问题
- PowerShell 7 完美支持 UTF-8，无乱码问题
- 两者可以共存，互不影响

---

### Q2: PowerShell 7 会替换掉 Windows PowerShell 吗？

**A:** 不会！

- PowerShell 7 和 Windows PowerShell 是两个独立的程序
- PowerShell 7 命令：`pwsh`
- Windows PowerShell 命令：`powershell`
- 安装 PowerShell 7 不会影响系统自带的 Windows PowerShell

---

### Q3: 如何知道我的 Winget 应用 ID 是什么？

**A:** 使用搜索命令：

```cmd
# 搜索应用
winget search <应用名>

# 示例
winget search git

# 输出示例：
# 名称    ID          版本
# Git     Git.Git     2.42.0
```

复制 ID 列的值（如 `Git.Git`）到配置文件。

---

### Q4: 执行策略设置失败怎么办？

**A:** 可能需要管理员权限：

```powershell
# 方法 1：以管理员身份打开 PowerShell，然后执行
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

# 方法 2：临时设置（每次运行时设置）
# 脚本中已包含此设置，一般无需手动操作
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

---

### Q5: 安装文件路径检查失败怎么办？

**A:** 脚本会自动检查 installerApps 中配置的 path 是否存在：

**错误示例：**
```
[ERROR] 检测到缺失的 Installer 文件！
[ERROR] 应用名称: httrack
[ERROR] 配置路径: httrack_x64-3.49.2.exe
[ERROR] 完整路径: F:\github\...\installer\httrack_x64-3.49.2.exe
```

**解决方法：**
1. 确认安装文件已下载
2. 检查文件名是否与配置一致（注意大小写）
3. 确认文件已放入 `installer/` 目录
4. 或者在配置中添加 `url` 属性让脚本自动下载

---

### Q6: 网络下载速度慢怎么办？

**A:** 配置代理：

编辑 `config/apps-settings.json`：
```json
{
  "proxy": {
    "enabled": true,
    "http": "http://127.0.0.1:7890",
    "https": "http://127.0.0.1:7890"
  }
}
```

常见代理端口：
- Clash: `7890`
- V2Ray: `10809`
- 企业代理: `8080` 或 `3128`

---

### Q7: 为什么需要管理员权限？

**A:** 并非所有情况都需要管理员权限。

**需要管理员权限的场景：**
- 安装到 `C:\Program Files` 的应用
- 使用 `--scope machine` 的 winget 应用
- 需要修改系统设置的应用（如驱动）

**不需要管理员权限的场景：**
- 安装到用户目录的应用
- 使用 `--scope user` 的 winget 应用
- 便携应用（portable）

**建议：** 首次运行建议使用管理员权限，避免权限问题。

---

### Q8: 如何查看详细的安装日志？

**A:** 日志文件会自动保存。

**日志位置：**
- 默认：`C:\Temp\logs\`
- 自定义：在 `config/apps-settings.json` 中配置 `logPath`

**日志文件名格式：**
```
install_log_20251008_143025.txt
```

**查看日志：**
```cmd
# 在 PowerShell 中
Get-Content "C:\Temp\logs\install_log_20251008_143025.txt"

# 或直接用记事本打开
notepad "C:\Temp\logs\install_log_20251008_143025.txt"
```

---

### Q9: 脚本运行卡住不动怎么办？

**A:** 可能的原因和解决方法：

1. **等待用户输入**
   - 某些应用可能需要手动确认
   - 检查是否有隐藏的安装窗口

2. **网络下载慢**
   - 配置代理加速
   - 或使用本地安装包

3. **winget 卡住**
   - 按 `Ctrl+C` 中断
   - 检查网络连接
   - 尝试手动运行：`winget install <ID>`

4. **权限问题**
   - 以管理员身份重新运行

---

### Q10: 可以在虚拟机中使用吗？

**A:** 可以！

**注意事项：**
- 确保虚拟机能访问网络（如果需要下载）
- 虚拟机有足够的磁盘空间
- 虚拟机快照可以方便测试

**适用的虚拟化软件：**
- ✅ VMware Workstation
- ✅ VirtualBox
- ✅ Hyper-V
- ✅ Parallels Desktop

---

## 📞 获取帮助

如果遇到问题：

1. **查看完整文档：** [README.md](../README.md)
2. **查看快速指南：** [QUICK-START.md](QUICK-START.md)
3. **查看更新日志：** [CHANGELOG.md](CHANGELOG.md)
4. **查看日志文件：** 检查详细的错误信息
5. **提交 Issue：** 到项目仓库报告问题

---

## 📚 相关文档

- [README.md](../README.md) - 完整使用文档
- [QUICK-START.md](QUICK-START.md) - 快速开始指南
- [CHANGELOG.md](CHANGELOG.md) - 版本更新记录

---

**文档版本：** v1.0  
**最后更新：** 2025-10-08

