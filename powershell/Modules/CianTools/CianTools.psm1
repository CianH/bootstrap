#
# Module: CianTools
# Description: Personal PowerShell utilities and helper functions
#

# Get the path to the Functions directory
$FunctionsPath = Join-Path $PSScriptRoot 'Functions'

# Load all function files
if (Test-Path $FunctionsPath) {
    Get-ChildItem -Path $FunctionsPath -Filter '*.ps1' | ForEach-Object {
        try {
            . $_.FullName
            Write-Verbose "Loaded function file: $($_.Name)"
        }
        catch {
            Write-Warning "Failed to load function file $($_.Name): $($_.Exception.Message)"
        }
    }
}
else {
    Write-Warning "Functions directory not found: $FunctionsPath"
}

# Export module members (this is also defined in the manifest, but good to have here too)
# Note: The manifest takes precedence, but this serves as documentation
