##-------------------------------------------
## Variables
##-------------------------------------------
$editor = "C:\Program Files (x86)\Notepad++\notepad++.exe"

##-------------------------------------------
## Aliases
##-------------------------------------------
Set-Alias claer clear
Set-Alias npp $editor
Set-Alias vs "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\devenv.exe"

# to add arguments to a command, you need to create a function and then alias that 
function vs2015admin {Start-Process "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\devenv.exe" -verb runAs} 
Set-Alias vsadmin vs2015admin

##-------------------------------------------
## Misc functions
##-------------------------------------------
function prompt { $env:computername + "\" + (get-location) + "> " }

function pro { npp $profile}

function hosts { Start-Process $editor -ArgumentList "-multiInst -notabbar -nosession C:\WINDOWS\system32\drivers\etc\hosts" -Verb runAs }

function mklink { cmd /c mklink $args }

function mkdlink { cmd /c mklink /D $args }

function which([Parameter(Mandatory=$true)]$cmd) { (gcm $cmd).Path 2>$null }

function admin([Parameter(Mandatory=$true)]$cmd) { Start-Process $cmd -Verb runAs }

function gas([Parameter(Mandatory=$true)]$cmd) { gal | ? { $_.Definition -match $cmd } }

function hostsb { cp "$env:windir\System32\drivers\etc\hosts" "$env:USERPROFILE\OneDrive\Synced" }

function hostsr { cp "$env:USERPROFILE\OneDrive\Synced\hosts" "$env:windir\System32\drivers\etc" } # requires ownership of path, otherwise wrap in sudo

function block([Parameter(Mandatory=$true)]$url) { ac -Path "$env:windir\system32\drivers\etc\hosts" -Value "`r`n0.0.0.0 $url" -NoNewline }

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