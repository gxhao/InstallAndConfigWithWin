# Windows 安装与配置脚本

这个仓库包含用于配置 Windows 开发环境的 PowerShell 脚本。脚本会安装常用软件、设置开发工具，并调整部分 Windows 用户和系统选项。运行前请先阅读各脚本的操作范围，并确认电脑上的文件和配置已经备份。

## 脚本说明

| 脚本 | 用途 |
| --- | --- |
| `appInstall.ps1` | 检查并安装 WinGet 软件源和应用；需要管理员权限。还会尝试移除 Microsoft Paint、3D Viewer，并清理当前用户和公共桌面的快捷方式。 |
| `windowsConfig.ps1` | 配置 Git、SSH、Maven、DBeaver、PATH、终端启动任务、电源、资源管理器、网络和其他 Windows 选项。部分设置涉及系统注册表或管理员权限。 |
| `Remove-WindowsOptionalApps.ps1` | 按脚本中的应用名称清单，移除所有用户已安装的可选应用及 Windows 预配包。支持 `-WhatIf` 预览和 `-Confirm` 确认。 |

### `appInstall.ps1` 安装的软件

脚本通过 WinGet 安装或检查以下应用：

- 开发工具：Visual Studio Code、Go、Node.js、Git、Python、PowerShell、Java 8 JDK
- 日常应用：Chrome、QQ、微信、Telegram、VLC、ChatGPT、iCloud、Apple Music
- 系统工具：gsudo、7-Zip、CPU-Z、WinDirStat、DB Browser for SQLite、CrystalDiskInfo、CrystalDiskMark
- Microsoft Store 应用：Windows Terminal、便笺、视频扩展、WinDynamicDesktop

实际安装结果取决于当前脚本中的包 ID、WinGet 源、网络连接及 Windows 应用商店可用性。

## 运行前准备

1. 在受支持的 Windows 环境中使用 Windows PowerShell，并确保系统已安装或能够安装 WinGet。
2. 查看脚本中的应用清单和配置路径。`windowsConfig.ps1` 预期 OneDrive 中存在 `Storage\SSH`、`Storage\MAVEN`、`Storage\DBeaver` 等目录。
3. 以管理员身份打开 Windows PowerShell。安装脚本会调整当前用户的执行策略；配置脚本还会修改系统设置。
4. 先备份桌面文件、回收站内容、SSH/Maven/DBeaver 配置及重要数据。

## 使用方法

推荐先将仓库下载到本机，检查脚本内容后再运行。不要在未阅读脚本的情况下直接执行远程下载并运行的命令。

在仓库目录中打开管理员 PowerShell，按需执行：

```powershell
# 安装应用
powershell -ExecutionPolicy Bypass -File .\appInstall.ps1

# 配置 Windows 和开发环境
powershell -ExecutionPolicy Bypass -File .\windowsConfig.ps1

# 预览可选应用移除操作，不会实际卸载
powershell -ExecutionPolicy Bypass -File .\Remove-WindowsOptionalApps.ps1 -WhatIf

# 确认清单无误后，执行可选应用移除
powershell -ExecutionPolicy Bypass -File .\Remove-WindowsOptionalApps.ps1 -Confirm
```

也可以在当前管理员 PowerShell 会话中使用：

```powershell
.\Remove-WindowsOptionalApps.ps1 -WhatIf
```

`-WhatIf` 和 `-Confirm` 仅适用于 `Remove-WindowsOptionalApps.ps1`。`appInstall.ps1` 和 `windowsConfig.ps1` 没有提供统一的预览模式。

## 重要影响

- `windowsConfig.ps1` 会删除当前用户桌面和公共桌面中的内容，并清空当前驱动器的回收站。运行前请保存需要保留的文件。
- 脚本会删除或重建 `.ssh`、Maven `settings.xml` 和 DBeaver 工作区的本地路径，再将它们链接到 OneDrive 中的配置。确认目标目录存在且数据已备份。
- 脚本会更改机器 PATH、注册表、电源和网络配置，添加 Microsoft Defender 排除路径，并设置登录时启动 Windows Terminal 的计划任务。
- 脚本可在交互过程中触发 Windows 更新、系统文件检查、磁盘检查和自动重启。运行期间请留意提示并保存工作。
- `Remove-WindowsOptionalApps.ps1` 会移除脚本清单中的应用。清单在 `$AppNames` 数组中维护；移除预配包会影响之后创建的用户配置文件。

## 日志与问题排查

`Remove-WindowsOptionalApps.ps1` 会在脚本所在目录生成带时间戳的 `Remove-WindowsOptionalApps-*.log` 文件。安装和配置脚本主要通过控制台输出状态信息；若某一步失败，请记录错误信息，并检查管理员权限、WinGet 源、网络连接及 OneDrive 配置目录。
