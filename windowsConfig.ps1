
Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 3  - Terminal    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green



$driveLetter = (Get-Location).Drive.Name
$computerName = Read-Host "Enter New Computer Name if you want to rename it: ($($env:COMPUTERNAME))"
$CloudPath = "Z:\"

function AddToPath {
    param (
        [string]$folder
    )

    Write-Host "Adding $folder to environment variables..." -ForegroundColor Yellow

    $currentEnv = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine).Trim(";");
    $addedEnv = $currentEnv + ";$folder"
    $trimmedEnv = (($addedEnv.Split(';') | Select-Object -Unique) -join ";").Trim(";")
    [Environment]::SetEnvironmentVariable(
        "Path",
        $trimmedEnv,
        [EnvironmentVariableTarget]::Machine)

    #Write-Host "Reloading environment variables..." -ForegroundColor Green
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

AddToPath -folder "C:\Program Files\Git\bin"
AddToPath -folder "C:\Program Files\VideoLAN\VLC"




# 长路径支持
# New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force

## ==============config ssh

Write-Host "Linking back SSH keys..." -ForegroundColor Green
$iCloudDriveSshConfigPath = "$CloudPath\Storage\SSH\"
$localSshConfigPath = "$HOME\.ssh\"
cmd /c "rmdir $localSshConfigPath /s /q"
cmd /c "mklink /d `"$localSshConfigPath`" `"$iCloudDriveSshConfigPath`""
Write-Host "Testing SSH features..." -ForegroundColor Green
Write-Host "yes" | ssh -o "StrictHostKeyChecking no" git@github.com

# ================config git 
Write-Host "Configuring git..." -ForegroundColor Green
Write-Host "Setting git email to $email" -ForegroundColor Yellow
Write-Host "Setting git name to $name" -ForegroundColor Yellow
git config --global user.email 1625546088@qq.com
git config --global user.name gxhao
git config --global core.autocrlf true
git config --global core.longpaths true

# ================config maven
Write-Host "Linking back maven settings.xml..." -ForegroundColor Green
$iCloudDriveSshConfigPath = "$CloudPath\Storage\MAVEN\settings.xml"
$localSshConfigPath = "$HOME\.m2\settings.xml" 
# Ensure file is available.
cmd /c "del /f /q $localSshConfigPath "
cmd /c "mklink `"$localSshConfigPath`" `"$iCloudDriveSshConfigPath`""
Write-Host "Testing maven features..." -ForegroundColor Green
mvn


# ================config dbeaver
Write-Host "Linking back dbeaver config..." -ForegroundColor Green
$iCloudDriveSshConfigPath = "$CloudPath\Storage\DBeaver\workspace6"
$localSshConfigPath = "$HOME\AppData\Roaming\DBeaverData\workspace6"
cmd /c "rmdir $localSshConfigPath /q"
cmd /c "mklink /d `"$localSshConfigPath`" `"$iCloudDriveSshConfigPath`""
Write-Host "Testing dbeaver features..." -ForegroundColor Green



# =====================config maven
AddToPath -folder "$HOME\OneDrive\Storage\env\maven\bin"

# =====================config svn 

AddToPath -folder "$HOME\OneDrive\Storage\TortoiseSVN\bin"

# =====================config java
Write-Host "JAVA version"
java -version

# =====================config openvpn
Write-Host "Linking back openvpn config..." -ForegroundColor Green
$iCloudDriveSshConfigPath = "$CloudPath\Storage\OpenVpn"
$localSshConfigPath = "$HOME\OpenVPN\config\gxhao"
cmd /c "rmdir $localSshConfigPath /q"
cmd /c "mklink /d `"$localSshConfigPath`" `"$iCloudDriveSshConfigPath`""

Write-Host "Configuring bash profile and bash rc..." -ForegroundColor Green
$bashProfile = "# generated by win.aiurs.co
test -f ~/.profile && . ~/.profile
test -f ~/.bashrc && . ~/.bashrc"
Set-Content -Path "$env:HOMEPATH\.bash_profile" -Value $bashProfile
$bashRC = "# generated by win.aiurs.co
alias sudo=`"gsudo`"
alias redis-cli=`"rdcli`""
Set-Content -Path "$env:HOMEPATH\.bashrc" -Value $bashRC

if (Get-ScheduledTask -TaskName "WT" -ErrorAction SilentlyContinue) { 
    Write-Host "Task schduler already configured." -ForegroundColor Green
} else {
    Write-Host "Configuring task scheduler to start WT in the background..." -ForegroundColor Green
    Set-Content -Path "$env:APPDATA\terminal.vbs" -Value "CreateObject(`"WScript.Shell`").Run `"wt.exe`", 0, True"
    $taskAction = New-ScheduledTaskAction -Execute "$env:APPDATA\terminal.vbs"
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    Register-ScheduledTask -Action $taskAction -Trigger $trigger -TaskName "WT" -Description "Start WT in the background."
}


Write-Host "Disable Sleep on AC Power..." -ForegroundColor Green
Powercfg /Change monitor-timeout-ac 20
Powercfg /Change standby-timeout-ac 0
Write-Host "Monitor timeout set to 20."



Write-Host "Removing Bluetooth icons..." -ForegroundColor Green
cmd.exe /c "reg add `"HKCU\Control Panel\Bluetooth`" /v `"Notification Area Icon`" /t REG_DWORD /d 0 /f"

Write-Host "Applying file explorer settings..." -ForegroundColor Green
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v AutoCheckSelect /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v LaunchTo /t REG_DWORD /d 1 /f"



Write-Host "Cleaning desktop..." -ForegroundColor Green
Remove-Item $HOME\Desktop\* -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue
Remove-Item "C:\Users\Public\Desktop\*" -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue

Write-Host "Resetting desktop..." -ForegroundColor Yellow
Stop-Process -Name explorer -Force
Write-Host "Desktop cleaned."

$networkProfiles = Get-NetConnectionProfile
foreach ($networkProfile in $networkProfiles) {
    Write-Host "Setting network $($networkProfile.Name) to home network to enable more features..." -ForegroundColor Green
    Write-Host "This is dangerous because your roommates may detect your device is online." -ForegroundColor Yellow
    Set-NetConnectionProfile -Name $networkProfile.Name -NetworkCategory Private
}

Write-Host "Clearing recycle bin..." -ForegroundColor Green
Write-Host "Recycle bin cleared on $driveLetter..."
Clear-RecycleBin -DriveLetter $driveLetter -Force -Confirm

# Disabling Active Probing may increase performance. But on some machines may cause UWP unable to connect to Internet.
Write-Host "Disabling rubbish Active Probing..." -ForegroundColor Green
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet\" -Name EnableActiveProbing -Value 0 -Force
Write-Host "Disabled Active Probing."

# Write-Host "Clearing start up..." -ForegroundColor Green
# $startUp = $env:USERPROFILE + "\Start Menu\Programs\StartUp\*"
# Get-ChildItem $startUp
# Remove-Item -Path $startUp
# Get-ChildItem $startUp

Write-Host "Remove rubbish 3D objects..." -ForegroundColor Green
Remove-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}' -ErrorAction SilentlyContinue
Write-Host "3D objects deleted."

Write-Host "Setting Power Policy to ultimate..." -ForegroundColor Green
powercfg /s e9a42b02-d5df-448d-aa00-03f14749eb61
powercfg /list

Write-Host "Enabling desktop icons..." -ForegroundColor Green
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu /v {20D04FE0-3AEA-1069-A2D8-08002B30309D} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {20D04FE0-3AEA-1069-A2D8-08002B30309D} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu /v {59031a47-3f72-44a7-89c5-5595fe6b30ee} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {59031a47-3f72-44a7-89c5-5595fe6b30ee} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu /v {645FF040-5081-101B-9F08-00AA002F954E} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {645FF040-5081-101B-9F08-00AA002F954E} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu /v {F02C1A0D-BE21-4350-88B0-7367FC96EF3C} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {F02C1A0D-BE21-4350-88B0-7367FC96EF3C} /t REG_DWORD /d 0 /f"

Write-Host "Enabling Hardware-Accelerated GPU Scheduling..." -ForegroundColor Green
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\" -Name 'HwSchMode' -Value '2' -PropertyType DWORD -Force


Write-Host "Exclude repos from Windows Defender..." -ForegroundColor Green
Add-MpPreference -ExclusionPath "$env:USERPROFILE\Code"
Add-MpPreference -ExclusionPath "$env:USERPROFILE\.vscode"
Add-MpPreference -ExclusionPath "$env:USERPROFILE\.ssh"
Add-MpPreference -ExclusionPath "$env:APPDATA\npm"
Add-MpPreference -ExclusionPath "$OneDrivePath"



Write-Host "Press the [C] key to continue to steps which requires reboot."
$pressedKey = Read-Host
Write-Host "You pressed: $($pressedKey)"
if ($pressedKey -eq 'c') {  
    Write-Host "Scanning missing dlls..." -ForegroundColor Green
    sfc /scannow
    Write-Host y | chkdsk "$($driveLetter):" /f /r /x

    Write-Host "Checking for windows updates..." -ForegroundColor Green
    Install-Module -Name PSWindowsUpdate -Force
    Write-Host "Installing updates... (Computer will reboot in minutes...)" -ForegroundColor Green
    Get-WindowsUpdate -AcceptAll -Install -ForceInstall -AutoReboot

    # cmd.exe /c "netsh winsock reset catalog"
    # cmd.exe /c "netsh int ip reset reset.log"
    # cmd.exe /c "ipconfig /flushdns"
    # cmd.exe /c "ipconfig /registerdns"
    # cmd.exe /c "route /f"
    cmd.exe /c "sc config FDResPub start=auto"
    cmd.exe /c "sc config fdPHost start=auto"
    cmd.exe /c "shutdown -r -t 70"
}