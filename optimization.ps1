
#requires -Version 5.1
#requires -RunAsAdministrator

<#
.SYNOPSIS
    Windows 11 UI responsiveness optimizer with backup and restore support.

.DESCRIPTION
    Provides an interactive menu to apply performance-focused UI tweaks, restore previous values from timestamped backups, or inspect current optimization status. The script safeguards all registry keys touched and the active power scheme before making changes.

.PARAMETER VerboseMode
    Enable detailed logging to file and console

.PARAMETER MaxBackups
    Maximum number of backups to retain (default: 10)

.NOTES
    Version: 2.0.0
    Author: Senior Software Engineer
    Last Modified: 2025-11-03
#>

[CmdletBinding()]
param(
    [Parameter()]
    [switch]$VerboseMode,

    [Parameter()]
    [ValidateRange(1, 100)]
    [int]$MaxBackups = 10
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Script-level variables
$Script:BackupRoot = Join-Path -Path $env:LOCALAPPDATA -ChildPath 'Win11-UI-Optimizer\Backups'
$Script:LogRoot = Join-Path -Path $env:LOCALAPPDATA -ChildPath 'Win11-UI-Optimizer\Logs'
$Script:LogFile = $null
$Script:VerboseMode = $VerboseMode.IsPresent

$Script:RegistryTweaks = @(
    [pscustomobject]@{
        FriendlyName = 'Reduce menu show delay'
        Hive = 'HKCU'
        Path = 'Control Panel\Desktop'
        Name = 'MenuShowDelay'
        DesiredValue = '20'
        Type = 'String'
    }
    [pscustomobject]@{
        FriendlyName = 'Disable minimize and restore animations'
        Hive = 'HKCU'
        Path = 'Control Panel\Desktop'
        Name = 'MinAnimate'
        DesiredValue = '0'
        Type = 'String'
    }
    [pscustomobject]@{
        FriendlyName = 'Disable transparency effects'
        Hive = 'HKCU'
        Path = 'Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
        Name = 'EnableTransparency'
        DesiredValue = 0
        Type = 'DWord'
    }
    [pscustomobject]@{
        FriendlyName = 'Disable taskbar animations'
        Hive = 'HKCU'
        Path = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        Name = 'TaskbarAnimations'
        DesiredValue = 0
        Type = 'DWord'
    }
    [pscustomobject]@{
        FriendlyName = 'Disable list view fade selection'
        Hive = 'HKCU'
        Path = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        Name = 'ListviewAlphaSelect'
        DesiredValue = 0
        Type = 'DWord'
    }
    [pscustomobject]@{
        FriendlyName = 'Disable list view shadows'
        Hive = 'HKCU'
        Path = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        Name = 'ListviewShadow'
        DesiredValue = 0
        Type = 'DWord'
    }
    [pscustomobject]@{
        FriendlyName = 'Open File Explorer to This PC'
        Hive = 'HKCU'
        Path = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        Name = 'LaunchTo'
        DesiredValue = 1
        Type = 'DWord'
    }
    [pscustomobject]@{
        FriendlyName = 'Disable Start menu recent items'
        Hive = 'HKCU'
        Path = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        Name = 'Start_TrackDocs'
        DesiredValue = 0
        Type = 'DWord'
    }
    [pscustomobject]@{
        FriendlyName = 'Adjust visual effects for best performance'
        Hive = 'HKCU'
        Path = 'Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects'
        Name = 'VisualFXSetting'
        DesiredValue = 2
        Type = 'DWord'
    }
    [pscustomobject]@{
        FriendlyName = 'Disable Aero Peek preview'
        Hive = 'HKCU'
        Path = 'Software\Microsoft\Windows\DWM'
        Name = 'EnablePeek'
        DesiredValue = 0
        Type = 'DWord'
    }
    [pscustomobject]@{
        FriendlyName = 'Disable background apps globally'
        Hive = 'HKCU'
        Path = 'Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications'
        Name = 'GlobalUserDisabled'
        DesiredValue = 1
        Type = 'DWord'
    }
    [pscustomobject]@{
        FriendlyName = 'Disable search background execution'
        Hive = 'HKCU'
        Path = 'Software\Microsoft\Windows\CurrentVersion\Search'
        Name = 'BackgroundAppGlobalToggle'
        DesiredValue = 0
        Type = 'DWord'
    }
    [pscustomobject]@{
        FriendlyName = 'Disable Start menu content suggestions'
        Hive = 'HKCU'
        Path = 'Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
        Name = 'SystemPaneSuggestionsEnabled'
        DesiredValue = 0
        Type = 'DWord'
    }
    [pscustomobject]@{
        FriendlyName = 'Disable Start menu suggestions'
        Hive = 'HKCU'
        Path = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        Name = 'Start_ShowSuggestions'
        DesiredValue = 0
        Type = 'DWord'
    }
    [pscustomobject]@{
        FriendlyName = 'Eliminate startup application delay'
        Hive = 'HKLM'
        Path = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize'
        Name = 'StartupDelayInMSec'
        DesiredValue = 0
        Type = 'DWord'
    }
)

# region Logging helpers
function Initialize-Logging {
    try {
        if (-not (Test-Path -LiteralPath $Script:LogRoot)) {
            New-Item -ItemType Directory -Path $Script:LogRoot -Force | Out-Null
        }

        $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
        $Script:LogFile = Join-Path -Path $Script:LogRoot -ChildPath "optimizer_$timestamp.log"
        
        Write-LogMessage -Message "=== Windows 11 UI Optimizer - Session Started ===" -Level 'INFO'
        Write-LogMessage -Message "Log file: $Script:LogFile" -Level 'INFO'
        
        # Cleanup old log files (keep last 30 days)
        $cutoffDate = (Get-Date).AddDays(-30)
        Get-ChildItem -Path $Script:LogRoot -Filter '*.log' -File | 
            Where-Object { $_.LastWriteTime -lt $cutoffDate } |
            Remove-Item -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Warning "Failed to initialize logging: $_"
    }
}

function Write-LogMessage {
    param(
        [Parameter(Mandatory)][string]$Message,
        [Parameter()][ValidateSet('INFO', 'SUCCESS', 'WARNING', 'ERROR', 'DEBUG')]
        [string]$Level = 'INFO'
    )
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logEntry = "[$timestamp] [$Level] $Message"
    
    # Write to file
    if ($null -ne $Script:LogFile) {
        try {
            Add-Content -Path $Script:LogFile -Value $logEntry -Encoding UTF8 -ErrorAction SilentlyContinue
        } catch {
            # Silently fail if logging to file fails
        }
    }
    
    # Write to console based on verbosity
    if ($Level -eq 'DEBUG' -and -not $Script:VerboseMode) {
        return
    }
}

function Write-InfoMessage {
    param([Parameter(Mandatory)][string]$Message)
    Write-LogMessage -Message $Message -Level 'INFO'
    Write-Host "[INFO ] $Message" -ForegroundColor Cyan
}

function Write-SuccessMessage {
    param([Parameter(Mandatory)][string]$Message)
    Write-LogMessage -Message $Message -Level 'SUCCESS'
    Write-Host "[ OK  ] $Message" -ForegroundColor Green
}

function Write-WarningMessage {
    param([Parameter(Mandatory)][string]$Message)
    Write-LogMessage -Message $Message -Level 'WARNING'
    Write-Host "[WARN ] $Message" -ForegroundColor Yellow
}

function Write-ErrorMessage {
    param([Parameter(Mandatory)][string]$Message)
    Write-LogMessage -Message $Message -Level 'ERROR'
    Write-Host "[FAIL ] $Message" -ForegroundColor Red
}

function Write-DebugMessage {
    param([Parameter(Mandatory)][string]$Message)
    Write-LogMessage -Message $Message -Level 'DEBUG'
    if ($Script:VerboseMode) {
        Write-Host "[DEBUG] $Message" -ForegroundColor Gray
    }
}
# endregion

# region Registry helpers
function Get-RegistryProviderPath {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Hive,
        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )
    
    Write-DebugMessage "Building registry path for $Hive\$Path"
    return "Registry::$Hive\$Path"
}

function ConvertTo-RegistryValue {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Type,
        
        [Parameter()]
        [AllowNull()]
        $Value
    )

    $normalizedType = $Type.ToLowerInvariant()
    Write-DebugMessage "Converting value '$Value' to type '$normalizedType'"

    try {
        switch ($normalizedType) {
            'dword' { 
                if ($null -eq $Value) { return 0 }
                return [int]$Value 
            }
            'qword' { 
                if ($null -eq $Value) { return [long]0 }
                return [long]$Value 
            }
            'string' {
                if ($null -eq $Value) { return [string]::Empty }
                return [string]$Value
            }
            'expandstring' {
                if ($null -eq $Value) { return [string]::Empty }
                return [string]$Value
            }
            default { 
                Write-WarningMessage "Unknown registry type '$Type', defaulting to string"
                return [string]$Value 
            }
        }
    } catch {
        Write-ErrorMessage "Failed to convert value '$Value' to type '$Type': $_"
        throw
    }
}

function Get-RegistryPropertyTypeName {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Type
    )

    $normalizedType = $Type.ToLowerInvariant()
    
    switch ($normalizedType) {
        'dword' { return 'DWord' }
        'qword' { return 'QWord' }
        'expandstring' { return 'ExpandString' }
        'multistring' { return 'MultiString' }
        'binary' { return 'Binary' }
        default { return 'String' }
    }
}

function Get-RegistryValue {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Hive,
        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    $regPath = Get-RegistryProviderPath -Hive $Hive -Path $Path
    Write-DebugMessage "Reading registry value: $regPath\$Name"
    
    try {
        if (-not (Test-Path -LiteralPath $regPath)) {
            Write-DebugMessage "Registry path does not exist: $regPath"
            return [pscustomobject]@{
                Exists = $false
                Value = $null
                ValueKind = $null
            }
        }

        $key = Get-Item -Path $regPath -ErrorAction Stop
        $value = $key.GetValue($Name, $null)
        
        if ($null -eq $value) {
            Write-DebugMessage "Registry value does not exist: $Name"
            return [pscustomobject]@{
                Exists = $false
                Value = $null
                ValueKind = $null
            }
        }

        $kind = $key.GetValueKind($Name)
        Write-DebugMessage "Found value: $value (Type: $kind)"
        
        return [pscustomobject]@{
            Exists = $true
            Value = $value
            ValueKind = $kind.ToString()
        }
    } catch {
        Write-ErrorMessage "Failed to read registry value $regPath\$Name : $_"
        throw
    }
}

function Set-RegistryValue {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Hive,
        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Type,
        
        [Parameter()]
        [AllowNull()]
        $Value
    )

    $regPath = Get-RegistryProviderPath -Hive $Hive -Path $Path
    Write-DebugMessage "Ensuring registry value: $regPath\$Name = $Value"
    
    try {
        if (-not (Test-Path -LiteralPath $regPath)) {
            Write-DebugMessage "Creating registry path: $regPath"
            New-Item -Path $regPath -Force -ErrorAction Stop | Out-Null
        }

        $convertedValue = ConvertTo-RegistryValue -Type $Type -Value $Value
        $existing = Get-RegistryValue -Hive $Hive -Path $Path -Name $Name

        if ($existing.Exists) {
            Write-DebugMessage "Updating existing registry value"
            Set-ItemProperty -Path $regPath -Name $Name -Value $convertedValue -ErrorAction Stop | Out-Null
        } else {
            $propertyType = Get-RegistryPropertyTypeName -Type $Type
            Write-DebugMessage "Creating new registry value with type $propertyType"
            New-ItemProperty -Path $regPath -Name $Name -PropertyType $propertyType -Value $convertedValue -Force -ErrorAction Stop | Out-Null
        }
    } catch {
        Write-ErrorMessage "Failed to ensure registry value $regPath\$Name : $_"
        throw
    }
}

function Remove-RegistryValue {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Hive,
        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    $regPath = Get-RegistryProviderPath -Hive $Hive -Path $Path
    Write-DebugMessage "Removing registry value: $regPath\$Name"
    
    try {
        if (Test-Path -LiteralPath $regPath) {
            Remove-ItemProperty -Path $regPath -Name $Name -ErrorAction SilentlyContinue
            Write-DebugMessage "Registry value removed successfully"
        }
    } catch {
        Write-WarningMessage "Failed to remove registry value $regPath\$Name : $_"
    }
}

function Test-RegistryValueMatch {
    param(
        [Parameter(Mandatory)]
        $CurrentValueInfo,
        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Type,
        
        [Parameter()]
        [AllowNull()]
        $DesiredValue
    )

    if (-not $CurrentValueInfo.Exists) {
        Write-DebugMessage "Registry value does not exist, no match"
        return $false
    }

    $normalizedType = $Type.ToLowerInvariant()
    $target = ConvertTo-RegistryValue -Type $normalizedType -Value $DesiredValue

    try {
        $result = switch ($normalizedType) {
            'dword' { ([int]$CurrentValueInfo.Value -eq [int]$target) }
            'qword' { ([long]$CurrentValueInfo.Value -eq [long]$target) }
            default { ([string]$CurrentValueInfo.Value -eq [string]$target) }
        }
        
        Write-DebugMessage "Value comparison result: $result (Current: $($CurrentValueInfo.Value), Target: $target)"
        return $result
    } catch {
        Write-WarningMessage "Failed to compare registry values: $_"
        return $false
    }
}
# endregion

# region Environment checks
function Assert-Administrator {
    Write-DebugMessage "Checking administrator privileges"
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'This script must be run from an elevated PowerShell session with administrator privileges.'
    }
    Write-DebugMessage "Administrator check passed"
}

function Test-Windows11 {
    Write-DebugMessage "Checking Windows version"
    try {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
        $isWin11 = ($os.Version -like '10.0*' -and [int]$os.BuildNumber -ge 22000)
        
        Write-DebugMessage "OS Version: $($os.Version), Build: $($os.BuildNumber), Windows 11: $isWin11"
        return $isWin11
    } catch {
        Write-ErrorMessage "Unable to determine OS version: $_"
        return $false
    }
}

function Test-BackupIntegrity {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$BackupFolder
    )
    
    Write-DebugMessage "Verifying backup integrity: $BackupFolder"
    
    try {
        $metadataPath = Join-Path -Path $BackupFolder -ChildPath 'backup.json'
        
        if (-not (Test-Path -LiteralPath $metadataPath)) {
            Write-WarningMessage "Backup metadata file not found"
            return $false
        }
        
        $json = Get-Content -Path $metadataPath -Raw -ErrorAction Stop
        $data = $json | ConvertFrom-Json -ErrorAction Stop
        
        if ($null -eq $data.Timestamp -or $null -eq $data.RegistryValues) {
            Write-WarningMessage "Backup metadata is incomplete"
            return $false
        }
        
        Write-DebugMessage "Backup integrity check passed"
        return $true
    } catch {
        Write-WarningMessage "Backup integrity check failed: $_"
        return $false
    }
}
# endregion

# region Power plan helpers
function Get-PowerSchemes {
    Write-DebugMessage "Enumerating power schemes"
    try {
        $output = & powercfg.exe /list 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-WarningMessage "powercfg.exe returned exit code $LASTEXITCODE"
        }
        
        $schemes = @()
        foreach ($line in $output) {
            if ($line -match 'Power Scheme GUID:\s+([0-9a-fA-F\-]+)\s+\((.+?)\)(\s*\*)?$') {
                $guid = $matches[1]
                $name = $matches[2].Trim()
                $isActive = -not [string]::IsNullOrEmpty($matches[3])
                
                $schemes += [pscustomobject]@{
                    Guid = $guid
                    Name = $name
                    IsActive = $isActive
                }
                Write-DebugMessage "Found power scheme: $name ($guid) Active: $isActive"
            }
        }
        
        Write-DebugMessage "Found $($schemes.Count) power schemes"
        return $schemes
    } catch {
        Write-ErrorMessage "Failed to enumerate power schemes: $_"
        return @()
    }
}

function Get-ActivePowerPlan {
    Write-DebugMessage "Getting active power plan"
    try {
        $output = & powercfg.exe /getactivescheme 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-WarningMessage "powercfg.exe /getactivescheme returned exit code $LASTEXITCODE"
        }
        
        foreach ($line in $output) {
            if ($line -match 'Power Scheme GUID:\s+([0-9a-fA-F\-]+)\s+\((.+?)\)') {
                $result = [pscustomobject]@{
                    Guid = $matches[1]
                    Name = $matches[2].Trim()
                }
                Write-DebugMessage "Active power plan: $($result.Name) ($($result.Guid))"
                return $result
            }
        }
    } catch {
        Write-ErrorMessage "Failed to read active power scheme: $_"
    }

    return [pscustomobject]@{
        Guid = $null
        Name = 'Unknown'
    }
}

function Set-PerformancePowerPlan {
    Write-InfoMessage "Checking power plan configuration..."
    
    $schemes = Get-PowerSchemes
    if (-not $schemes -or $schemes.Count -eq 0) {
        Write-WarningMessage "No power schemes found. Skipping power plan configuration."
        return
    }

    # Try to find Ultimate Performance first, then High Performance
    $target = $schemes | Where-Object { $_.Name -match 'Ultimate Performance' } | Select-Object -First 1
    
    if (-not $target) {
        # GUID for High Performance power plan
        $target = $schemes | Where-Object { $_.Guid -eq '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c' } | Select-Object -First 1
    }
    
    if (-not $target) {
        # Fallback to any plan with "performance" or "high" in the name
        $target = $schemes | Where-Object { $_.Name -match '(Performance|High)' } | Select-Object -First 1
    }

    if (-not $target) {
        Write-WarningMessage 'No high performance power scheme found. Skipping power plan update.'
        return
    }

    if ($target.IsActive) {
        Write-InfoMessage "Power plan already set to '$($target.Name)'."
        return
    }

    try {
        Write-InfoMessage "Setting power plan to '$($target.Name)'..."
        & powercfg.exe /setactive $target.Guid | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-SuccessMessage "Set active power plan to '$($target.Name)'."
        } else {
            Write-WarningMessage "powercfg.exe returned exit code $LASTEXITCODE when setting power plan."
        }
    } catch {
        Write-ErrorMessage "Failed to set power plan: $_"
    }
}

function Restore-PowerPlan {
    param(
        [Parameter(Mandatory)]
        $BackupData
    )

    Write-DebugMessage "Restoring power plan from backup"
    
    if ($null -eq $BackupData.PowerPlan -or [string]::IsNullOrEmpty($BackupData.PowerPlan.Guid)) {
        Write-WarningMessage 'No power plan information found in backup. Skipping power plan restore.'
        return
    }

    $schemes = Get-PowerSchemes
    $target = $schemes | Where-Object { $_.Guid -eq $BackupData.PowerPlan.Guid } | Select-Object -First 1

    if (-not $target) {
        Write-WarningMessage "Power plan '$($BackupData.PowerPlan.Name)' (GUID: $($BackupData.PowerPlan.Guid)) is not available on this system. Skipping restore."
        return
    }

    try {
        Write-InfoMessage "Restoring power plan to '$($BackupData.PowerPlan.Name)'..."
        & powercfg.exe /setactive $target.Guid | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-SuccessMessage "Restored power plan to '$($BackupData.PowerPlan.Name)'."
        } else {
            Write-WarningMessage "powercfg.exe returned exit code $LASTEXITCODE when restoring power plan."
        }
    } catch {
        Write-ErrorMessage "Failed to restore power plan: $_"
    }
}
# endregion

# region Backup and restore
function Export-RegistryKeys {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$BackupFolder
    )

    Write-DebugMessage "Exporting registry keys to $BackupFolder"
    $uniqueKeys = $Script:RegistryTweaks | Select-Object Hive, Path -Unique
    $exportCount = 0
    
    foreach ($key in $uniqueKeys) {
        $cleanName = ($key.Path -replace '[\\/:*?"<>|]', '_')
        $fileName = "{0}_{1}.reg" -f $key.Hive, $cleanName
        $destination = Join-Path -Path $BackupFolder -ChildPath $fileName

        $fullKeyPath = "$($key.Hive)\$($key.Path)"
        $regPath = Get-RegistryProviderPath -Hive $key.Hive -Path $key.Path
        
        if (-not (Test-Path -LiteralPath $regPath)) {
            Write-DebugMessage "Registry key $fullKeyPath not present. Skipping export."
            continue
        }

        try {
            & reg.exe export $fullKeyPath $destination /y 2>&1 | Out-Null
            
            if ($LASTEXITCODE -eq 0 -and (Test-Path -LiteralPath $destination)) {
                Write-DebugMessage "Exported $fullKeyPath to $fileName"
                $exportCount++
            } else {
                Write-WarningMessage "reg.exe export returned exit code $LASTEXITCODE for $fullKeyPath"
            }
        } catch {
            Write-WarningMessage "Failed to export $fullKeyPath : $_"
        }
    }
    
    Write-InfoMessage "Exported $exportCount registry keys"
}

function Backup-Settings {
    Write-InfoMessage "Creating backup of current settings..."
    
    try {
        if (-not (Test-Path -LiteralPath $Script:BackupRoot)) {
            New-Item -ItemType Directory -Path $Script:BackupRoot -Force | Out-Null
        }

        $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
        $backupFolder = Join-Path -Path $Script:BackupRoot -ChildPath "backup_$timestamp"
        New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null
        
        Write-DebugMessage "Backup folder: $backupFolder"

        # Capture current registry state
        $registrySnapshots = @()
        foreach ($tweak in $Script:RegistryTweaks) {
            try {
                $valueInfo = Get-RegistryValue -Hive $tweak.Hive -Path $tweak.Path -Name $tweak.Name
                $registrySnapshots += [pscustomobject]@{
                    FriendlyName = $tweak.FriendlyName
                    Hive = $tweak.Hive
                    Path = $tweak.Path
                    Name = $tweak.Name
                    Exists = $valueInfo.Exists
                    Value = $valueInfo.Value
                    ValueKind = $valueInfo.ValueKind
                }
            } catch {
                Write-WarningMessage "Failed to capture state for $($tweak.FriendlyName): $_"
                # Add a failed entry to maintain consistency
                $registrySnapshots += [pscustomobject]@{
                    FriendlyName = $tweak.FriendlyName
                    Hive = $tweak.Hive
                    Path = $tweak.Path
                    Name = $tweak.Name
                    Exists = $false
                    Value = $null
                    ValueKind = $null
                }
            }
        }

        # Create backup metadata
        $backupData = [ordered]@{
            Version = '2.0'
            Timestamp = (Get-Date).ToString('o')
            ComputerName = $env:COMPUTERNAME
            UserName = $env:USERNAME
            PowerPlan = Get-ActivePowerPlan
            RegistryValues = $registrySnapshots
            TweakCount = $registrySnapshots.Count
        }

        # Save metadata
        $metadataPath = Join-Path -Path $backupFolder -ChildPath 'backup.json'
        $backupData | ConvertTo-Json -Depth 10 | Set-Content -Path $metadataPath -Encoding UTF8
        Write-DebugMessage "Saved backup metadata to $metadataPath"

        # Export registry keys
        Export-RegistryKeys -BackupFolder $backupFolder

        # Verify backup
        if (Test-BackupIntegrity -BackupFolder $backupFolder) {
            Write-SuccessMessage "Backup created successfully at $backupFolder"
            
            # Cleanup old backups
            Remove-OldBackups -MaxBackups $MaxBackups
            
            return [pscustomobject]@{
                Folder = $backupFolder
                MetadataPath = $metadataPath
                Timestamp = $timestamp
            }
        } else {
            Write-ErrorMessage "Backup integrity verification failed"
            return $null
        }
    } catch {
        Write-ErrorMessage "Failed to create backup: $_"
        return $null
    }
}

function Remove-OldBackups {
    param(
        [Parameter(Mandatory)]
        [ValidateRange(1, 100)]
        [int]$MaxBackups
    )
    
    Write-DebugMessage "Checking for old backups (Max: $MaxBackups)"
    
    try {
        if (-not (Test-Path -LiteralPath $Script:BackupRoot)) {
            return
        }

        $backups = Get-ChildItem -Path $Script:BackupRoot -Directory | 
                   Where-Object { $_.Name -match '^backup_\d{8}_\d{6}$' } |
                   Sort-Object Name -Descending

        if ($backups.Count -le $MaxBackups) {
            Write-DebugMessage "Current backup count ($($backups.Count)) is within limit"
            return
        }

        $toRemove = $backups | Select-Object -Skip $MaxBackups
        
        foreach ($backup in $toRemove) {
            try {
                Write-InfoMessage "Removing old backup: $($backup.Name)"
                Remove-Item -Path $backup.FullName -Recurse -Force -ErrorAction Stop
            } catch {
                Write-WarningMessage "Failed to remove old backup $($backup.Name): $_"
            }
        }
        
        Write-InfoMessage "Removed $($toRemove.Count) old backup(s)"
    } catch {
        Write-WarningMessage "Failed to cleanup old backups: $_"
    }
}

function Get-BackupList {
    Write-DebugMessage "Retrieving backup list"
    
    if (-not (Test-Path -LiteralPath $Script:BackupRoot)) {
        Write-DebugMessage "Backup root directory does not exist"
        return @()
    }

    try {
        $backups = Get-ChildItem -Path $Script:BackupRoot -Directory | 
                   Where-Object { $_.Name -match '^backup_\d{8}_\d{6}$' } |
                   Sort-Object Name -Descending

        $backupList = @()
        foreach ($backup in $backups) {
            $metadataPath = Join-Path -Path $backup.FullName -ChildPath 'backup.json'
            
            if (Test-Path -LiteralPath $metadataPath) {
                try {
                    $json = Get-Content -Path $metadataPath -Raw -ErrorAction Stop
                    $metadata = $json | ConvertFrom-Json -ErrorAction Stop
                    
                    $backupList += [pscustomobject]@{
                        Folder = $backup.FullName
                        Name = $backup.Name
                        Timestamp = $metadata.Timestamp
                        ComputerName = if ($metadata.PSObject.Properties.Name -contains 'ComputerName') { $metadata.ComputerName } else { 'N/A' }
                        TweakCount = if ($metadata.PSObject.Properties.Name -contains 'TweakCount') { $metadata.TweakCount } else { $metadata.RegistryValues.Count }
                        IsValid = $true
                    }
                } catch {
                    Write-DebugMessage "Failed to read backup metadata for $($backup.Name): $_"
                    $backupList += [pscustomobject]@{
                        Folder = $backup.FullName
                        Name = $backup.Name
                        Timestamp = $backup.CreationTime.ToString('o')
                        ComputerName = 'Unknown'
                        TweakCount = 0
                        IsValid = $false
                    }
                }
            } else {
                Write-DebugMessage "Backup metadata not found for $($backup.Name)"
                $backupList += [pscustomobject]@{
                    Folder = $backup.FullName
                    Name = $backup.Name
                    Timestamp = $backup.CreationTime.ToString('o')
                    ComputerName = 'Unknown'
                    TweakCount = 0
                    IsValid = $false
                }
            }
        }
        
        Write-DebugMessage "Found $($backupList.Count) backup(s)"
        return $backupList
    } catch {
        Write-ErrorMessage "Failed to retrieve backup list: $_"
        return @()
    }
}

function Restore-RegistryValues {
    param(
        [Parameter(Mandatory)]
        $BackupData,
        
        [Parameter()]
        [int[]]$SelectiveIndexes = @()
    )

    $itemsToRestore = if ($SelectiveIndexes.Count -gt 0) {
        $BackupData.RegistryValues | Where-Object { 
            $index = [array]::IndexOf($BackupData.RegistryValues, $_)
            $SelectiveIndexes -contains $index
        }
    } else {
        $BackupData.RegistryValues
    }

    $successCount = 0
    $failCount = 0

    foreach ($item in $itemsToRestore) {
        try {
            if ($item.Exists) {
                $typeToUse = if ([string]::IsNullOrEmpty($item.ValueKind)) { 'String' } else { $item.ValueKind }
                $valueToRestore = ConvertTo-RegistryValue -Type $typeToUse -Value $item.Value
                Set-RegistryValue -Hive $item.Hive -Path $item.Path -Name $item.Name -Type $typeToUse -Value $valueToRestore
                Write-SuccessMessage "Restored: $($item.FriendlyName)"
                $successCount++
            } else {
                Remove-RegistryValue -Hive $item.Hive -Path $item.Path -Name $item.Name
                Write-SuccessMessage "Removed: $($item.FriendlyName) (did not exist originally)"
                $successCount++
            }
        } catch {
            Write-ErrorMessage "Failed to restore $($item.FriendlyName): $_"
            $failCount++
        }
    }
    
    Write-InfoMessage "Restore summary: $successCount succeeded, $failCount failed"
    return ($failCount -eq 0)
}
# endregion

# region Actions
function Apply-RegistryTweaks {
    Write-InfoMessage "Applying registry optimizations..."
    
    $successCount = 0
    $failCount = 0
    $failedTweaks = @()
    
    foreach ($tweak in $Script:RegistryTweaks) {
        try {
            Set-RegistryValue -Hive $tweak.Hive -Path $tweak.Path -Name $tweak.Name -Type $tweak.Type -Value $tweak.DesiredValue
            Write-SuccessMessage "Applied: $($tweak.FriendlyName)"
            $successCount++
        } catch {
            Write-ErrorMessage "Failed to apply $($tweak.FriendlyName): $_"
            $failCount++
            $failedTweaks += $tweak.FriendlyName
        }
    }
    
    Write-InfoMessage "Apply summary: $successCount succeeded, $failCount failed"
    
    if ($failCount -gt 0) {
        Write-WarningMessage "Failed tweaks: $($failedTweaks -join ', ')"
    }
    
    return ($failCount -eq 0)
}

function Invoke-Optimization {
    Write-InfoMessage '=== Starting Optimization Process ==='
    
    # Create backup first
    Write-InfoMessage 'Step 1/3: Creating backup before applying tweaks...'
    $backup = Backup-Settings
    
    if ($null -eq $backup) {
        Write-ErrorMessage 'Cannot continue without a valid backup. Aborting optimization.'
        return
    }

    # Apply tweaks
    Write-InfoMessage 'Step 2/3: Applying optimization tweaks...'
    $tweaksSuccess = Apply-RegistryTweaks
    
    # Set power plan
    Write-InfoMessage 'Step 3/3: Configuring power plan...'
    Set-PerformancePowerPlan
    
    # Summary
    Write-Host ''
    if ($tweaksSuccess) {
        Write-SuccessMessage 'Optimization completed successfully!'
        Write-InfoMessage "Backup location: $($backup.Folder)"
        Write-Host ''
        Write-Host 'IMPORTANT: A system restart is recommended for all changes to take effect.' -ForegroundColor Yellow
    } else {
        Write-WarningMessage 'Optimization completed with some errors. Check the log for details.'
        Write-InfoMessage "You can restore previous settings from: $($backup.Folder)"
    }
}

function Invoke-Restore {
    Write-InfoMessage '=== Starting Restore Process ==='
    
    $backupList = Get-BackupList
    
    if ($backupList.Count -eq 0) {
        Write-WarningMessage 'No backups found. Cannot restore.'
        return
    }

    # Display available backups
    Write-Host ''
    Write-Host 'Available backups:' -ForegroundColor Cyan
    Write-Host ''
    
    $displayBackups = @()
    for ($index = 0; $index -lt $backupList.Count; $index++) {
        $backup = $backupList[$index]
        $displayIndex = $index + 1
        
        try {
            $timestamp = [DateTime]::Parse($backup.Timestamp)
            $formattedDate = $timestamp.ToString('yyyy-MM-dd HH:mm:ss')
        } catch {
            $formattedDate = $backup.Timestamp
        }
        
        $status = if ($backup.IsValid) { '✓' } else { '✗' }
        $line = "  {0,2}) {1} {2} | Computer: {3} | Items: {4}" -f $displayIndex, $status, $formattedDate, $backup.ComputerName, $backup.TweakCount
        
        Write-Host $line
        $displayBackups += $backup
    }
    
    Write-Host ''
    Write-Host 'Enter backup number to restore, or Q to cancel:' -ForegroundColor Cyan
    $selection = Read-Host 'Selection'
    
    if ([string]::IsNullOrWhiteSpace($selection) -or $selection.Trim().ToUpperInvariant() -eq 'Q') {
        Write-WarningMessage 'Restore canceled by user.'
        return
    }

    $selectionNumber = $selection.Trim() -as [int]
    if ($null -eq $selectionNumber -or $selectionNumber -lt 1 -or $selectionNumber -gt $displayBackups.Count) {
        Write-WarningMessage 'Invalid selection. Restore canceled.'
        return
    }

    $selectedBackup = $displayBackups[$selectionNumber - 1]
    
    if (-not $selectedBackup.IsValid) {
        Write-ErrorMessage 'Selected backup is corrupted or invalid. Cannot restore.'
        return
    }
    
    # Load backup data
    $metadataPath = Join-Path -Path $selectedBackup.Folder -ChildPath 'backup.json'
    
    try {
        $backupJson = Get-Content -Path $metadataPath -Raw -ErrorAction Stop
        $backupData = $backupJson | ConvertFrom-Json -ErrorAction Stop
    } catch {
        Write-ErrorMessage "Failed to read backup metadata: $_"
        return
    }

    # Confirm restore
    Write-Host ''
    Write-Host "You are about to restore settings from: $($selectedBackup.Name)" -ForegroundColor Yellow
    $confirm = Read-Host 'Continue? (Y/N)'
    
    if ($confirm.Trim().ToUpperInvariant() -ne 'Y') {
        Write-WarningMessage 'Restore canceled by user.'
        return
    }

    # Perform restore
    Write-InfoMessage "Restoring settings from $($selectedBackup.Folder)..."
    
    $restoreSuccess = Restore-RegistryValues -BackupData $backupData
    Restore-PowerPlan -BackupData $backupData
    
    Write-Host ''
    if ($restoreSuccess) {
        Write-SuccessMessage 'Restore completed successfully!'
        Write-Host ''
        Write-Host 'IMPORTANT: A system restart is recommended for all changes to take effect.' -ForegroundColor Yellow
    } else {
        Write-WarningMessage 'Restore completed with some errors. Check the log for details.'
    }
}

function Show-OptimizationStatus {
    Write-InfoMessage 'Checking current optimization status...'
    Write-Host ''
    
    $status = foreach ($tweak in $Script:RegistryTweaks) {
        try {
            $current = Get-RegistryValue -Hive $tweak.Hive -Path $tweak.Path -Name $tweak.Name
            $isMatch = Test-RegistryValueMatch -CurrentValueInfo $current -Type $tweak.Type -DesiredValue $tweak.DesiredValue
            
            [pscustomobject]@{
                Setting = $tweak.FriendlyName
                CurrentValue = if ($current.Exists) { $current.Value } else { 'Not set' }
                DesiredValue = ConvertTo-RegistryValue -Type $tweak.Type -Value $tweak.DesiredValue
                Status = if ($isMatch) { 'Optimized' } else { 'Not optimized' }
            }
        } catch {
            Write-WarningMessage "Failed to check status for $($tweak.FriendlyName): $_"
            [pscustomobject]@{
                Setting = $tweak.FriendlyName
                CurrentValue = 'Error'
                DesiredValue = 'N/A'
                Status = 'Error'
            }
        }
    }

    Write-Host 'Registry Optimization Status:' -ForegroundColor Cyan
    $status | Format-Table -AutoSize

    $plan = Get-ActivePowerPlan
    Write-Host ''
    Write-Host "Active Power Plan: $($plan.Name) (GUID: $($plan.Guid))" -ForegroundColor Cyan
    
    # Summary statistics
    $optimizedCount = ($status | Where-Object { $_.Status -eq 'Optimized' }).Count
    $totalCount = $status.Count
    $percentage = if ($totalCount -gt 0) { [math]::Round(($optimizedCount / $totalCount) * 100, 1) } else { 0 }
    
    Write-Host ''
    Write-Host "Optimization Level: $optimizedCount/$totalCount settings optimized ($percentage%)" -ForegroundColor $(if ($percentage -eq 100) { 'Green' } elseif ($percentage -ge 50) { 'Yellow' } else { 'Red' })
}

function Show-BackupManagement {
    Write-InfoMessage 'Loading backup information...'
    
    $backupList = Get-BackupList
    
    if ($backupList.Count -eq 0) {
        Write-WarningMessage 'No backups found.'
        return
    }
    
    Write-Host ''
    Write-Host "=== Backup Management ($($backupList.Count) backups) ===" -ForegroundColor Cyan
    Write-Host ''
    
    foreach ($backup in $backupList) {
        try {
            $timestamp = [DateTime]::Parse($backup.Timestamp)
            $formattedDate = $timestamp.ToString('yyyy-MM-dd HH:mm:ss')
            $age = (Get-Date) - $timestamp
            $ageStr = if ($age.TotalDays -ge 1) { 
                "$([math]::Floor($age.TotalDays)) day(s) ago" 
            } elseif ($age.TotalHours -ge 1) { 
                "$([math]::Floor($age.TotalHours)) hour(s) ago" 
            } else { 
                "$([math]::Floor($age.TotalMinutes)) minute(s) ago" 
            }
        } catch {
            $formattedDate = $backup.Timestamp
            $ageStr = 'Unknown'
        }
        
        $status = if ($backup.IsValid) { 'Valid' } else { 'Invalid' }
        $statusColor = if ($backup.IsValid) { 'Green' } else { 'Red' }
        
        Write-Host "Name: " -NoNewline
        Write-Host $backup.Name -ForegroundColor White
        Write-Host "  Date: $formattedDate ($ageStr)"
        Write-Host "  Computer: $($backup.ComputerName) | Items: $($backup.TweakCount) | Status: " -NoNewline
        Write-Host $status -ForegroundColor $statusColor
        Write-Host "  Path: $($backup.Folder)" -ForegroundColor Gray
        Write-Host ''
    }
    
    Write-Host "Total backup size: " -NoNewline
    try {
        $totalSize = (Get-ChildItem -Path $Script:BackupRoot -Recurse -File | Measure-Object -Property Length -Sum).Sum
        $sizeKB = [math]::Round($totalSize / 1KB, 2)
        Write-Host "$sizeKB KB" -ForegroundColor Yellow
    } catch {
        Write-Host "Unable to calculate" -ForegroundColor Gray
    }
}
# endregion

# region Menu
function Show-Menu {
    do {
        Write-Host ''
        Write-Host '╔════════════════════════════════════════════╗' -ForegroundColor Cyan
        Write-Host '║   Windows 11 UI Optimizer v2.0            ║' -ForegroundColor Cyan
        Write-Host '╚════════════════════════════════════════════╝' -ForegroundColor Cyan
        Write-Host ''
        Write-Host '1) Apply optimization tweaks'
        Write-Host '2) Restore previous settings'
        Write-Host '3) View current optimization status'
        Write-Host '4) Manage backups'
        Write-Host '5) View logs'
        Write-Host 'Q) Quit'
        Write-Host ''
        
        $choice = Read-Host 'Select an option'
        $normalized = if ($null -eq $choice) { '' } else { $choice.Trim().ToUpperInvariant() }

        switch ($normalized) {
            '1' { 
                Invoke-Optimization 
                Read-Host 'Press Enter to continue'
            }
            '2' { 
                Invoke-Restore 
                Read-Host 'Press Enter to continue'
            }
            '3' { 
                Show-OptimizationStatus 
                Read-Host 'Press Enter to continue'
            }
            '4' { 
                Show-BackupManagement 
                Read-Host 'Press Enter to continue'
            }
            '5' {
                if ($null -ne $Script:LogFile -and (Test-Path -LiteralPath $Script:LogFile)) {
                    Write-Host ''
                    Write-Host "Current log file: $Script:LogFile" -ForegroundColor Cyan
                    Write-Host ''
                    $viewLog = Read-Host 'Open log file in default viewer? (Y/N)'
                    if ($viewLog.Trim().ToUpperInvariant() -eq 'Y') {
                        try {
                            Start-Process -FilePath $Script:LogFile
                        } catch {
                            Write-ErrorMessage "Failed to open log file: $_"
                        }
                    }
                } else {
                    Write-WarningMessage 'No log file available for this session.'
                }
                Read-Host 'Press Enter to continue'
            }
            'Q' { 
                Write-InfoMessage 'Exiting...'
                if ($null -ne $Script:LogFile) {
                    Write-LogMessage -Message "=== Session Ended ===" -Level 'INFO'
                }
                return 
            }
            ''  { 
                Write-WarningMessage 'Please enter a selection.' 
            }
            default { 
                Write-WarningMessage "Unknown option '$choice'." 
            }
        }
    } while ($true)
}
# endregion

# region Main execution
function Start-Optimizer {
    try {
        # Initialize logging
        Initialize-Logging
        
        # Check prerequisites
        Write-DebugMessage "Checking prerequisites..."
        Assert-Administrator
        
        if (-not (Test-Windows11)) {
            Write-ErrorMessage 'This script is designed for Windows 11 (build 22000 or later) only.'
            Write-InfoMessage 'While some optimizations may work on Windows 10, full compatibility is not guaranteed.'
            
            $continue = Read-Host 'Continue anyway? (Y/N)'
            if ($continue.Trim().ToUpperInvariant() -ne 'Y') {
                return
            }
        }

        # Ensure backup directory exists
        if (-not (Test-Path -LiteralPath $Script:BackupRoot)) {
            try {
                New-Item -ItemType Directory -Path $Script:BackupRoot -Force | Out-Null
                Write-DebugMessage "Created backup directory: $Script:BackupRoot"
            } catch {
                Write-ErrorMessage "Unable to create backup directory at $Script:BackupRoot : $_"
                return
            }
        }

        # Display welcome message
        Write-Host ''
        Write-Host '╔════════════════════════════════════════════════════════════╗' -ForegroundColor Green
        Write-Host '║  Windows 11 UI Optimizer v2.0                             ║' -ForegroundColor Green
        Write-Host '║  Enhanced Edition with Advanced Features                  ║' -ForegroundColor Green
        Write-Host '╚════════════════════════════════════════════════════════════╝' -ForegroundColor Green
        Write-Host ''
        Write-Host 'Features:' -ForegroundColor Cyan
        Write-Host '  • Automatic backup before optimization'
        Write-Host '  • Versioned backup system with automatic cleanup'
        Write-Host '  • Comprehensive logging'
        Write-Host '  • Backup integrity verification'
        Write-Host '  • Detailed status reporting'
        Write-Host ''
        Write-Host "Backup directory: $Script:BackupRoot" -ForegroundColor Gray
        
        if ($Script:VerboseMode) {
            Write-Host "Verbose mode: ENABLED" -ForegroundColor Yellow
        }
        
        Write-Host "Max backups to retain: $MaxBackups" -ForegroundColor Gray
        Write-Host ''

        # Show main menu
        Show-Menu
        
    } catch {
        Write-ErrorMessage "Fatal error: $_"
        Write-DebugMessage $_.ScriptStackTrace
        
        if ($null -ne $Script:LogFile) {
            Write-Host ''
            Write-Host "Check log file for details: $Script:LogFile" -ForegroundColor Yellow
        }
    }
}

# Start the optimizer
Start-Optimizer
# endregion