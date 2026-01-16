# Basic Machine Powershell setup - Requires Admin prompt
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
	$arguments = "& '" + $myinvocation.mycommand.definition + "'"
	Start-Process powershell -Verb runAs -ArgumentList $arguments
	Break
}

# Setup Powershell symlinks
$linkPath = "$env:USERPROFILE\Documents\WindowsPowerShell"
$targetPath = $PSScriptRoot

try {
	if (Test-Path $linkPath) {
		Write-Warning "PowerShell profile directory already exists: $linkPath"
	} else {
		New-Item -ItemType SymbolicLink -Path $linkPath -Target $targetPath | Out-Null
		Write-Host "Created PowerShell profile symlink: $linkPath -> $targetPath" -ForegroundColor Green
	}
}
catch {
	Write-Error "Failed to create PowerShell profile symlink: $($_.Exception.Message)"
}

# Setup vimrc
$vimrcLink = "$env:USERPROFILE\_vimrc"
$vimrcTarget = "$((Get-Item $PSScriptRoot).parent.FullName)\.vimrc"

try {
	if (Test-Path $vimrcTarget) {
		if (Test-Path $vimrcLink) {
			Write-Warning "Vimrc link already exists: $vimrcLink"
		} else {
			New-Item -ItemType SymbolicLink -Path $vimrcLink -Target $vimrcTarget | Out-Null
			Write-Host "Created vimrc symlink: $vimrcLink -> $vimrcTarget" -ForegroundColor Green
		}
	} else {
		Write-Warning "Vimrc target not found: $vimrcTarget"
	}
}
catch {
	Write-Error "Failed to create vimrc symlink: $($_.Exception.Message)"
}

# Set privacy settings
# & $PSScriptRoot\privacy_settings.ps1
