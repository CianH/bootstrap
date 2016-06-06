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
cinst notepadplusplus -y
cinst github -y
cinst google-chrome-x64 -y
cinst firefox -y
cinst vim -y
cinst sysinternals -y
cinst putty -y
cinst nuget.commandline -y

# Setup Powershell symlinks
cmd /c mklink /D "$env:USERPROFILE\Documents\WindowsPowerShell\" "$PSScriptRoot"

# Setup vimrc
cmd /c mklink "$env:USERPROFILE\_vimrc" "$((Get-Item $PSScriptRoot).parent.FullName)\.vimrc"

# Enable Windows Optional Features
try { Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" } catch {} # Fails on TH2, swallow the error.

# Set privacy settings
& $PSScriptRoot\privacy_settings.ps1