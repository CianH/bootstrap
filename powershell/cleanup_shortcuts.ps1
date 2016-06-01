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

function CleanupStartMenuShortcut{
	param(
		$RootStartMenuFolder,
		$FolderName,
		$ShortcutName,
		[switch]$Desktop
	)
	
	echo "Working on $ShortcutName"
	if (Test-Path "$RootStartMenuFolder\$ShortcutName"){
		if (Test-Path "$RootStartMenuFolder\$FolderName"){
			rm -r -force "$RootStartMenuFolder\$FolderName"
		}
	}
	else{
		if (Test-Path $RootStartMenuFolder\$FolderName\$ShortcutName)
		{
			mv $RootStartMenuFolder\$FolderName\$ShortcutName $ExpectedShortcutLocation\
		}
	}
	if ($Desktop){
		if (Test-Path "$env:PUBLIC\Desktop\$ShortcutName"){
			rm "$env:PUBLIC\Desktop\$ShortcutName"
		}
		if (Test-Path "$env:USERPROFILE\Desktop\$ShortcutName"){
			rm "$env:USERPROFILE\Desktop\$ShortcutName"
		}
	}
}

CleanupStartMenuShortcut $ProgramDataStart "CCleaner" "CCleaner.lnk" -Desktop
CleanupStartMenuShortcut $ProgramDataStart "Dropbox" "Dropbox.lnk"
CleanupStartMenuShortcut $AppDataStart "GitHub, Inc" "GitHub.appref-ms"
CleanupStartMenuShortcut $ProgramDataStart "Skype" "Skype.lnk" -Desktop
CleanupStartMenuShortcut $AppDataStart "Slack Technologies" "Slack.lnk"
CleanupStartMenuShortcut $AppDataStart "Vim 7.4" "Vim.lnk"
CleanupStartMenuShortcut $AppDataStart "WinDirStat" "WinDirStat.lnk" -Desktop
CleanupStartMenuShortcut $AppDataStart "Sysinternals" "Process Explorer.lnk"
CleanupStartMenuShortcut $ProgramDataStart "VideoLAN" "VLC media player.lnk" -Desktop
CleanupStartMenuShortcut $ProgramDataStart "7-Zip" "7-Zip File Manager.lnk"

# Remove CCleaner "Open in CCleaner", etc RegKeys
echo "Removing CCleaner regkeys"
rm "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\Run CCleaner" -Recurse 2>$null
rm "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\Open CCleaner..." -Recurse 2>$null

rm "Registry::HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\Run CCleaner" -Recurse 2>$null
rm "Registry::HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\Open CCleaner..." -Recurse 2>$null