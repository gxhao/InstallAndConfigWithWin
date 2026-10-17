[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param()

$ErrorActionPreference = 'Stop'

# 要卸载的可选 Windows 应用包名称（AppX/MSIX 包名）。
# 核心 Windows 应用、运行框架、驱动、编解码器、Microsoft Store、Edge 和系统外壳组件不在列表中。
$AppNames = @(
    'Clipchamp.Clipchamp'
    'Microsoft.BingNews'
    'Microsoft.BingWeather'
    'Microsoft.MicrosoftOfficeHub'
    'Microsoft.MicrosoftSolitaireCollection'
    'Microsoft.MixedReality.Portal'
    'Microsoft.SkypeApp'
    'Microsoft.Todos'
    'Microsoft.WindowsMaps'
    'Microsoft.WindowsFeedbackHub'
    'Microsoft.Windows.DevHome'
    'Microsoft.PowerAutomateDesktop'
    'Microsoft.OutlookForWindows'
    'MSTeams'
    'Microsoft.YourPhone'
    'Microsoft.GamingApp'
    'Microsoft.XboxGameOverlay'
    'Microsoft.XboxGamingOverlay'
    'Microsoft.XboxIdentityProvider'
)

function Write-RunLog {
    param([Parameter(Mandatory)][string]$Message)

    # 同时将带时间戳的消息写到控制台和本次运行的日志文件。
    $line = '{0}  {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    Write-Host $line
    Add-Content -LiteralPath $script:LogPath -Value $line -Encoding UTF8
}

# 查询当前 PowerShell 进程的身份；移除所有用户的应用包需要管理员权限。
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw '请右键 PowerShell，选择“以管理员身份运行”，然后重新运行此脚本。'
}

# 日志放在脚本所在目录，文件名带运行时间，避免覆盖之前的记录。
$script:LogPath = Join-Path $PSScriptRoot ('Remove-WindowsOptionalApps-{0}.log' -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType File -Path $script:LogPath -Force | Out-Null
Write-RunLog "Starting. Log: $script:LogPath"

try {
    # 获取当前系统中所有用户配置文件已安装的 AppX 包，只保留白名单中的目标应用。
    $installedPackages = @(Get-AppxPackage -AllUsers | Where-Object { $AppNames -contains $_.Name })
} catch {
    Write-RunLog "Failed to enumerate installed AppX packages: $($_.Exception.Message)"
    throw
}

$installedPackages = @($installedPackages | Sort-Object PackageFullName -Unique)
foreach ($package in $installedPackages) {
    # ShouldProcess 提供 -WhatIf / -Confirm 支持；执行删除前会按 PowerShell 的确认策略处理。
    $target = '{0} ({1}) for all users' -f $package.Name, $package.PackageFullName
    if ($PSCmdlet.ShouldProcess($target, 'Remove-AppxPackage')) {
        try {
            Remove-AppxPackage -Package $package.PackageFullName -AllUsers -ErrorAction Stop
            Write-RunLog "Removed installed package: $($package.Name)"
        } catch {
            Write-RunLog "FAILED to remove installed package $($package.Name): $($_.Exception.Message)"
        }
    } else {
        Write-RunLog "Preview/declined installed package removal: $($package.Name)"
    }
}

try {
    # 已安装包的删除不会自动阻止新用户再次获得应用，因此也检查在线 Windows 镜像中的预配包。
    # 移除预配包后，新建用户通常不会再自动安装该应用；现有用户的安装由上面的步骤处理。
    $provisionedPackages = @(Get-AppxProvisionedPackage -Online | Where-Object { $AppNames -contains $_.DisplayName })
    foreach ($package in $provisionedPackages) {
        $target = '{0} ({1}) from the online Windows image' -f $package.DisplayName, $package.PackageName
        if ($PSCmdlet.ShouldProcess($target, 'Remove-AppxProvisionedPackage')) {
            try {
                Remove-AppxProvisionedPackage -Online -PackageName $package.PackageName -ErrorAction Stop | Out-Null
                Write-RunLog "Removed provisioned package: $($package.DisplayName)"
            } catch {
                Write-RunLog "FAILED to remove provisioned package $($package.DisplayName): $($_.Exception.Message)"
            }
        } else {
            Write-RunLog "Preview/declined provisioned package removal: $($package.DisplayName)"
        }
    }
} catch {
    Write-RunLog "Could not inspect/remove provisioned packages: $($_.Exception.Message)"
}

# -WhatIf 只预览计划操作，不应将后续状态检查误认为实际卸载结果。
if ($WhatIfPreference) {
    Write-RunLog 'WhatIf run complete; no packages were removed.'
} else {
    # 卸载后复查用户配置文件中的安装包，记录仍然存在的目标应用。
    try {
        $remainingInstalled = @(Get-AppxPackage -AllUsers | Where-Object { $AppNames -contains $_.Name } | Select-Object -ExpandProperty Name -Unique)
        if ($remainingInstalled.Count -eq 0) {
            Write-RunLog 'Verification: selected apps are absent from installed user profiles.'
        } else {
            Write-RunLog "Verification: selected apps still installed: $($remainingInstalled -join ', ')"
        }
    } catch {
        Write-RunLog "Could not verify installed packages: $($_.Exception.Message)"
    }

    # 复查 Windows 预配列表，确认新用户默认安装项是否已清理。
    try {
        $remainingProvisioned = @(Get-AppxProvisionedPackage -Online | Where-Object { $AppNames -contains $_.DisplayName } | Select-Object -ExpandProperty DisplayName -Unique)
        if ($remainingProvisioned.Count -eq 0) {
            Write-RunLog 'Verification: no selected apps remain in the Windows provisioning list.'
        } else {
            Write-RunLog "Verification: selected apps remain provisioned: $($remainingProvisioned -join ', ')"
        }
    } catch {
        Write-RunLog "Could not verify provisioned packages: $($_.Exception.Message)"
    }
}

Write-RunLog 'Finished.'
Write-Host "`nLog saved to: $script:LogPath"
