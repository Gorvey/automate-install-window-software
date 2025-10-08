# Windows 软件自动安装脚本

这是一个用于自动安装 Windows 软件的 PowerShell 脚本系统。

## 📚 文档导航

- 📖 [快速开始指南](docs/QUICK-START.md) - 新手入门必看
- 🔧 [前置依赖文档](docs/PREREQUISITES.md) - 环境准备和依赖说明
- 📝 [更新日志](docs/CHANGELOG.md) - 版本更新记录
- 📘 README.md - 完整文档（当前文档）

## 📋 功能特性

- ✅ 自动安装 Winget 应用（跳过已安装的应用）
- ✅ **实时显示安装进度** - 可以看到下载进度条、安装状态 ⭐
- ✅ **智能静默安装** - 自动检测 MSI/EXE 类型并应用静默参数 🔇
- ✅ 自动安装本地或在线下载的安装包
- ✅ 自动解压便携应用
- ✅ 详细的彩色日志输出
- ✅ 自动生成日志文件
- ✅ 全局 Winget 默认选项配置
- ✅ 代理支持（解决下载慢的问题）
- ✅ 智能参数解析（支持带空格和引号的路径）
- ✅ Winget 依赖检测
- ✅ 错误容错机制（单个应用失败不影响其他应用）

## 🚀 使用方法

### 方法一：自动选择最佳 PowerShell（最推荐）⭐

```cmd
# 双击运行 run-auto.bat
# 会自动检测并使用 PowerShell 7，如果没有则使用 Windows PowerShell
run-auto.bat
```

### 方法二：使用 PowerShell 7（解决中文乱码）⭐

**第一步：安装 PowerShell 7**
```powershell
# 方式 1：运行安装脚本
.\install-pwsh7.ps1

# 方式 2：使用 winget 命令
winget install Microsoft.PowerShell

# 方式 3：手动下载安装
# 访问：https://github.com/PowerShell/PowerShell/releases
```

**第二步：运行脚本**
```cmd
# 双击运行或在命令行中执行
scripts\run-pwsh7.bat

# 或者直接使用 pwsh 命令
pwsh -File scripts\run.ps1
```

### 方法三：使用 Windows PowerShell

```cmd
# 使用原版批处理文件
scripts\run.bat
```

### 方法四：直接使用 PowerShell 命令

```powershell
# PowerShell 7
pwsh -File .\scripts\run.ps1

# Windows PowerShell
powershell -File .\scripts\run.ps1
```

## 🔧 配置文件说明

### config/apps.json - 应用配置

配置文件位于 `config/apps.json`：

```json
{
  "wingetApps": [
    {
      "name": "应用名称",
      "id": "Winget ID",
      "options": "--silent --scope machine"  // 可选
    }
  ],
  "installerApps": [
    {
      "name": "应用名称",
      "path": "httrack_x64-3.49.2.exe",  // installer/ 目录下的文件
      "silent": true,                     // 是否静默安装（自动检测MSI/EXE并应用静默参数）
      "ignoreInstall": false              // 是否跳过安装
    },
    {
      "name": "应用名称",
      "url": "https://example.com/app.exe",  // 在线下载
      "silent": false,                        // false = 交互式安装（需要手动点击）
      "ignoreInstall": false
    }
  ],
  "portableApps": [
    {
      "name": "应用名称",
      "path": "portable/app.zip",  // portable/ 目录下的文件
      "type": "zip",
      "ignoreInstall": false
    }
  ]
}
```

**installerApps 的 silent 参数说明：**
- `silent: true` - **静默安装（推荐）**
  - MSI 文件：自动使用 `msiexec /i "file.msi" /quiet /norestart`
  - EXE 文件：智能尝试多种静默参数组合
    - Inno Setup: `/VERYSILENT /NORESTART /SUPPRESSMSGBOXES`
    - NSIS: `/S`
    - 通用: `/silent`、`--silent`、`/quiet`
  - 如果所有静默参数都失败，自动回退到交互式安装
- `silent: false` - **交互式安装**
  - 弹出安装向导，需要手动点击"下一步"
  - 适用于需要自定义安装选项的场景

### config/apps-settings.json - 全局设置

配置文件位于 `config/apps-settings.json`：

```json
{
  "downloadDir": "C:\\Temp\\downloads",      // 下载目录
  "logPath": "C:\\Temp\\logs",               // 日志目录
  "portableAppsDir": "C:\\Temp\\portable",   // 便携应用目录
  "defaultWingetOptions": "-e -h --scope machine",  // Winget 默认选项
  "proxy": {                                 // 代理配置
    "enabled": false,                        // 是否启用代理
    "http": "http://127.0.0.1:7890",        // HTTP 代理地址
    "https": "http://127.0.0.1:7890"        // HTTPS 代理地址
  }
}
```

**defaultWingetOptions 说明：**
- 所有 Winget 应用安装时的默认选项
- 如果某个应用在 `apps.json` 中定义了自己的 `options`，则优先使用该应用的自定义选项
- 常用选项：
  - `--accept-package-agreements` - 自动接受软件许可协议
  - `--accept-source-agreements` - 自动接受源协议
  - `--silent` 或 `-h` - 静默安装
  - `-e` - 精确匹配应用 ID
  - `--scope machine` - 为所有用户安装

**proxy 代理配置说明：**
- `enabled`: 设置为 `true` 启用代理，`false` 禁用代理
- `http`: HTTP 代理服务器地址（格式：`http://host:port`）
- `https`: HTTPS 代理服务器地址（格式：`http://host:port`）
- **使用场景：**
  - 🚀 解决 Winget 下载速度慢的问题
  - 🌐 通过代理访问 GitHub、Microsoft Store
  - 🔒 在公司网络环境中使用企业代理
- **常见代理端口：**
  - Clash: `7890`
  - V2Ray: `10809`
  - 企业代理: 通常是 `8080` 或 `3128`

## 📁 目录结构

```
automate-install-window-software/
├── install-pwsh7.ps1    # 安装 PowerShell 7 的辅助脚本
├── run-auto.bat         # 自动选择最佳 PowerShell（推荐）⭐
├── README.md            # 完整文档
├── docs/                # 文档目录
│   ├── QUICK-START.md   # 快速开始指南
│   └── CHANGELOG.md     # 更新日志
├── config/              # 配置文件
│   ├── apps.json        # 应用配置
│   └── apps-settings.json  # 全局设置
├── scripts/             # 脚本文件
│   ├── run.ps1          # 主脚本
│   ├── run-pwsh7.bat    # 使用 PowerShell 7 运行
│   ├── run.bat          # 使用 Windows PowerShell 运行
│   ├── test-encoding.ps1  # 测试编码的脚本
│   ├── log.psm1         # 日志模块
│   └── tool.psm1        # 工具模块
├── installer/           # 存放安装包
└── portable/            # 存放便携应用压缩包
```

## 🔍 测试编码

如果遇到中文乱码，先运行测试脚本：

```powershell
.\scripts\test-encoding.ps1
```

## 📝 日志文件

日志文件会自动保存到配置的日志目录，格式为：
```
install_log_20251008_121307.txt
```

## ⚠️ 注意事项

1. **管理员权限**：部分应用安装需要管理员权限
2. **网络连接**：下载应用需要稳定的网络连接
3. **杀毒软件**：某些杀毒软件可能会拦截自动安装
4. **中文乱码问题**：
   - ⭐ **最佳解决方案**：安装 PowerShell 7，然后使用 `run-pwsh7.bat` 或 `run-auto.bat`
   - Windows PowerShell 5.1 对 UTF-8 支持不完善，可能显示中文乱码
   - PowerShell 7 完美支持 UTF-8，不会有乱码问题

## 🛠️ 故障排除

### 问题：中文显示乱码 ⭐

**最佳解决方案（推荐）：**
```powershell
# 1. 安装 PowerShell 7
.\install-pwsh7.ps1

# 2. 使用 PowerShell 7 运行
run-pwsh7.bat
# 或
run-auto.bat
```

**临时解决方案（如果不想安装 PowerShell 7）：**
```powershell
# 方法1：使用批处理文件
run.bat

# 方法2：手动设置编码
chcp 65001
.\run.ps1

# 注意：Windows PowerShell 5.1 即使设置编码也可能有乱码
# 建议安装 PowerShell 7 以获得最佳体验
```

**为什么 PowerShell 7 更好？**
- ✅ 完美支持 UTF-8 编码
- ✅ 跨平台（Windows、Linux、macOS）
- ✅ 更现代的功能和更好的性能
- ✅ 与 Windows PowerShell 5.1 兼容

### 问题：无法加载模块

**解决方案：**
```powershell
# 设置执行策略
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### 问题：Winget 命令不存在

**解决方案：**
从 Microsoft Store 安装 "应用安装程序" 或访问：
https://github.com/microsoft/winget-cli/releases

## 📊 运行效果

脚本运行时会显示：
- ✅ 绿色 - 正常信息
- ⚠️ 黄色 - 警告信息
- ❌ 红色 - 错误信息
- 🎉 青色 - 成功信息

运行完成后会显示统计信息：
```
Winget 应用: 成功=2, 失败=0, 跳过=1
Installer 应用: 成功=1, 失败=0, 跳过=1
Portable 应用: 成功=1, 失败=0, 跳过=0
总计: 成功=4, 失败=0, 跳过=2
```

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📚 相关文档

- [快速开始指南](docs/QUICK-START.md) - 5分钟快速上手
- [前置依赖文档](docs/PREREQUISITES.md) - 环境准备和依赖说明
- [更新日志](docs/CHANGELOG.md) - 查看版本变更

