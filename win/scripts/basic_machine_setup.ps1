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

function Ensure-RealDirectory {
	param(
		[string]$Path,
		[string]$Description
	)

	$item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
	if ($item) {
		if (-not $item.PSIsContainer -or ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
			throw "$Description must be a real directory: $Path"
		}
		return
	}

	New-Item -ItemType Directory -Path $Path -ErrorAction Stop | Out-Null
	Write-Host "  Created $Description" -ForegroundColor Green
}

function Test-RealDirectory {
	param([string]$Path)

	$item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
	return $item -and $item.PSIsContainer -and -not ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)
}

function Install-PoshGitForPowerShell7 {
	$pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
	if (-not $pwsh) {
		throw "PowerShell 7 is not installed or is not available in PATH"
	}

	$installCommand = "if (-not (Get-Module -ListAvailable -Name posh-git)) { Install-Module posh-git -Scope CurrentUser -Force -ErrorAction Stop }"
	& $pwsh.Source -NoProfile -NonInteractive -Command $installCommand
	if ($LASTEXITCODE -ne 0) {
		throw "PowerShell 7 failed to install posh-git"
	}

	Write-Host "  [OK] Available to PowerShell 7" -ForegroundColor Green
}

$repoRoot = (Get-Item $PSScriptRoot).Parent.Parent.FullName

# Setup symlinks
Write-Host "`nChecking symlinks..." -ForegroundColor Cyan
$powershellTarget = Join-Path $PSScriptRoot "..\powershell"
$profileTarget = Join-Path $powershellTarget "Microsoft.PowerShell_profile.ps1"
$cianToolsTarget = Join-Path $powershellTarget "Modules\CianTools"
$documentsPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)

if (-not $documentsPath) {
	Write-Error "  [ERROR] Could not resolve the Windows Documents folder"
	$setupFailures.Add("Resolve Windows Documents folder")
} else {
	$windowsPowerShellDirectory = Join-Path $documentsPath "WindowsPowerShell"
	$powerShellDirectory = Join-Path $documentsPath "PowerShell"
	$profileDirectories = @(
		@{ Name = "WindowsPowerShell"; Path = $windowsPowerShellDirectory },
		@{ Name = "PowerShell"; Path = $powerShellDirectory }
	)

	foreach ($profileDirectory in $profileDirectories) {
		Invoke-SetupStep "$($profileDirectory.Name) directory" {
			Ensure-RealDirectory -Path $profileDirectory.Path -Description "$($profileDirectory.Name) profile directory"
		}

		if (Test-RealDirectory $profileDirectory.Path) {
			$modulesDirectory = Join-Path $profileDirectory.Path "Modules"
			Invoke-SetupStep "$($profileDirectory.Name) modules directory" {
				Ensure-RealDirectory -Path $modulesDirectory -Description "$($profileDirectory.Name) modules directory"
			}

			Invoke-SetupStep "$($profileDirectory.Name) profile" {
				Set-SafeSymlink `
					-LinkPath (Join-Path $profileDirectory.Path "Microsoft.PowerShell_profile.ps1") `
					-TargetPath $profileTarget `
					-Description "$($profileDirectory.Name) profile"
			}

			if (Test-RealDirectory $modulesDirectory) {
				Invoke-SetupStep "$($profileDirectory.Name) CianTools module" {
					Set-SafeSymlink `
						-LinkPath (Join-Path $modulesDirectory "CianTools") `
						-TargetPath $cianToolsTarget `
						-Description "$($profileDirectory.Name) CianTools module"
				}
			}
		}
	}
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

# Configure global git hooks using the checkout's resolved path
$hooksPath = Join-Path $repoRoot "git\hooks"
if (Test-Path $hooksPath) {
	Invoke-SetupStep "Global git hooks" {
		if (-not (Test-Path $gitconfigLocal)) {
			throw ".gitconfig.local is unavailable"
		}

		git config --file $gitconfigLocal core.hooksPath $hooksPath
		if ($LASTEXITCODE -ne 0) {
			throw "Failed to set core.hooksPath"
		}

		$configuredHooksPath = git config --file $gitconfigLocal --get core.hooksPath
		if ($LASTEXITCODE -ne 0 -or $configuredHooksPath -ne $hooksPath) {
			throw "core.hooksPath verification failed"
		}

		Write-Host "  [OK] Global git hooks ($hooksPath)" -ForegroundColor Green
	}
}

# Install posh-git from PowerShell Gallery (for git tab completion)
Write-Host "`nChecking posh-git..." -ForegroundColor Cyan
Invoke-SetupStep "PowerShell 7 posh-git installation" {
	Install-PoshGitForPowerShell7
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
