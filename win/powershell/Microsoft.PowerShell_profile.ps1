##-------------------------------------------
## Environment Settings
##-------------------------------------------
$env:DOTNET_CLI_TELEMETRY_OPTOUT = 1

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
## Key Remaps
##-------------------------------------------
# flip Up/Down and F8/Shift+F8
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadlineKeyHandler -Key F8 -Function PreviousHistory
Set-PSReadlineKeyHandler -Key Shift+F8 -Function NextHistory

##-------------------------------------------
## Console State
##-------------------------------------------
Set-PSReadlineOption -BellStyle Visual