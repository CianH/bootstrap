##-------------------------------------------
## Aliases
##-------------------------------------------
Set-Alias npp "C:\Program Files (x86)\Notepad++\notepad++.exe"
Set-Alias vs "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\devenv.exe"

# to add arguments to a command, you need to create a function and then alias that 
function vs2015admin {Start-Process "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\devenv.exe" -verb runAs} 
Set-Alias vsadmin vs2015admin

##-------------------------------------------
## Misc functions
##-------------------------------------------
function pro { npp $profile}

function prompt { $env:computername + "\" + (get-location) + "> " }

function which($cmd) { (gcm $cmd).Path }

function mklink { cmd /c mklink $args }

function mkdlink { cmd /c mklink /D $args }

##-------------------------------------------
## Load Script Libraries
##-------------------------------------------
$lib_home = "$PSScriptRoot\scripts"
Get-ChildItem $lib_home\*.ps1 | ForEach-Object {. (Join-Path $lib_home $_.Name)} | Out-Null

##-------------------------------------------
## Load Git
##-------------------------------------------
. (Resolve-Path "$env:LOCALAPPDATA\GitHub\shell.ps1")
. $env:github_posh_git\profile.example.ps1

# Shell.ps1 overwrites TMP and TEMP with a version with a trailing '\' 
$env:TMP = $env:TEMP = [system.io.path]::gettemppath().TrimEnd('\') 

##-------------------------------------------
## Key Remaps
##-------------------------------------------
# flip Up/Down and F8/Shift+F8
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadlineKeyHandler -Key F8 -Function PreviousHistory
Set-PSReadlineKeyHandler -Key Shift+F8 -Function NextHistory