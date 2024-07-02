# InstallAndConfigWithWin



## Getting started

打开Windows PowerShell 管理员，执行appInstall执行安装所需应用。
## 应用列表：
### 日常类

- utools
- nextcloud
- clash-for-Windows
- wechat
- chrome
- auto-darkmodel
- notion
- telegram
- Spotify.Spotify

### 开发

- git
- JetBrains.IntelliJIDEA.Ultimate
- Microsoft.VisualStudioCode
- powershell
- svn
- ZeroTier.ZeroTierOne
- OpenVPNTechnologies.OpenVPN
- scoop

```powershell
# 设置策略可执行
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
# 安装
iwr -useb get.scoop.sh | iex
# maven
scoop install maven
```

- EclipseAdoptium.Temurin.8.JDK
- dbeaver.dbeaver

### 配置

1、ssh

```powershell
# 切换到cmd管理员执行
mklink /D C:\Users\%USERNAME%\.ssh  C:\Users\%USERNAME%\OneDrive\Storage\SSH
```

2、maven

```bash
# 切换到cmd管理员执行
mklink  C:\Users\%USERNAME%\.m2\settings.xml  C:\Users\%USERNAME%\OneDrive\Storage\MAVEN\settings.xml
```

3、idea

- Jrebel
- GitToolBox

4、jrebel

http://192.168.202.199:8787/7ab4659d-cf30-4589-bb66-7c36669c8e4d

5、dbeaver
```
# 切换到cmd管理员执行
mklink /D  C:\Users\%USERNAME%\AppData\Roaming\DBeaverData\workspace6  C:\Users\%USERNAME%\OneDrive\Storage\DBeaver\workspace6
```
