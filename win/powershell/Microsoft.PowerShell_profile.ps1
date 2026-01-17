##-------------------------------------------
## Environment Settings
##-------------------------------------------
$env:DOTNET_CLI_TELEMETRY_OPTOUT = 1

# Admin detection + window title
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$Host.UI.RawUI.WindowTitle = "PowerShell $($PSVersionTable.PSVersion.Major)" + $(if ($isAdmin) { " [ADMIN]" })

##-------------------------------------------
## Navigation & Utilities
##-------------------------------------------
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function md5($file) { (Get-FileHash $file -Algorithm MD5).Hash }
function sha256($file) { (Get-FileHash $file -Algorithm SHA256).Hash }
function mkcd { param($dir) New-Item -ItemType Directory -Path $dir -Force | Out-Null; Set-Location $dir }
function ll { Get-ChildItem -Force | Format-Table -AutoSize }
function flushdns { Clear-DnsClientCache; Write-Host "DNS cache flushed" -ForegroundColor Green }

##-------------------------------------------
## Aliases
##-------------------------------------------
Set-Alias claer clear
Set-Alias open start

# Application aliases (only set if found)
$sevenZip = "$env:ProgramFiles\7-Zip\7z.exe"
if (Test-Path $sevenZip) { Set-Alias sz $sevenZip }

# VS Code - 'code' is already in PATH via installer, just add shortcuts
if (Get-Command code -ErrorAction SilentlyContinue) {
	Set-Alias edit code
	Set-Alias e code
}

# Visual Studio detection (searches recent versions first)
$vs = @(2025, 2024, 2022, 2019) | ForEach-Object { $year = $_
	@('Enterprise', 'Professional', 'Community') | ForEach-Object {
		"${env:ProgramFiles}\Microsoft Visual Studio\$year\$_\Common7\IDE\devenv.exe"
	}
} | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($vs) { Set-Alias vs $vs }

##-------------------------------------------
## Load Modules
##-------------------------------------------
Import-Module (Join-Path $PSScriptRoot "Modules\CianTools") -Force -ErrorAction SilentlyContinue
Import-Module posh-git -ErrorAction SilentlyContinue

##-------------------------------------------
## PSReadLine Configuration
##-------------------------------------------
Set-PSReadLineOption -BellStyle Visual
Set-PSReadLineOption -HistoryNoDuplicates:$true

# Key remaps - flip Up/Down and F8/Shift+F8
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key F8 -Function PreviousHistory
Set-PSReadLineKeyHandler -Key Shift+F8 -Function NextHistory
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# PS7+ features: prediction and additional key handlers
if ($PSVersionTable.PSVersion.Major -ge 7) {
	Set-PSReadLineOption -PredictionSource History
	Set-PSReadLineOption -PredictionViewStyle ListView
	Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
	Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -Function BackwardDeleteWord
	Set-PSReadLineKeyHandler -Chord 'Ctrl+LeftArrow' -Function BackwardWord
	Set-PSReadLineKeyHandler -Chord 'Ctrl+RightArrow' -Function ForwardWord
}