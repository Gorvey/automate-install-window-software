# 测试编码的脚本
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "测试中文显示" -ForegroundColor Green
Write-Host "如果你能看到这行中文，说明编码正确" -ForegroundColor Cyan
Write-Host "Test English text" -ForegroundColor Yellow

Write-Host "`n当前编码信息:" -ForegroundColor Magenta
Write-Host "OutputEncoding: $([Console]::OutputEncoding.EncodingName)"
Write-Host "脚本编码测试: 开始检查 Winget 应用" -ForegroundColor Green

Read-Host "`n按回车键退出"

