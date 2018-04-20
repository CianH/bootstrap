# Dev Machine Powershell setup - Requires Admin prompt
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
	$arguments = "& '" + $myinvocation.mycommand.definition + "'"
	Start-Process powershell -Verb runAs -ArgumentList $arguments
	Break
}

# Chocolatey install
if (!(gcm cinst -ErrorAction SilentlyContinue)){
	iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
}

# install applications
cinst slack -y
cinst github -y
cinst firefox -y
cinst sysinternals -y
cinst nuget.commandline -y

# Setup Powershell symlinks
cmd /c mklink /D "$env:USERPROFILE\Documents\WindowsPowerShell\" "$PSScriptRoot"

# Setup vimrc
cmd /c mklink "$env:USERPROFILE\_vimrc" "$((Get-Item $PSScriptRoot).parent.FullName)\.vimrc"

# Set privacy settings
& $PSScriptRoot\privacy_settings.ps1
