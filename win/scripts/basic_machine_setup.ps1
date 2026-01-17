# Basic Machine Powershell setup - Requires Admin prompt
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
	$arguments = "& '" + $myinvocation.mycommand.definition + "'"
	Start-Process powershell -Verb runAs -ArgumentList $arguments
	Break
}

# Setup Powershell symlinks
$linkPath = "$env:USERPROFILE\Documents\WindowsPowerShell"
$targetPath = Join-Path $PSScriptRoot "..\powershell"

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
$repoRoot = (Get-Item $PSScriptRoot).Parent.Parent.FullName
$vimrcTarget = Join-Path $repoRoot ".vimrc"

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

# Install posh-git from PowerShell Gallery (for git tab completion)
if (-not (Get-Module -ListAvailable -Name posh-git)) {
	Write-Host "Installing posh-git from PowerShell Gallery..." -ForegroundColor Cyan
	Install-Module posh-git -Scope CurrentUser -Force
	Write-Host "posh-git installed successfully" -ForegroundColor Green
} else {
	Write-Host "posh-git already installed" -ForegroundColor Green
}
