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
cinst sysinternals -y
cinst putty -y
cinst nuget.commandline -y

# Setup Powershell symlinks
cmd /c mklink /D "$env:USERPROFILE\Documents\WindowsPowerShell\" "$PSScriptRoot"

# Setup vimrc
cmd /c mklink "$env:USERPROFILE\_vimrc" "$((Get-Item $PSScriptRoot).parent.FullName)\.vimrc"

# Enable Windows Optional Features
try { Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" } catch {} # Fails on TH2, swallow the error.

### Configure things ###
sp -path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -name BingSearchEnabled -value 0 # Web Search in Start
sp -path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection -name AllowTelemetry -value 0 # Telemetry

# Privacy/General
sp -path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo -name Enabled -value 0 # Let apps use my advertising ID
sp -path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost -name EnableWebContentEvaluation -value 0 # SmartScreen Filter
sp -path HKCU:\SOFTWARE\Microsoft\Input\TIPC -name Enabled -value 0 # Send MSFT info about typing/writing
sp -path "HKCU:\Control Panel\International\User Profile\" -name HttpAcceptLanguageOptOut -value 1 # Share language list to websites (1 is disable)

# Privacy/Location
sp -path HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\System -name AllowLocation -value 0 # Location for this device

