# Configuration management for CianTools module

# Module-level variable to cache config
$script:CianToolsConfig = $null

function Get-CianToolsConfig {
    <#
    .SYNOPSIS
        Gets the current CianTools configuration settings.
    
    .DESCRIPTION
        Returns the merged configuration from defaults and user overrides.
        Configuration is cached for performance.
    
    .EXAMPLE
        Get-CianToolsConfig
        Returns the current configuration hashtable
    
    .EXAMPLE
        (Get-CianToolsConfig).CloudStoragePath
        Gets just the cloud storage path setting
    #>
    [CmdletBinding()]
    param()
    
    if ($null -eq $script:CianToolsConfig) {
        $script:CianToolsConfig = Initialize-CianToolsConfig
    }
    
    return $script:CianToolsConfig
}

function Set-CianToolsConfig {
    <#
    .SYNOPSIS
        Sets CianTools configuration values.
    
    .DESCRIPTION
        Updates user configuration settings. Creates the config file if it doesn't exist.
    
    .PARAMETER CloudStoragePath
        Path to cloud storage sync folder for backups
    
    .PARAMETER GitRepoPath
        Default path for git repositories
    
    .EXAMPLE
        Set-CianToolsConfig -CloudStoragePath "$env:USERPROFILE\iCloudDrive\Synced"
    
    .EXAMPLE
        Set-CianToolsConfig -GitRepoPath "$env:USERPROFILE\Source\Repos"
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$CloudStoragePath,
        
        [Parameter()]
        [string]$GitRepoPath
    )
    
    $configPath = Get-ConfigPath
    $userConfig = @{}
    
    # Load existing user config if it exists
    if (Test-Path $configPath) {
        try {
            $userConfig = Import-PowerShellDataFile -Path $configPath
        }
        catch {
            Write-Warning "Failed to load existing config: $($_.Exception.Message)"
        }
    }
    
    # Update specified values
    if ($PSBoundParameters.ContainsKey('CloudStoragePath')) {
        $userConfig.CloudStoragePath = $CloudStoragePath
    }
    if ($PSBoundParameters.ContainsKey('GitRepoPath')) {
        $userConfig.GitRepoPath = $GitRepoPath
    }
    
    # Save user config
    try {
        $configDir = Split-Path $configPath -Parent
        if (-not (Test-Path $configDir)) {
            New-Item -Path $configDir -ItemType Directory -Force | Out-Null
        }
        
        $configContent = "@{`n"
        foreach ($key in $userConfig.Keys) {
            $value = $userConfig[$key]
            $configContent += "    $key = '$value'`n"
        }
        $configContent += "}"
        
        Set-Content -Path $configPath -Value $configContent -Encoding UTF8
        Write-Host "Configuration saved to: $configPath" -ForegroundColor Green
        
        # Clear cache to force reload
        $script:CianToolsConfig = $null
    }
    catch {
        Write-Error "Failed to save configuration: $($_.Exception.Message)"
    }
}

function Reset-CianToolsConfig {
    <#
    .SYNOPSIS
        Resets CianTools configuration to defaults.
    
    .DESCRIPTION
        Removes the user configuration file, reverting all settings to defaults.
    
    .EXAMPLE
        Reset-CianToolsConfig
        Removes user config file and reverts to defaults
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param()
    
    $configPath = Get-ConfigPath
    
    if (Test-Path $configPath) {
        if ($PSCmdlet.ShouldProcess($configPath, "Delete user configuration")) {
            try {
                Remove-Item -Path $configPath -Force
                Write-Host "User configuration reset to defaults" -ForegroundColor Green
                
                # Clear cache to force reload
                $script:CianToolsConfig = $null
            }
            catch {
                Write-Error "Failed to reset configuration: $($_.Exception.Message)"
            }
        }
    }
    else {
        Write-Host "No user configuration found - already using defaults" -ForegroundColor Yellow
    }
}

function Show-CianToolsConfig {
    <#
    .SYNOPSIS
        Displays the current CianTools configuration in a readable format.
    
    .DESCRIPTION
        Shows all current configuration settings with their values and sources.
    
    .EXAMPLE
        Show-CianToolsConfig
        Displays current configuration settings
    #>
    [CmdletBinding()]
    param()
    
    $config = Get-CianToolsConfig
    $configPath = Get-ConfigPath
    $hasUserConfig = Test-Path $configPath
    
    Write-Host "`nCianTools Configuration:" -ForegroundColor Cyan
    Write-Host "========================" -ForegroundColor Cyan
    Write-Host "Config file: $configPath" -ForegroundColor Gray
    Write-Host "User config exists: $hasUserConfig" -ForegroundColor Gray
    Write-Host ""
    
    foreach ($key in $config.Keys | Sort-Object) {
        $value = $config[$key]
        Write-Host "$key : " -ForegroundColor Yellow -NoNewline
        Write-Host $value -ForegroundColor White
    }
    Write-Host ""
}

# Private helper functions
function Get-ConfigPath {
    return "$env:USERPROFILE\.ciantools\config.psd1"
}

function Get-DefaultConfig {
    return @{
        CloudStoragePath = "$env:USERPROFILE\OneDrive\Synced"
        GitRepoPath = "$env:USERPROFILE\github"
    }
}

function Initialize-CianToolsConfig {
    $defaults = Get-DefaultConfig
    $configPath = Get-ConfigPath
    
    if (Test-Path $configPath) {
        try {
            $userConfig = Import-PowerShellDataFile -Path $configPath
            # Merge user config over defaults
            foreach ($key in $userConfig.Keys) {
                $defaults[$key] = $userConfig[$key]
            }
        }
        catch {
            Write-Warning "Failed to load user config, using defaults: $($_.Exception.Message)"
        }
    }
    
    return $defaults
}

# Aliases
Set-Alias -Name ctconfig -Value Get-CianToolsConfig
Set-Alias -Name ctset -Value Set-CianToolsConfig
Set-Alias -Name ctreset -Value Reset-CianToolsConfig
Set-Alias -Name ctshow -Value Show-CianToolsConfig
