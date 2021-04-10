##-------------------------------------------
## Environment Settings
##-------------------------------------------
$env:DOTNET_CLI_TELEMETRY_OPTOUT = 1

##-------------------------------------------
## Variables
##-------------------------------------------
$code = "${env:ProgramFiles}\Microsoft VS Code\bin\code"
$npp  = "${env:ProgramFiles}\Notepad++\notepad++.exe"
if (Test-Path $code) { $editor = $code }
elseif (Test-Path $npp) { $editor = $npp }
else {
	Write-Warning "Default editor falling back to notepad"
	$editor = "${$env:windir}\system32\notepad.exe"
}

##-------------------------------------------
## Visual Studio
##-------------------------------------------
$editions = @('Enterprise', 'Professional', 'Community')
foreach ($edition in $editions) {
	$vs_loc = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\$edition\Common7\IDE\devenv.exe"
	if (Test-Path $vs_loc)
	{
		$vs = $vs_loc
		break
	}
}
if ($vs) { Set-Alias vs $vs }
else { Write-Warning "Visual Studio not installed" }

##-------------------------------------------
## Aliases
##-------------------------------------------
Set-Alias claer clear
Set-Alias npp $npp
Set-Alias code $code
Set-Alias edit $editor
Set-Alias e $editor
Set-Alias sz "$env:ProgramFiles\7-Zip\7z.exe"
Set-Alias open start

##-------------------------------------------
## Misc functions
##-------------------------------------------
# This interferes with posh-git prompt
#function prompt { $env:computername + "\" + (get-location) + "> " }

function pro { edit $profile }

# TODO: Fix for when npp not installed
function hosts { Start-Process $npp -ArgumentList "-multiInst -notabbar -nosession C:\WINDOWS\system32\drivers\etc\hosts" -Verb runAs }

function mklink { cmd /c mklink $args }

function mkdlink { cmd /c mklink /D $args }

function which([Parameter(Mandatory=$true)]$cmd) { (gcm $cmd).Path 2>$null }

function admin([Parameter(Mandatory=$true)]$cmd) { Start-Process $cmd -Verb runAs }

function gas([Parameter(Mandatory=$true)]$cmd) { gal | ? { $_.Definition -match $cmd } }

function hostsb { cp "$env:windir\System32\drivers\etc\hosts" "$env:USERPROFILE\OneDrive\Synced" }

function hostsr { cp "$env:USERPROFILE\OneDrive\Synced\hosts" "$env:windir\System32\drivers\etc" } # requires ownership of path, otherwise wrap in sudo

function zipall($delete) { ls -Directory | % { sz a -t7z "$_.7z" ".\$_\*"; if ($delete){ rm -r -force $_ } } }

function dirs2cbz($delete) { ls -Directory | % { sz a -tzip "$_.cbz" ".\$_\*"; if ($delete){ rm -r -force $_ } } }

##-------------------------------------------
## Load Script Libraries
##-------------------------------------------
$lib_home = "$PSScriptRoot\scripts"
Get-ChildItem $lib_home\*.ps1 | ForEach-Object {. (Join-Path $lib_home $_.Name)} | Out-Null

##-------------------------------------------
## Load Git
##-------------------------------------------
if (Test-Path "$env:LOCALAPPDATA\GitHub\shell.ps1")
{
	. (Resolve-Path "$env:LOCALAPPDATA\GitHub\shell.ps1")
	. $env:github_posh_git\profile.example.ps1

	# Shell.ps1 overwrites TMP and TEMP with a version with a trailing '\' 
	$env:TMP = $env:TEMP = [system.io.path]::gettemppath().TrimEnd('\') 
}
else { Write-Warning "Git Shell not present" }

##-------------------------------------------
## Key Remaps
##-------------------------------------------
# flip Up/Down and F8/Shift+F8
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadlineKeyHandler -Key F8 -Function PreviousHistory
Set-PSReadlineKeyHandler -Key Shift+F8 -Function NextHistory

##-------------------------------------------
## Console State
##-------------------------------------------
Set-PSReadlineOption -BellStyle Visual