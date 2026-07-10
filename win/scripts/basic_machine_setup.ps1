# Basic Machine Powershell setup - Requires Admin prompt
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
	$powerShellPath = (Get-Process -Id $PID).Path
	Start-Process -FilePath $powerShellPath -Verb RunAs -ArgumentList "-File", "`"$PSCommandPath`""
	exit
}

# Helper function to create/update symlinks safely
function Set-SafeSymlink {
	param(
		[string]$LinkPath,
		[string]$TargetPath,
		[string]$Description
	)

	$resolvedTarget = (Resolve-Path $TargetPath -ErrorAction SilentlyContinue).Path
	if (-not $resolvedTarget) {
		Write-Error "$Description target not found: $TargetPath"
		return $false
	}

	if (Test-Path $LinkPath) {
		$item = Get-Item $LinkPath -Force
		
		if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
			# It's a symlink - check if target exists
			$currentTarget = $item.Target
			if ($currentTarget -and (Test-Path $currentTarget)) {
				# Normalize paths for comparison (resolve to full path, remove trailing slashes)
				$normalizedCurrent = (Resolve-Path $currentTarget).Path.TrimEnd('\', '/')
				$normalizedTarget = $resolvedTarget.TrimEnd('\', '/')
				if ($normalizedCurrent -eq $normalizedTarget) {
					Write-Host "  [OK] $Description (already linked correctly)" -ForegroundColor Green
					return $true
				}
				# Target exists but points elsewhere - archive it
				$oldPath = "$LinkPath.old"
				if (Get-Item -LiteralPath $oldPath -Force -ErrorAction SilentlyContinue) {
					throw "Cannot replace $Description because backup already exists: $oldPath"
				}
				Copy-Item -Path $currentTarget -Destination $oldPath -Recurse -Force -ErrorAction Stop
				Write-Host "  -> $Description (archived old target to .old)" -ForegroundColor Yellow
			} else {
				Write-Host "  -> $Description (removing broken symlink)" -ForegroundColor Yellow
			}
			Remove-Item $LinkPath -Force -ErrorAction Stop
		} else {
			# It's a real file/folder - archive it
			$oldPath = "$LinkPath.old"
			if (Get-Item -LiteralPath $oldPath -Force -ErrorAction SilentlyContinue) {
				throw "Cannot replace $Description because backup already exists: $oldPath"
			}
			Move-Item -Path $LinkPath -Destination $oldPath -Force -ErrorAction Stop
			Write-Host "  -> $Description (archived existing to .old)" -ForegroundColor Yellow
		}
	}

	try {
		New-Item -ItemType SymbolicLink -Path $LinkPath -Target $resolvedTarget -ErrorAction Stop | Out-Null
		Write-Host "  [OK] $Description (created)" -ForegroundColor Green
		return $true
	} catch {
		Write-Error "  [ERROR] $Description failed: $($_.Exception.Message)"
		return $false
	}
}

$setupFailures = [System.Collections.Generic.List[string]]::new()

function Invoke-SetupStep {
	param(
		[string]$Description,
		[scriptblock]$Action
	)

	try {
		$result = & $Action
		if ($result -eq $false) {
			$script:setupFailures.Add($Description)
		}
	} catch {
		Write-Error "  [ERROR] $Description failed: $($_.Exception.Message)"
		$script:setupFailures.Add($Description)
	}
}

$repoRoot = (Get-Item $PSScriptRoot).Parent.Parent.FullName

# Setup symlinks
Write-Host "`nChecking symlinks..." -ForegroundColor Cyan
$powershellTarget = Join-Path $PSScriptRoot "..\powershell"

Invoke-SetupStep "WindowsPowerShell profile" {
	Set-SafeSymlink `
		-LinkPath "$env:USERPROFILE\Documents\WindowsPowerShell" `
		-TargetPath $powershellTarget `
		-Description "WindowsPowerShell profile"
}

Invoke-SetupStep "PowerShell profile" {
	Set-SafeSymlink `
		-LinkPath "$env:USERPROFILE\Documents\PowerShell" `
		-TargetPath $powershellTarget `
		-Description "PowerShell profile"
}

# Windows Terminal symlink
$terminalPackage = Get-ChildItem "$env:LOCALAPPDATA\Packages" -Filter "Microsoft.WindowsTerminal_*" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($terminalPackage) {
	$terminalSettingsLink = Join-Path $terminalPackage.FullName "LocalState\settings.json"
	$terminalSettingsTarget = Join-Path $PSScriptRoot "..\terminal\settings.json"
	
	Invoke-SetupStep "Windows Terminal settings" {
		Set-SafeSymlink `
			-LinkPath $terminalSettingsLink `
			-TargetPath $terminalSettingsTarget `
			-Description "Windows Terminal settings"
	}
} else {
	Write-Host "  ! Windows Terminal package not found" -ForegroundColor Yellow
}

# vimrc
Invoke-SetupStep "vimrc" {
	Set-SafeSymlink `
		-LinkPath "$env:USERPROFILE\_vimrc" `
		-TargetPath (Join-Path $repoRoot ".vimrc") `
		-Description "vimrc"
}

# gitconfig
Invoke-SetupStep "gitconfig" {
	Set-SafeSymlink `
		-LinkPath "$env:USERPROFILE\.gitconfig" `
		-TargetPath (Join-Path $repoRoot ".gitconfig") `
		-Description "gitconfig"
}

# Create .gitconfig.local if it doesn't exist
$gitconfigLocal = "$env:USERPROFILE\.gitconfig.local"
if (-not (Test-Path $gitconfigLocal)) {
	Invoke-SetupStep ".gitconfig.local" {
		$gitconfigOld = "$env:USERPROFILE\.gitconfig.old"
		if (Test-Path $gitconfigOld) {
			# Extract machine-specific sections from the backup
			Write-Host "  -> Generating .gitconfig.local from previous .gitconfig" -ForegroundColor Yellow
			"# Machine-specific gitconfig - DO NOT COMMIT" | Set-Content $gitconfigLocal -ErrorAction Stop
			"# Generated from previous .gitconfig during bootstrap setup" | Add-Content $gitconfigLocal -ErrorAction Stop
			"" | Add-Content $gitconfigLocal -ErrorAction Stop
			$userEntries = git --no-pager config --file $gitconfigOld --get-regexp '^user\.' 2>$null
			if ($userEntries) {
				$userEntries | ForEach-Object {
					$parts = $_ -split ' ', 2
					git config --file $gitconfigLocal $parts[0] $parts[1]
					if ($LASTEXITCODE -ne 0) { throw "Failed to migrate user configuration" }
				}
			}
			# Credential helpers use multi-valued keys (empty helper= to reset, then actual helper)
			$credEntries = git --no-pager config --file $gitconfigOld --get-regexp '^credential\.' 2>$null
			if ($credEntries) {
				$credEntries | ForEach-Object {
					$parts = $_ -split ' ', 2
					$value = if ($parts.Length -gt 1) { $parts[1] } else { "" }
					git config --file $gitconfigLocal --add $parts[0] $value
					if ($LASTEXITCODE -ne 0) { throw "Failed to migrate credential configuration" }
				}
			}
			Write-Host "  [OK] .gitconfig.local (migrated from backup)" -ForegroundColor Green
		} else {
			$templatePath = Join-Path $repoRoot ".gitconfig.local.template"
			Copy-Item $templatePath $gitconfigLocal -ErrorAction Stop
			Write-Host "  -> Created .gitconfig.local from template (edit with your details)" -ForegroundColor Yellow
		}
	}
}


# Install posh-git from PowerShell Gallery (for git tab completion)
Write-Host "`nChecking posh-git..." -ForegroundColor Cyan
if (-not (Get-Module -ListAvailable -Name posh-git)) {
	Write-Host "  Installing from PowerShell Gallery..."
	Invoke-SetupStep "posh-git installation" {
		Install-Module posh-git -Scope CurrentUser -Force -ErrorAction Stop
		Write-Host "  [OK] Installed" -ForegroundColor Green
	}
} else {
	Write-Host "  [OK] Already installed" -ForegroundColor Green
}

# ------------------------------
# Copilot CLI setup
# ------------------------------
$devRoot = (Get-Item $repoRoot).Parent.FullName

Write-Host "`nChecking Copilot CLI setup..." -ForegroundColor Cyan

# Create ~/.copilot if needed
$copilotDir = "$env:USERPROFILE\.copilot"
if (-not (Test-Path $copilotDir)) {
	Invoke-SetupStep "Copilot directory" {
		New-Item -ItemType Directory -Path $copilotDir -ErrorAction Stop | Out-Null
		Write-Host "  Created $copilotDir"
	}
}

# Copilot instructions
Invoke-SetupStep "Copilot instructions" {
	Set-SafeSymlink `
		-LinkPath "$copilotDir\copilot-instructions.md" `
		-TargetPath (Join-Path $repoRoot "ai\copilot-instructions.md") `
		-Description "Copilot instructions"
}

# Memory (diary, reflections) - requires docs repo
$docsMemory = Join-Path $devRoot "docs\memory"
if (Test-Path $docsMemory) {
	Invoke-SetupStep "Copilot memory" {
		Set-SafeSymlink `
			-LinkPath "$copilotDir\memory" `
			-TargetPath $docsMemory `
			-Description "Copilot memory"
	}
} else {
	Write-Host "  ! Skipping memory symlink - docs repo not found at $devRoot\docs" -ForegroundColor Yellow
}

if ($setupFailures.Count -gt 0) {
	Write-Host "`nSetup completed with errors:" -ForegroundColor Red
	foreach ($failure in $setupFailures) {
		Write-Host "  - $failure" -ForegroundColor Red
	}
	exit 1
}

Write-Host "`nSetup complete!" -ForegroundColor Green
Write-Host "Restart PowerShell or run: . `$PROFILE" -ForegroundColor Cyan
