# Apply privacy-related registry settings
# Each .reg file in win/regkeys/ contains a single setting with comments explaining its purpose

$regkeysPath = Join-Path $PSScriptRoot "..\win\regkeys"

$regFiles = @(
    "DisableAdvertisingId.reg",
    "DisableBingSearch.reg",
    "DisableLanguageSharing.reg",
    "DisableLocation.reg",
    "DisableOnedriveAds.reg",
    "DisableSmartScreen.reg",
    "DisableTelemetry.reg",
    "DisableTypingData.reg"
)

foreach ($file in $regFiles) {
    $path = Join-Path $regkeysPath $file
    if (Test-Path $path) {
        Write-Host "Applying $file..." -ForegroundColor Cyan
        reg import $path 2>$null
    } else {
        Write-Warning "Registry file not found: $path"
    }
}