# Requires Admin prompt
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
	$arguments = "& '" + $myinvocation.mycommand.definition + "'"
	Start-Process powershell -Verb runAs -ArgumentList $arguments
	Break
}

### Used to remove annoying folders and shortcuts that pollute my start menu after every upgrade ###
$ProgramDataStart = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
$AppDataStart = "$env:AppData\Microsoft\Windows\Start Menu\Programs"

function Update-StartMenuShortcut{
	param(
		$RootStartMenuFolder,
		$FolderName,
		$ShortcutName,
		[switch]$Desktop
	)

	Write-Output "Working on $ShortcutName"
	if (Test-Path "$RootStartMenuFolder\$ShortcutName"){
		if (Test-Path "$RootStartMenuFolder\$FolderName"){
			Remove-Item -r -force "$RootStartMenuFolder\$FolderName"
		}
	}
	else{
		if (Test-Path $RootStartMenuFolder\$FolderName\$ShortcutName){
			Move-Item $RootStartMenuFolder\$FolderName\$ShortcutName $RootStartMenuFolder\
		}
	}
	if ($Desktop){
		Remove-DesktopShortcut $ShortcutName
	}
}

function Remove-DesktopShortcut{
	param(
		[parameter(Mandatory = $true)]$ShortcutName
	)

  if (Test-Path "$env:PUBLIC\Desktop\$ShortcutName"){
		Remove-Item "$env:PUBLIC\Desktop\$ShortcutName"
	}
	if (Test-Path "$env:USERPROFILE\Desktop\$ShortcutName"){
		Remove-Item "$env:USERPROFILE\Desktop\$ShortcutName"
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
Remove-Item "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\Run CCleaner" -Recurse 2>$null
Remove-Item "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\Open CCleaner..." -Recurse 2>$null

Remove-Item "Registry::HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\Run CCleaner" -Recurse 2>$null
Remove-Item "Registry::HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\Open CCleaner..." -Recurse 2>$null