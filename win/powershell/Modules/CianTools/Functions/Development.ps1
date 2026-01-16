#
# Development Functions
# Functions for development and coding tasks
#

function Edit-Profile {
	<#
	.SYNOPSIS
		Opens the PowerShell profile for editing.
	
	.DESCRIPTION
		Opens the current user's PowerShell profile in the default editor.
		If no profile exists, it will be created.
	
	.EXAMPLE
		Edit-Profile
		Opens the profile in your default editor
	
	.EXAMPLE
		pro
		Same as above using the alias
	
	.NOTES
		Available via alias: pro
	#>
	[CmdletBinding()]
	param()
	
	try {
		if (-not (Test-Path $PROFILE)) {
			Write-Host "Profile doesn't exist, creating: $PROFILE" -ForegroundColor Yellow
			New-Item -Path $PROFILE -ItemType File -Force | Out-Null
		}
		
		if (Get-Command code -ErrorAction SilentlyContinue) {
			& code $PROFILE
		} elseif (Get-Command edit -ErrorAction SilentlyContinue) {
			& edit $PROFILE  
		} else {
			& notepad $PROFILE
		}
	}
	catch {
		Write-Error "Failed to open profile: $($_.Exception.Message)"
	}
}

function Get-CommandPath {
	<#
	.SYNOPSIS
		Gets the full path to a command (equivalent to Unix 'which').
	
	.DESCRIPTION
		Returns the full path to the specified command, similar to the Unix 'which' command.
		Useful for finding where executables are located.
	
	.PARAMETER Command
		The command name to locate.
	
	.EXAMPLE
		Get-CommandPath git
		Returns the full path to git.exe
	
	.EXAMPLE
		which powershell
		Returns the path to PowerShell using alias
	
	.NOTES
		Available via alias: which
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory, Position = 0)]
		[string]$Command
	)
	
	try {
		$cmd = Get-Command $Command -ErrorAction Stop
		return $cmd.Source
	}
	catch {
		Write-Error "Command '$Command' not found"
		return $null
	}
}

function Find-CommandAlias {
	<#
	.SYNOPSIS
		Finds aliases that match a given pattern.
	
	.DESCRIPTION
		Searches through all available aliases to find ones whose definition matches the specified pattern.
		Useful for discovering what aliases are available for a command.
	
	.PARAMETER Pattern
		The pattern to search for in alias definitions.
	
	.EXAMPLE
		Find-CommandAlias "Get-ChildItem"
		Finds all aliases that resolve to Get-ChildItem (like 'ls', 'dir', 'gci')
	
	.EXAMPLE
		gas "location"
		Finds aliases containing "location" using the shorter alias
	
	.NOTES
		Available via alias: gas (Get-Alias-Search)
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory, Position = 0)]
		[string]$Pattern
	)
	
	try {
		Get-Alias | Where-Object { $_.Definition -match $Pattern } | 
			Format-Table Name, Definition -AutoSize
	}
	catch {
		Write-Error "Error searching aliases: $($_.Exception.Message)"
	}
}

function Import-Profile {
	<#
	.SYNOPSIS
		Reloads all PowerShell profiles.
	
	.DESCRIPTION
		Reloads all available PowerShell profiles for the current user and all users.
		Useful for testing profile changes without restarting PowerShell.
	
	.EXAMPLE
		Import-Profile
		Reloads all profiles
	
	.EXAMPLE
		reload
		Same as above using the alias
	
	.NOTES
		Available via alias: reload
	#>
	[CmdletBinding()]
	param()
	
	$profiles = @(
		$Profile.AllUsersAllHosts,
		$Profile.AllUsersCurrentHost,
		$Profile.CurrentUserAllHosts,
		$Profile.CurrentUserCurrentHost
	)
	
	foreach ($profilePath in $profiles) {
		if (Test-Path $profilePath) {
			try {
				Write-Host "Loading profile: $profilePath" -ForegroundColor Green
				. $profilePath
			}
			catch {
				Write-Warning "Failed to load profile '$profilePath': $($_.Exception.Message)"
			}
		}
	}
	
	Write-Host "Profile reload completed" -ForegroundColor Cyan
}

function Push-Project {
	<#
	.SYNOPSIS
		Navigates to a project directory with intelligent search.
	
	.DESCRIPTION
		Searches for and navigates to a project directory. Searches in GitHub directory first,
		then performs fuzzy matching if exact match not found. Uses push-location so you can
		return with 'popd'.
	
	.PARAMETER ProjectName
		The name or partial name of the project to navigate to.
	
	.PARAMETER BasePath
		The base directory to search in. If not specified, uses the configured GitRepoPath.
	
	.EXAMPLE
		Push-Project "MyProject"
		Navigates to MyProject directory
	
	.EXAMPLE
		pp "bootstrap"
		Navigate to bootstrap project using alias
	
	.EXAMPLE
		Push-Project "web" -BasePath "C:\Dev"
		Search for web project in C:\Dev
	
	.NOTES
		Available via alias: pp
		Uses Push-Location so you can return with 'popd'.
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory, Position = 0)]
		[string]$ProjectName,
		
		[Parameter(Position = 1)]
		[string]$BasePath
	)
	
	# Use configured path if not specified
	if (-not $BasePath) {
		$config = Get-CianToolsConfig
		$BasePath = $config.GitRepoPath
	}
	
	if (-not (Test-Path $BasePath)) {
		Write-Error "Base path does not exist: $BasePath"
		return
	}
	
	# Try exact match first
	$exactPath = Join-Path $BasePath $ProjectName
	if (Test-Path $exactPath) {
		Push-Location $exactPath
		Write-Host "Navigated to: $exactPath" -ForegroundColor Green
		return
	}
	
	# Try fuzzy match in base directory
	$fuzzyMatch = Get-ChildItem $BasePath -Directory -Filter "*$ProjectName*" | Select-Object -First 1
	if ($fuzzyMatch) {
		Push-Location $fuzzyMatch.FullName
		Write-Host "Navigated to: $($fuzzyMatch.FullName)" -ForegroundColor Green
		return
	}
	
	# Try fuzzy match in subdirectories (one level deep)
	$deepMatch = Get-ChildItem $BasePath -Directory | 
		ForEach-Object { Get-ChildItem $_.FullName -Directory -Filter "*$ProjectName*" -ErrorAction SilentlyContinue } | 
		Select-Object -First 1
		
	if ($deepMatch) {
		Push-Location $deepMatch.FullName
		Write-Host "Navigated to: $($deepMatch.FullName)" -ForegroundColor Green
		return
	}
	
	# If nothing found, show available projects
	Write-Warning "Project '$ProjectName' not found."
	Write-Host "Available projects:" -ForegroundColor Yellow
	Get-ChildItem $BasePath -Directory | ForEach-Object {
		Write-Host "  $($_.Name)" -ForegroundColor Gray
	}
}

# Create aliases for backward compatibility
Set-Alias -Name pro -Value Edit-Profile
Set-Alias -Name which -Value Get-CommandPath
Set-Alias -Name gas -Value Find-CommandAlias
Set-Alias -Name reload -Value Import-Profile
Set-Alias -Name pp -Value Push-Project
