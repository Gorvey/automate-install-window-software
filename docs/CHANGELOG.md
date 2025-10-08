# 更新日志

## 2025-10-08 - 文件结构重构与功能增强

### 🎯 主要改动

**简化主目录，只保留3个核心文件：**
- ✅ `install-pwsh7.ps1` - 安装 PowerShell 7
- ✅ `run-auto.bat` - 自动运行（推荐使用）
- ✅ `README.md` - 完整文档

**新增功能：**
- ✅ **代理支持**：支持配置 HTTP/HTTPS 代理，解决 Winget 下载慢的问题 🚀
- ✅ **智能静默安装**：支持配置 `silent` 参数，自动检测 MSI/EXE 并应用静默参数 🔇
- ✅ Winget 依赖检测：如果配置了 Winget 应用但未安装 Winget，将终止脚本并提示安装方法
- ✅ Winget 全局默认选项：新增 `defaultWingetOptions` 配置，支持为所有 Winget 应用设置默认安装选项
- ✅ Winget 选项优先级：应用自定义选项 > 全局默认选项，灵活配置
- ✅ **实时显示安装进度**：Winget 安装应用时实时显示进度条、下载速度等信息 ⭐
- ✅ 安装命令调试：安装时会打印完整的 winget 命令和参数数组，方便调试问题
- ✅ 智能参数解析：正确处理带空格和引号的参数（如 `-l "D://program files"`）
- ✅ 文档目录：所有文档文件移至 `docs/` 目录，更专业的组织结构

### 📁 新的目录结构

```
automate-install-window-software/
├── install-pwsh7.ps1    # 安装 PowerShell 7
├── run-auto.bat         # 一键运行（推荐）⭐
├── README.md            # 完整文档
├── docs/                # 文档目录
│   ├── QUICK-START.md   # 快速开始指南
│   └── CHANGELOG.md     # 更新日志（当前文件）
├── config/              # 配置文件目录
│   ├── apps.json        # 应用配置
│   └── apps-settings.json  # 全局设置
├── scripts/             # 脚本文件目录
│   ├── run.ps1          # 主脚本
│   ├── run-pwsh7.bat    # PowerShell 7 运行器
│   ├── run.bat          # Windows PowerShell 运行器
│   ├── test-encoding.ps1  # 编码测试
│   ├── log.psm1         # 日志模块
│   └── tool.psm1        # 工具模块
├── installer/           # 安装包目录
└── portable/            # 便携应用目录
```

### 🔧 技术改进

1. **代理支持** 🚀
   - 在 `config/apps-settings.json` 中新增 `proxy` 配置项
   - 支持独立配置 HTTP 和 HTTPS 代理
   - 一键启用/禁用代理（`enabled: true/false`）
   - 自动设置环境变量：`HTTP_PROXY`、`HTTPS_PROXY`、`http_proxy`、`https_proxy`
   - 适用于所有网络操作（Winget 下载、在线安装包下载等）
   - 支持 Clash、V2Ray、企业代理等各类代理工具

2. **Winget 依赖检测**
   - 脚本启动时自动检测 Winget 是否已安装
   - 如果配置了 Winget 应用但未安装 Winget，将显示详细的安装指引
   - 避免运行过程中出现 Winget 命令错误

3. **Winget 全局默认选项与优先级**
   - 在 `config/apps-settings.json` 中新增 `defaultWingetOptions` 字段
   - 支持为所有 Winget 应用设置统一的默认安装选项
   - 选项优先级：应用自定义 `options` > 全局 `defaultWingetOptions`
   - 安装时会在日志中显示使用的选项来源（自定义/全局/无）
   - 打印完整的 `winget install` 命令，便于调试和排查问题

4. **实时显示安装进度** ⭐
   - 改用 `Start-Process` 实时显示 winget 的安装输出
   - 可以看到下载进度条、安装状态、完成百分比等信息
   - 安装过程更透明，用户体验更好
   - 智能参数解析：使用正则表达式正确处理带引号和空格的参数
   - 显示解析后的参数数组，方便验证参数是否正确

5. **智能静默安装** 🔇
   - 在 `config/apps.json` 的 `installerApps` 中新增 `silent` 字段
   - `silent: true` - 自动检测安装包类型（MSI/EXE）并应用静默参数
   - MSI 文件：使用 `msiexec /i "file.msi" /quiet /norestart`
   - EXE 文件：智能尝试多种静默参数组合（Inno Setup、NSIS、通用）
   - 如果所有静默参数失败，自动回退到交互式安装
   - `silent: false` - 使用交互式安装，弹出安装向导
   - 灵活控制：不同应用可以使用不同的安装方式

6. **PowerShell 7 兼容性修复**
   - 修复模块导入作用域问题（添加 `-Scope Global`）
   - 修复 `Test-WingetInstalled` 函数未导出的问题

7. **文件组织优化**
   - 所有脚本中的路径引用已更新
   - 配置文件移至 `config/` 目录
   - 脚本文件移至 `scripts/` 目录
   - 文档文件移至 `docs/` 目录

8. **文档更新**
   - README.md 已更新反映新结构
   - QUICK-START.md 已更新运行方式
   - 添加详细的目录结构说明
   - 添加文档导航链接

### 🚀 代理配置使用示例

**场景 1：使用 Clash 代理加速下载**

`config/apps-settings.json`：
```json
{
  "proxy": {
    "enabled": true,
    "http": "http://127.0.0.1:7890",
    "https": "http://127.0.0.1:7890"
  }
}
```

**场景 2：使用 V2Ray 代理**

```json
{
  "proxy": {
    "enabled": true,
    "http": "http://127.0.0.1:10809",
    "https": "http://127.0.0.1:10809"
  }
}
```

**场景 3：使用公司代理**

```json
{
  "proxy": {
    "enabled": true,
    "http": "http://proxy.company.com:8080",
    "https": "http://proxy.company.com:8080"
  }
}
```

**场景 4：禁用代理（默认）**

```json
{
  "proxy": {
    "enabled": false
  }
}
```

**运行时日志输出：**
```
[INFO] Windows 软件自动安装脚本开始运行
[INFO] 下载目录: C:\Temp\downloads
[INFO] 便携应用目录: C:\Temp\portable
[INFO] 日志目录: C:\Temp\logs
[INFO] 代理已启用
[INFO] HTTP 代理: http://127.0.0.1:7890
[INFO] HTTPS 代理: http://127.0.0.1:7890
```

### 💡 Winget 选项使用示例

**场景 1：使用全局默认选项**

`config/apps-settings.json`：
```json
{
  "defaultWingetOptions": "--accept-package-agreements --accept-source-agreements"
}
```

`config/apps.json`：
```json
{
  "wingetApps": [
    {
      "name": "Git",
      "id": "Git.Git"
      // 未指定 options，将使用全局默认选项
    }
  ]
}
```

**场景 2：应用自定义选项（优先级更高）**

```json
{
  "wingetApps": [
    {
      "name": "Git",
      "id": "Git.Git",
      "options": "--silent --scope machine"
      // 指定了自定义 options，将使用此选项而非全局默认
    }
  ]
}
```

**日志输出示例（现在会显示实时进度）：**
```
[INFO] 开始检查 Winget 应用: Git (Git.Git)
[INFO] 正在安装 Git...
[INFO] 使用自定义选项: --silent --scope machine
[INFO] 执行命令: winget install --id Git.Git --silent --scope machine
[INFO] 参数数组: winget install --id Git.Git --silent --scope machine
[INFO] ==================== 安装进度 ====================

找到 Git [Git.Git] 版本 2.43.0
正在下载 https://github.com/git-for-windows/git/releases/download/v2.43.0...
  ████████████████████████████████  100%  已下载 52.1 MB / 52.1 MB
已成功验证安装程序哈希
正在启动程序包安装...
已成功安装

[INFO] ==================================================
[SUCCESS] Git 安装成功
```

### 📝 使用方法（保持简单）

**最简单的使用方式：**
```cmd
# 直接双击运行
run-auto.bat
```

**首次使用建议：**
```cmd
# 1. 安装 PowerShell 7（获得更好体验）
install-pwsh7.ps1

# 2. 运行脚本
run-auto.bat
```

### ⚠️ 兼容性说明

- ✅ 向后兼容：旧的运行方式仍然可用（在 scripts 目录下）
- ✅ 路径自动处理：所有相对路径已正确更新
- ✅ 配置文件位置：自动从 config 目录读取

### 🎉 好处

1. **更清晰的项目结构** - 主目录只有最常用的文件
2. **更好的组织** - 配置、脚本分类存放
3. **更易上手** - 新用户只需关注4个核心文件
4. **更易维护** - 文件分类明确，便于管理


