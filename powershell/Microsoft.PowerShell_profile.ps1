##-------------------------------------------
## Aliases
##-------------------------------------------
Set-Alias npp "C:\Program Files (x86)\Notepad++\notepad++.exe"
Set-Alias vs "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\devenv.exe"
# to add arguments to a command, you need to create a function and then alias that 
function vs2015admin {Start-Process "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\devenv.exe" -verb runAs} 
Set-Alias vsadmin vs2015admin 
#Set-Alias git "$env:LOCALAPPDATA\GitHub\PortableGit_c7e0cbde92ba565cb218a521411d0e854079a28c\cmd\git.exe"
Set-Alias git "$env:LOCALAPPDATA\GitHub\PortableGit_cf76fc1621ac41ad4fe86c420ab5ff403f1808b9\cmd\git.exe"

##-------------------------------------------
## Misc functions
##-------------------------------------------
function pro {notepad $profile}

function prompt { $env:computername + "\" + (get-location) + "> " }

function which($cmd) { (gcm $cmd).Path }

function mklink { cmd /c mklink $args }

function mkdlink { cmd /c mklink /D $args }

##-------------------------------------------
## Load Script Libraries
##-------------------------------------------
$lib_home = "$env:USERPROFILE/Documents/GitHub/bootstrap/powershell/scripts"
Get-ChildItem $lib_home\*.ps1 | ForEach-Object {. (Join-Path $lib_home $_.Name)} | Out-Null
