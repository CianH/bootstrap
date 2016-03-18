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

# Setup Powershell symlinks
cmd /c mklink /D  "$env:USERPROFILE\Documents\WindowsPowerShell\" "$env:USERPROFILE\Documents\github\bootstrap\powershell\"

# Setup vimrc
cmd /c mklink "$env:USERPROFILE\_vimrc" "$env:USERPROFILE\Documents\github\bootstrap\.vimrc"
