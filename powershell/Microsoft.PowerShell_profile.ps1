##-------------------------------------------
## Environment Settings
##-------------------------------------------
$env:DOTNET_CLI_TELEMETRY_OPTOUT = 1

##-------------------------------------------
## Application Detection
##-------------------------------------------
# VS Code detection (simplified)
$code_locations = @(
	"${env:LocalAppData}\Programs\Microsoft VS Code\bin\code",
	"${env:ProgramFiles}\Microsoft VS Code\bin\code"
)
$code = $code_locations | Where-Object { Test-Path $_ } | Select-Object -First 1

##-------------------------------------------
## Visual Studio Detection
##-------------------------------------------
$vs_editions = @('Enterprise', 'Professional', 'Community')
$vs = $vs_editions | ForEach-Object {
	"${env:ProgramFiles}\Microsoft Visual Studio\2022\$_\Common7\IDE\devenv.exe"
} | Where-Object { Test-Path $_ } | Select-Object -First 1
##-------------------------------------------
## Aliases
##-------------------------------------------
Set-Alias claer clear
Set-Alias open start

# 7-Zip detection
$sevenZip = "$env:ProgramFiles\7-Zip\7z.exe"
if (Test-Path $sevenZip) {
	Set-Alias sz $sevenZip
} else {
	Write-Warning "7-Zip not found - sz alias not available"
}

# Application aliases (only set if applications exist)
if ($code) { 
	Set-Alias code $code
	Set-Alias edit $code
	Set-Alias e $code
} else {
	Write-Warning "VS Code not found - edit aliases not available"
}

if ($vs) { 
	Set-Alias vs $vs 
} else { 
	Write-Warning "Visual Studio not found"
}

##-------------------------------------------
## Load CianTools Module
##-------------------------------------------
$ModulePath = Join-Path $PSScriptRoot "Modules\CianTools"
if (Test-Path $ModulePath) {
	try {
		Import-Module $ModulePath -Force -ErrorAction Stop
		Write-Host "CianTools module loaded. Type 'mytools' to see available functions." -ForegroundColor Green
	}
	catch {
		Write-Warning "Failed to load CianTools module: $($_.Exception.Message)"
	}
} else {
	Write-Warning "CianTools module not found at $ModulePath"
}

##-------------------------------------------
## Load Git Integration
##-------------------------------------------
try {
	Import-Module posh-git -ErrorAction Stop
	Write-Host "posh-git loaded successfully" -ForegroundColor Green
}
catch {
	Write-Warning "Failed to load posh-git: $($_.Exception.Message)"
}

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