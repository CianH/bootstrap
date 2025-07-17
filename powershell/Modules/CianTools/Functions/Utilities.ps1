#
# Utilities Functions
# General utility functions for various tasks
#

function ConvertTo-Binary {
    <#
    .SYNOPSIS
        Converts a number to its binary representation.
    
    .DESCRIPTION
        Converts an integer to its binary (base-2) string representation.
        Accepts input from pipeline.
    
    .PARAMETER Number
        The number to convert to binary.
    
    .EXAMPLE
        ConvertTo-Binary 42
        Returns: 101010
    
    .EXAMPLE
        255 | ConvertTo-Binary
        Returns: 11111111
    
    .EXAMPLE
        1..5 | ConvertTo-Binary
        Converts numbers 1 through 5 to binary
    
    .NOTES
        Supports pipeline input for batch conversions.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [int]$Number
    )
    
    process {
        try {
            [Convert]::ToString($Number, 2)
        }
        catch {
            Write-Error "Failed to convert '$Number' to binary: $($_.Exception.Message)"
        }
    }
}

function ConvertTo-Hex {
    <#
    .SYNOPSIS
        Converts a number to its hexadecimal representation.
    
    .DESCRIPTION
        Converts an integer to its hexadecimal (base-16) string representation.
        Accepts input from pipeline.
    
    .PARAMETER Number
        The number to convert to hexadecimal.
    
    .PARAMETER UpperCase
        Return hexadecimal in uppercase. Default is lowercase.
    
    .EXAMPLE
        ConvertTo-Hex 255
        Returns: ff
    
    .EXAMPLE
        ConvertTo-Hex 255 -UpperCase
        Returns: FF
    
    .EXAMPLE
        16..31 | ConvertTo-Hex
        Converts numbers 16 through 31 to hex
    
    .NOTES
        Supports pipeline input for batch conversions.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [int]$Number,
        
        [switch]$UpperCase
    )
    
    process {
        try {
            $hex = [Convert]::ToString($Number, 16)
            if ($UpperCase) {
                $hex.ToUpper()
            } else {
                $hex
            }
        }
        catch {
            Write-Error "Failed to convert '$Number' to hexadecimal: $($_.Exception.Message)"
        }
    }
}

function Get-CianTools {
    <#
    .SYNOPSIS
        Lists all available functions in the CianTools module.
    
    .DESCRIPTION
        Displays all custom functions organized by category, with descriptions.
        Use -Detailed for full help information or -Category to filter by specific category.
    
    .PARAMETER Category
        Filter by specific category (Development, FileSystem, System, Utilities)
    
    .PARAMETER Detailed
        Show detailed help for each function
    
    .PARAMETER ListAliases
        Show available aliases for each function
    
    .EXAMPLE
        Get-CianTools
        Shows all available functions grouped by category
    
    .EXAMPLE
        Get-CianTools -Category FileSystem
        Shows only filesystem-related functions
    
    .EXAMPLE
        mytools -Detailed
        Shows detailed help for all functions using alias
    
    .NOTES
        Available via alias: mytools
        This is your main discovery function for all available tools.
    #>
    [CmdletBinding()]
    param(
        [ValidateSet('Development', 'FileSystem', 'System', 'Media', 'Utilities')]
        [string]$Category,
        
        [switch]$Detailed,
        
        [switch]$ListAliases
    )
    
    $functions = @{
        'FileSystem' = @(
            @{ Name = 'New-TouchFile'; Alias = 'touch'; Description = 'Create/update file timestamps (Unix touch)' },
            @{ Name = 'Get-DirectorySizes'; Alias = ''; Description = 'Show directory sizes in current location' },
            @{ Name = 'Compress-DirectoriesToArchive'; Alias = 'zipall'; Description = 'Compress directories to 7z archives' },
            @{ Name = 'Convert-DirectoriesToCBZ'; Alias = 'dirs2cbz'; Description = 'Convert directories to CBZ format' },
            @{ Name = 'Find-Files'; Alias = 'find'; Description = 'Recursively search for files' },
            @{ Name = 'Invoke-ForEachDirectory'; Alias = 'fed'; Description = 'Execute command in each subdirectory' },
            @{ Name = 'Get-FileCrc32'; Alias = 'crc32'; Description = 'Calculate CRC32 checksum of files' }
        )
        'Development' = @(
            @{ Name = 'Edit-Profile'; Alias = 'pro'; Description = 'Open PowerShell profile for editing' },
            @{ Name = 'Get-CommandPath'; Alias = 'which'; Description = 'Get full path to command (Unix which)' },
            @{ Name = 'Find-CommandAlias'; Alias = 'gas'; Description = 'Find aliases matching pattern' },
            @{ Name = 'Import-Profile'; Alias = 'reload'; Description = 'Reload PowerShell profiles' },
            @{ Name = 'Push-Project'; Alias = 'pp'; Description = 'Navigate to project with smart search' }
        )
        'System' = @(
            @{ Name = 'Edit-HostsFile'; Alias = 'hosts'; Description = 'Edit Windows hosts file (elevated)' },
            @{ Name = 'New-SymbolicLink'; Alias = 'mklink'; Description = 'Create file symbolic links' },
            @{ Name = 'New-DirectoryLink'; Alias = 'mkdlink'; Description = 'Create directory symbolic links' },
            @{ Name = 'Backup-HostsFile'; Alias = 'hostsb'; Description = 'Backup hosts file to OneDrive' },
            @{ Name = 'Restore-HostsFile'; Alias = 'hostsr'; Description = 'Restore hosts file from backup' },
            @{ Name = 'Invoke-Elevated'; Alias = 'sudo'; Description = 'Run commands with elevation' },
            @{ Name = 'Block-Host'; Alias = 'block'; Description = 'Block hostnames via hosts file' },
            @{ Name = 'Stop-RazerServices'; Alias = ''; Description = 'Stop Razer services in correct order' }
        )
        'Media' = @(
            @{ Name = 'Remove-MkvTitle'; Alias = ''; Description = 'Remove title metadata from MKV files' },
            @{ Name = 'Remove-MkvTitlesInDirectory'; Alias = ''; Description = 'Remove titles from all MKVs in directory' },
            @{ Name = 'Remove-MkvSubtitles'; Alias = ''; Description = 'Remove subtitle tracks from MKV files' }
        )
        'Utilities' = @(
            @{ Name = 'ConvertTo-Binary'; Alias = ''; Description = 'Convert numbers to binary' },
            @{ Name = 'ConvertTo-Hex'; Alias = ''; Description = 'Convert numbers to hexadecimal' },
            @{ Name = 'Get-CianTools'; Alias = 'mytools'; Description = 'Show this help (meta!)' }
        )
        'Configuration' = @(
            @{ Name = 'Get-CianToolsConfig'; Alias = 'ctconfig'; Description = 'Get current configuration settings' },
            @{ Name = 'Set-CianToolsConfig'; Alias = 'ctset'; Description = 'Set configuration values' },
            @{ Name = 'Reset-CianToolsConfig'; Alias = 'ctreset'; Description = 'Reset configuration to defaults' },
            @{ Name = 'Show-CianToolsConfig'; Alias = 'ctshow'; Description = 'Display configuration in readable format' }
        )
    }
    
    if ($Category) {
        $functions = @{ $Category = $functions[$Category] }
    }
    
    foreach ($cat in $functions.Keys | Sort-Object) {
        Write-Host "`n=== $cat Functions ===" -ForegroundColor Cyan
        
        foreach ($func in $functions[$cat]) {
            if ($Detailed) {
                try {
                    Get-Help $func.Name -Detailed -ErrorAction SilentlyContinue
                }
                catch {
                    Write-Host "  $($func.Name) - Help not available" -ForegroundColor Red
                }
            } else {
                $displayName = $func.Name
                if ($func.Alias -and $ListAliases) {
                    $displayName += " ($($func.Alias))"
                } elseif ($func.Alias) {
                    $displayName = "$($func.Alias) [$($func.Name)]"
                }
                
                Write-Host "  $displayName" -ForegroundColor Green -NoNewline
                if ($func.Description) {
                    Write-Host " - $($func.Description)" -ForegroundColor Gray
                } else {
                    Write-Host ""
                }
            }
        }
    }
    
    if (-not $Detailed) {
        Write-Host "`n" -NoNewline
        Write-Host "Tips:" -ForegroundColor Yellow
        Write-Host "  • Use 'Get-CianTools -Detailed' for full help" -ForegroundColor Gray
        Write-Host "  • Use 'Get-Help <function-name>' for specific function help" -ForegroundColor Gray
        Write-Host "  • Use 'Get-CianTools -Category <name>' to filter by category" -ForegroundColor Gray
        Write-Host "  • Most functions have short aliases shown in brackets" -ForegroundColor Gray
    }
}

# Create alias for the discovery function
Set-Alias -Name mytools -Value Get-CianTools
