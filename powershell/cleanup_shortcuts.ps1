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
	
	Write-Output "Working on $ShortcutName"
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