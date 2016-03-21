# Dev Machine Powershell setup - Requires Admin prompt

# Chocolatey install
iex ((new-object net.webclient).DownloadString('http://bit.ly/psChocInstall'))

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
cmd /c mklink /D  "$env:USERPROFILE\Documents\WindowsPowerShell\" "$PSScriptRoot"

# Setup vimrc
cmd /c mklink "$env:USERPROFILE\_vimrc" "$((Get-Item $PSScriptRoot).parent.FullName)\.vimrc"
