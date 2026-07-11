[CmdletBinding(SupportsShouldProcess)]
param()

# Requires Admin prompt
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator") -and -not $WhatIfPreference)
{
	$powerShellPath = (Get-Process -Id $PID -ErrorAction Stop).Path
	$command = "& '" + $MyInvocation.MyCommand.Definition + "'"
	if ($PSBoundParameters.ContainsKey("Confirm") -and $PSBoundParameters["Confirm"]) {
		$command += " -Confirm"
	}
	$arguments = "-NoProfile -Command `"$command`""
	$process = Start-Process -FilePath $powerShellPath -Verb RunAs -ArgumentList $arguments -Wait -PassThru -ErrorAction Stop
	exit $process.ExitCode
}

### Used to remove annoying folders and shortcuts that pollute my start menu after every upgrade ###
$ProgramDataStart = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"
$AppDataStart = "$env:AppData\Microsoft\Windows\Start Menu\Programs"
$cleanupFailed = $false

function Invoke-CleanupAction {
	[CmdletBinding(SupportsShouldProcess)]
	param(
		$Target,
		$Action,
		[scriptblock]$Operation
	)

	if (-not $PSCmdlet.ShouldProcess($Target, $Action)) {
		return $WhatIfPreference
	}

	try {
		& $Operation
		return $true
	} catch {
		$script:cleanupFailed = $true
		Write-Error $_ -ErrorAction Continue
		return $false
	}
}

function Update-StartMenuShortcut {
	param(
		$RootStartMenuFolder,
		$FolderName,
		$ShortcutName,
		[switch]$Desktop
	)

	Write-Output "Working on $ShortcutName"

	$shortcutAtRoot = Test-Path "$RootStartMenuFolder\$ShortcutName"
	if (-not $shortcutAtRoot -and (Test-Path "$RootStartMenuFolder\$FolderName\$ShortcutName")) {
		$shortcutAtRoot = Invoke-CleanupAction "$RootStartMenuFolder\$FolderName\$ShortcutName" "Move shortcut to $RootStartMenuFolder" {
			Move-Item $RootStartMenuFolder\$FolderName\$ShortcutName $RootStartMenuFolder\ -ErrorAction Stop
		}
	}

	if ($shortcutAtRoot -and (Test-Path "$RootStartMenuFolder\$FolderName")) {
		[void](Invoke-CleanupAction "$RootStartMenuFolder\$FolderName" "Remove Start menu folder and all contents" {
			Remove-Item -Recurse -Force "$RootStartMenuFolder\$FolderName" -ErrorAction Stop
		})
	}

	if ($Desktop) {
		Remove-DesktopShortcut $ShortcutName
	}
}

function Remove-DesktopShortcut {
	param(
		[parameter(Mandatory = $true)]$ShortcutName
	)

	if (Test-Path "$env:PUBLIC\Desktop\$ShortcutName") {
		[void](Invoke-CleanupAction "$env:PUBLIC\Desktop\$ShortcutName" "Remove desktop shortcut" {
			Remove-Item "$env:PUBLIC\Desktop\$ShortcutName" -ErrorAction Stop
		})
	}
	if (Test-Path "$env:USERPROFILE\Desktop\$ShortcutName") {
		[void](Invoke-CleanupAction "$env:USERPROFILE\Desktop\$ShortcutName" "Remove desktop shortcut" {
			Remove-Item "$env:USERPROFILE\Desktop\$ShortcutName" -ErrorAction Stop
		})
	}
}

function Remove-RegistryKey {
	param($Path)

	if (Test-Path $Path) {
		[void](Invoke-CleanupAction $Path "Remove registry key" {
			Remove-Item $Path -Recurse -ErrorAction Stop
		})
	}
}

Update-StartMenuShortcut $ProgramDataStart "7-Zip" "7-Zip File Manager.lnk"
Update-StartMenuShortcut $ProgramDataStart "HandBrake" "HandBrake.lnk" -Desktop
Update-StartMenuShortcut $ProgramDataStart "MKVToolNix" "MKVToolNix GUI.lnk"
Update-StartMenuShortcut $ProgramDataStart "Mp3tag" "Mp3tag.lnk" -Desktop
Update-StartMenuShortcut $ProgramDataStart "Steam" "Steam.lnk" -Desktop
Update-StartMenuShortcut $ProgramDataStart "VideoLAN" "VLC media player.lnk" -Desktop
Update-StartMenuShortcut $ProgramDataStart "calibre 64bit - E-book Management" "calibre 64bit - E-book management.lnk" -Desktop
Update-StartMenuShortcut $ProgramDataStart "PowerToys (Preview)" "PowerToys (Preview).lnk"
Update-StartMenuShortcut $ProgramDataStart "qBittorrent" "qBittorrent.lnk"
Update-StartMenuShortcut $ProgramDataStart "Razer" "Razer Synapse.lnk"
Update-StartMenuShortcut $ProgramDataStart "Visual Studio Code" "Visual Studio Code.lnk"
Update-StartMenuShortcut $ProgramDataStart "WizTree" "WizTree.lnk"
Update-StartMenuShortcut $AppDataStart "GitHub, Inc" "GitHub Desktop.lnk" -Desktop
Update-StartMenuShortcut $AppDataStart "Slack Technologies" "Slack.lnk" -Desktop
Update-StartMenuShortcut $AppDataStart "Sysinternals" "Process Explorer.lnk"

Remove-DesktopShortcut "Mozilla Firefox.lnk"

# Remove CCleaner "Open in CCleaner", etc RegKeys
Write-Output "Removing CCleaner regkeys"
Remove-RegistryKey "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\Run CCleaner"
Remove-RegistryKey "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\Open CCleaner..."
Remove-RegistryKey "HKLM:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\Run CCleaner"
Remove-RegistryKey "HKLM:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\Open CCleaner..."

if ($cleanupFailed) {
	exit 1
}