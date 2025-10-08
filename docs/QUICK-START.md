# 快速开始指南

## 🚀 解决中文乱码的最佳方案

### 方案 A：安装 PowerShell 7（推荐）⭐

**为什么选择 PowerShell 7？**
- ✅ 完美支持中文，无乱码
- ✅ 更快、更现代
- ✅ 完全免费

**安装步骤：**

1. **双击运行：** `install-pwsh7.ps1`

   或者在命令行中执行：
   ```cmd
   powershell -ExecutionPolicy Bypass -File install-pwsh7.ps1
   ```

2. **等待安装完成**（需要网络连接）

3. **运行软件安装脚本：**
   - 双击：`run-pwsh7.bat`
   - 或双击：`run-auto.bat`（会自动选择最佳 PowerShell）

---

### 方案 B：直接使用（可能有乱码）

如果你不想安装 PowerShell 7，可以直接运行：

```cmd
run.bat
```

⚠️ 注意：使用 Windows PowerShell 5.1 可能会有中文乱码问题。

---

## 📋 所有运行方式对比

| 文件名 | 说明 | 中文支持 | 推荐度 |
|--------|------|----------|--------|
| `run-auto.bat` | 自动选择最佳 PowerShell | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| `scripts\run-pwsh7.bat` | 使用 PowerShell 7 | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| `scripts\run.bat` | 使用 Windows PowerShell | ⚠️ 可能乱码 | ⭐⭐ |
| `scripts\run.ps1` | 直接运行脚本 | 取决于环境 | ⭐⭐⭐ |

---

## 🔧 一行命令安装 PowerShell 7

如果你已经安装了 winget：

```powershell
winget install Microsoft.PowerShell
```

---

## 🎯 推荐工作流程

### 首次使用：

1. 双击 `install-pwsh7.ps1` → 安装 PowerShell 7
2. 双击 `run-auto.bat` → 运行软件安装脚本
3. 查看日志文件（在 `C:\Temp\logs` 目录）

### 后续使用：

直接双击 `run-auto.bat` 即可！

---

## ❓ 常见问题

### Q: 必须安装 PowerShell 7 吗？
A: 不是必须的，但强烈推荐。Windows PowerShell 5.1 可能会有中文显示问题。

### Q: PowerShell 7 会替换掉 Windows PowerShell 吗？
A: 不会！两者可以共存。PowerShell 7 命令是 `pwsh`，Windows PowerShell 命令是 `powershell`。

### Q: PowerShell 7 安全吗？
A: 是的！PowerShell 7 是微软官方开发的开源项目，完全安全。
项目地址：https://github.com/PowerShell/PowerShell

### Q: 安装失败怎么办？
A: 可以手动下载安装：
1. 访问：https://github.com/PowerShell/PowerShell/releases/latest
2. 下载：`PowerShell-7.x.x-win-x64.msi`
3. 运行安装程序

---

## 📞 需要帮助？

如果遇到问题，请查看完整文档：`README.md`

