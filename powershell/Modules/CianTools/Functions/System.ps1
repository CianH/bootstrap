#
# System Functions  
# Functions for system administration and management
#

function Edit-HostsFile {
	<#
	.SYNOPSIS
		Opens the Windows hosts file for editing with elevated privileges.
	
	.DESCRIPTION
		Opens the Windows hosts file (C:\Windows\System32\drivers\etc\hosts) in an elevated editor.
		This is required because the hosts file requires administrator privileges to modify.
	
	.EXAMPLE
		Edit-HostsFile
		Opens the hosts file in an elevated editor
	
	.EXAMPLE
		hosts
		Same as above using the alias
	
	.NOTES
		Available via alias: hosts
		Requires elevation to modify the hosts file.
	#>
	[CmdletBinding()]
	param()
	
	$hostsPath = "$env:WINDIR\System32\drivers\etc\hosts"
	
	try {
		if (Get-Command code -ErrorAction SilentlyContinue) {
			Start-Process code -ArgumentList $hostsPath -Verb RunAs
		} elseif (Get-Command edit -ErrorAction SilentlyContinue) {
			Start-Process edit -ArgumentList $hostsPath -Verb RunAs
		} else {
			Start-Process notepad -ArgumentList $hostsPath -Verb RunAs
		}
	}
	catch {
		Write-Error "Failed to open hosts file: $($_.Exception.Message)"
	}
}

function New-SymbolicLink {
	<#
	.SYNOPSIS
		Creates a symbolic link using native PowerShell.
	
	.DESCRIPTION
		Creates a symbolic link to a file using PowerShell's New-Item cmdlet.
		Works with both files and directories automatically.
	
	.PARAMETER Target
		The target file or directory to link to.
	
	.PARAMETER Link
		The path where the symbolic link will be created.
	
	.EXAMPLE
		New-SymbolicLink "C:\Source\file.txt" "C:\Link\file.txt"
		Creates a symbolic link to the file
	
	.EXAMPLE
		mklink "target.txt" "link.txt"
		Creates a symbolic link using the alias
	
	.NOTES
		Available via alias: mklink
		May require elevation depending on system configuration.
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory, Position = 0)]
		[string]$Link,
		
		[Parameter(Mandatory, Position = 1)]
		[string]$Target
	)
	
	try {
		# Validate target exists
		if (-not (Test-Path $Target)) {
			Write-Error "Target does not exist: $Target"
			return
		}
		
		# Check if link already exists
		if (Test-Path $Link) {
			Write-Warning "Link already exists: $Link"
			return
		}
		
		# Create the symbolic link
		New-Item -ItemType SymbolicLink -Path $Link -Target $Target | Out-Null
		Write-Host "Created symbolic link: $Link -> $Target" -ForegroundColor Green
	}
	catch {
		Write-Error "Failed to create symbolic link: $($_.Exception.Message)"
	}
}

function New-DirectoryLink {
	<#
	.SYNOPSIS
		Creates a directory symbolic link using native PowerShell.
	
	.DESCRIPTION
		Creates a symbolic link to a directory using PowerShell's New-Item cmdlet.
		This function is now identical to New-SymbolicLink since PowerShell handles both files and directories.
	
	.PARAMETER Target
		The target directory to link to.
	
	.PARAMETER Link
		The path where the directory symbolic link will be created.
	
	.EXAMPLE
		New-DirectoryLink "C:\Source\Directory" "C:\Link\Directory"
		Creates a directory symbolic link
	
	.EXAMPLE
		mkdlink "target-dir" "link-dir"
		Creates a directory symbolic link using the alias
	
	.NOTES
		Available via alias: mkdlink
		May require elevation depending on system configuration.
		This function now uses the same implementation as New-SymbolicLink.
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory, Position = 0)]
		[string]$Link,
		
		[Parameter(Mandatory, Position = 1)]
		[string]$Target
	)
	
	try {
		# Validate target exists and is a directory
		if (-not (Test-Path $Target)) {
			Write-Error "Target directory does not exist: $Target"
			return
		}
		
		if (-not (Get-Item $Target).PSIsContainer) {
			Write-Error "Target is not a directory: $Target"
			return
		}
		
		# Check if link already exists
		if (Test-Path $Link) {
			Write-Warning "Link already exists: $Link"
			return
		}
		
		# Create the symbolic link
		New-Item -ItemType SymbolicLink -Path $Link -Target $Target | Out-Null
		Write-Host "Created directory symbolic link: $Link -> $Target" -ForegroundColor Green
	}
	catch {
		Write-Error "Failed to create directory link: $($_.Exception.Message)"
	}
}

function Backup-HostsFile {
	<#
	.SYNOPSIS
		Backs up the Windows hosts file to OneDrive sync folder.
	
	.DESCRIPTION
		Copies the current Windows hosts file to the OneDrive Synced folder for backup.
		Useful for keeping a synchronized backup of hosts file modifications.
	
	.PARAMETER BackupPath
		Custom backup location. If not specified, uses the configured CloudStoragePath.
	
	.EXAMPLE
		Backup-HostsFile
		Backs up hosts file to configured cloud storage location
	
	.EXAMPLE
		hostsb
		Same as above using the alias
	
	.NOTES
		Available via alias: hostsb
		Uses CloudStoragePath from CianTools configuration.
	#>
	[CmdletBinding()]
	param(
		[Parameter(Position = 0)]
		[string]$BackupPath
	)
	
	# Use configured path if not specified
	if (-not $BackupPath) {
		$config = Get-CianToolsConfig
		$BackupPath = $config.CloudStoragePath
	}
	
	$hostsPath = "$env:WINDIR\System32\drivers\etc\hosts"
	
	try {
		if (-not (Test-Path $BackupPath)) {
			Write-Warning "Backup path does not exist: $BackupPath"
			return
		}
		
		$backupFile = Join-Path $BackupPath "hosts"
		Copy-Item -Path $hostsPath -Destination $backupFile -Force
		Write-Host "Hosts file backed up to: $backupFile" -ForegroundColor Green
	}
	catch {
		Write-Error "Failed to backup hosts file: $($_.Exception.Message)"
	}
}

function Restore-HostsFile {
	<#
	.SYNOPSIS
		Restores the Windows hosts file from OneDrive sync folder.
	
	.DESCRIPTION
		Copies the backed up hosts file from OneDrive Synced folder back to the Windows hosts location.
		This operation requires administrator privileges.
	
	.PARAMETER BackupPath
		Custom backup location. If not specified, uses the configured CloudStoragePath.
	
	.EXAMPLE
		Restore-HostsFile
		Restores hosts file from configured cloud storage location
	
	.EXAMPLE
		hostsr
		Same as above using the alias
	
	.NOTES
		Available via alias: hostsr
		Requires administrator privileges. Consider wrapping with Invoke-Elevated (sudo).
	#>
	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Position = 0)]
		[string]$BackupPath
	)
	
	# Use configured path if not specified
	if (-not $BackupPath) {
		$config = Get-CianToolsConfig
		$BackupPath = $config.CloudStoragePath
	}
	
	$hostsPath = "$env:WINDIR\System32\drivers\etc\hosts"
	$backupFile = Join-Path $BackupPath "hosts"
	
	if (-not (Test-Path $backupFile)) {
		Write-Error "Backup hosts file not found: $backupFile"
		return
	}
	
	if ($PSCmdlet.ShouldProcess($hostsPath, "Restore hosts file from backup")) {
		try {
			Copy-Item -Path $backupFile -Destination $hostsPath -Force
			Write-Host "Hosts file restored from: $backupFile" -ForegroundColor Green
		}
		catch {
			Write-Error "Failed to restore hosts file: $($_.Exception.Message)"
			Write-Host "Note: This operation requires administrator privileges. Try: sudo { Restore-HostsFile }" -ForegroundColor Yellow
		}
	}
}

function Block-Host {
	<#
	.SYNOPSIS
		Blocks a hostname by adding it to the Windows hosts file.
	
	.DESCRIPTION
		Adds an entry to the Windows hosts file to redirect the specified hostname to 0.0.0.0,
		effectively blocking access to that host. Requires administrator privileges.
	
	.PARAMETER Hostname
		The hostname or domain to block.
	
	.PARAMETER IPAddress
		The IP address to redirect to. Defaults to 0.0.0.0 (block completely).
	
	.EXAMPLE
		Block-Host "malicious-site.com"
		Blocks access to malicious-site.com
	
	.EXAMPLE
		block "ads.example.com"
		Blocks ads.example.com using the alias
	
	.NOTES
		Available via alias: block
		Requires administrator privileges to modify the hosts file.
	#>
	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory, Position = 0)]
		[string]$Hostname,
		
		[Parameter(Position = 1)]
		[string]$IPAddress = "0.0.0.0"
	)
	
	$hostsPath = "$env:WINDIR\System32\drivers\etc\hosts"
	
	try {
		# Check if hostname is already blocked
		if ((Select-String -Pattern $Hostname -Path $hostsPath -ErrorAction SilentlyContinue).Count -eq 0) {
			if ($PSCmdlet.ShouldProcess($Hostname, "Block hostname in hosts file")) {
				Add-Content -Path $hostsPath -Value "`r`n$IPAddress $Hostname" -NoNewline
				Write-Host "Blocked $Hostname" -ForegroundColor Green
			}
		} else {
			Write-Host "$Hostname already present in hosts file" -ForegroundColor Yellow
		}
	}
	catch {
		Write-Error "Failed to block host '$Hostname': $($_.Exception.Message)"
		Write-Host "Note: This operation requires administrator privileges. Try: sudo { Block-Host '$Hostname' }" -ForegroundColor Yellow
	}
}

function Stop-RazerServices {
	<#
	.SYNOPSIS
		Stops Razer services in the correct order.
	
	.DESCRIPTION
		Stops Razer-related services that tend to be interdependent and must be stopped
		in a particular order. Automatically elevates if not running as administrator.
	
	.PARAMETER Force
		Forces service termination without confirmation.
	
	.EXAMPLE
		Stop-RazerServices
		Stops all Razer services
	
	.EXAMPLE
		Stop-RazerServices -Force
		Stops services without confirmation prompts
	
	.NOTES
		Requires administrator privileges and will auto-elevate if needed.
	#>
	[CmdletBinding(SupportsShouldProcess)]
	param(
		[switch]$Force
	)
	
	# Check if running as administrator
	if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
		Write-Warning "Administrator privileges required. Attempting to elevate..."
		try {
			$arguments = "& { Import-Module '$($MyInvocation.MyCommand.Module.ModuleBase)\$($MyInvocation.MyCommand.Module.Name).psd1'; Stop-RazerServices }"
			Start-Process powershell -Verb RunAs -ArgumentList "-Command", $arguments
			return
		}
		catch {
			Write-Error "Failed to elevate: $($_.Exception.Message)"
			return
		}
	}
	
	function Test-ServiceRunning([string]$ServiceName) {
		try {
			return (Get-Service $ServiceName -ErrorAction Stop | Select-Object -ExpandProperty Status) -eq "Running"
		}
		catch {
			return $false
		}
	}
	
	function Stop-ServiceAndWait(
		[Parameter(Mandatory)]
		[string]$ServiceName,
		[int]$SleepTime = 0
	) {
		if (Test-ServiceRunning $ServiceName) {
			if ($Force -or $PSCmdlet.ShouldProcess($ServiceName, "Stop service")) {
				Write-Host "$ServiceName is running, stopping..." -ForegroundColor Yellow
				try {
					Stop-Service $ServiceName -Force:$Force
					if ($SleepTime -gt 0) {
						Write-Host "Waiting for $SleepTime seconds..." -ForegroundColor Gray
						Start-Sleep $SleepTime
					}
					Write-Host "$ServiceName stopped successfully" -ForegroundColor Green
				}
				catch {
					Write-Error "Failed to stop $ServiceName`: $($_.Exception.Message)"
				}
			}
		} else {
			Write-Host "$ServiceName is already stopped" -ForegroundColor Gray
		}
	}
	
	# Razer services in dependency order
	$razerServices = @(
		@{ Name = "Razer Game Manager Service"; Sleep = 2 },
		@{ Name = "Razer Central Service"; Sleep = 2 },
		@{ Name = "Razer Synapse Service"; Sleep = 1 },
		@{ Name = "RzSurroundVADStreamingService"; Sleep = 0 }
	)
	
	Write-Host "Stopping Razer services..." -ForegroundColor Cyan
	foreach ($service in $razerServices) {
		Stop-ServiceAndWait -ServiceName $service.Name -SleepTime $service.Sleep
	}
	Write-Host "Razer service shutdown complete" -ForegroundColor Green
}

# Load the Invoke-Elevated function from the existing sudo.ps1 script
# Read the existing sudo script and include it here
$sudoScriptPath = Join-Path (Split-Path (Split-Path $PSScriptRoot)) "scripts\sudo.ps1"
if (Test-Path $sudoScriptPath) {
	. $sudoScriptPath
	# Create alias for the function if it's named differently in the script
	if (Get-Command Invoke-Elevated -ErrorAction SilentlyContinue) {
		Set-Alias -Name sudo -Value Invoke-Elevated
	}
}

# Create aliases for backward compatibility  
Set-Alias -Name hosts -Value Edit-HostsFile
Set-Alias -Name mklink -Value New-SymbolicLink
Set-Alias -Name mkdlink -Value New-DirectoryLink
Set-Alias -Name hostsb -Value Backup-HostsFile
Set-Alias -Name hostsr -Value Restore-HostsFile
# Update aliases section
Set-Alias -Name block -Value Block-Host
