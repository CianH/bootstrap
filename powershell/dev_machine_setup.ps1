# Dev Machine Powershell setup - Requires Admin prompt
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
	$arguments = "& '" + $myinvocation.mycommand.definition + "'"
	Start-Process powershell -Verb runAs -ArgumentList $arguments
	Break
}

# Chocolatey install
if (!(gcm cinst -ErrorAction SilentlyContinue)){
	iex ((new-object net.webclient).DownloadString('http://bit.ly/psChocInstall'))
}

# install applications
cinst slack -y
cinst firefox -y
cinst google-chrome-x64 -y
cinst notepadplusplus -y
# cinst git -y
# cinst github -y # failing due to md5 sum mismatch
cinst vim -y
cinst procexp -y
cinst putty -y
cinst nuget.commandline -y

# Setup Powershell symlinks
cmd /c mklink /D "$env:USERPROFILE\Documents\WindowsPowerShell\" "$PSScriptRoot"

# Setup vimrc
cmd /c mklink "$env:USERPROFILE\_vimrc" "$((Get-Item $PSScriptRoot).parent.FullName)\.vimrc"

# Setup hosts file
$hostsPath = "$env:windir\System32\drivers\etc\hosts"
$syncedHosts = "$env:USERPROFILE\OneDrive\Synced\hosts"
if (Test-Path "$syncedHosts") {
	mv "$hostsPath" "$hostsPath.old"
	cmd /c mklink "$hostsPath" "$syncedHosts"
}

# Enable Windows Optional Features
try { Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" } catch {} # Fails on TH2, swallow the error.