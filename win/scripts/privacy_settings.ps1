[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$MachineOnly,
    [string]$MachineFileNames
)

# Apply privacy-related registry settings.
# Each .reg file in win/regkeys/ groups related settings with comments explaining its purpose.

$regkeysPath = Join-Path $PSScriptRoot "..\regkeys"

$regFiles = @(
    "DisableAdvertisingId.reg",
    "DisableBingSearch.reg",
    "DisableLanguageSharing.reg",
    "DisableLocation.reg",
    "DisableOnedriveAds.reg",
    "DisableSmartScreen.reg",
    "DisableTelemetry.reg",
    "DisableTypingData.reg",
    "DisableUpdateP2P.reg",
    "DisableWiFiSense.reg",
    "ExplorerTweaks.reg"
)

$failures = [System.Collections.Generic.List[string]]::new()
$confirmRequested = $PSBoundParameters.ContainsKey("Confirm") -and $PSBoundParameters["Confirm"]

function Add-RegistryFailure {
    param(
        [string]$Name,
        [string]$Reason
    )

    $script:failures.Add("$Name`: $Reason")
    Write-Host "  [ERROR] $Name`: $Reason" -ForegroundColor Red
}

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$identity
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-RegistryFile {
    param([string]$Name)

    $path = Join-Path $regkeysPath $Name
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "File not found: $path"
    }

    $hives = @(
        Get-Content -LiteralPath $path -ErrorAction Stop |
            ForEach-Object {
                if ($_ -match '^\s*\[-?(HKEY_[^\\\]]+)(?:\\|\])') {
                    $Matches[1].ToUpperInvariant()
                }
            } |
            Sort-Object -Unique
    )

    if ($hives.Count -eq 0) {
        throw "No registry key headers found"
    }

    if ($hives.Count -gt 1) {
        throw "Mixed registry hives are not supported: $($hives -join ', ')"
    }

    $scope = switch ($hives[0]) {
        "HKEY_CURRENT_USER" { "CurrentUser" }
        "HKEY_LOCAL_MACHINE" { "Machine" }
        default { throw "Unsupported registry hive: $($hives[0])" }
    }

    return [pscustomobject]@{
        Name = $Name
        Path = $path
        Scope = $scope
    }
}

function Resolve-RegistryFiles {
    param(
        [string[]]$Names,
        [switch]$RequireMachineScope
    )

    $resolvedFiles = [System.Collections.Generic.List[object]]::new()

    foreach ($name in $Names) {
        if ($regFiles -notcontains $name) {
            Add-RegistryFailure $name "File is not included in the registry settings list"
            continue
        }

        try {
            $file = Get-RegistryFile $name
            if ($RequireMachineScope -and $file.Scope -ne "Machine") {
                Add-RegistryFailure $name "Elevated phase accepts only HKEY_LOCAL_MACHINE files"
                continue
            }
            $resolvedFiles.Add($file)
        } catch {
            Add-RegistryFailure $name $_.Exception.Message
        }
    }

    return $resolvedFiles.ToArray()
}

function Invoke-RegistryFiles {
    [CmdletBinding(SupportsShouldProcess)]
    param([object[]]$Files)

    if ($Files.Count -eq 0) {
        return
    }

    try {
        $regExecutable = (Get-Command reg.exe -CommandType Application -ErrorAction Stop).Source
    } catch {
        foreach ($file in $Files) {
            Add-RegistryFailure $file.Name "reg.exe is unavailable"
        }
        return
    }

    foreach ($file in $Files) {
        if (-not $PSCmdlet.ShouldProcess($file.Path, "Import $($file.Scope) registry settings")) {
            continue
        }

        Write-Host "Applying $($file.Name)..." -ForegroundColor Cyan

        try {
            $arguments = "import `"$($file.Path)`""
            $process = Start-Process -FilePath $regExecutable -ArgumentList $arguments -NoNewWindow -Wait -PassThru -ErrorAction Stop
        } catch {
            Add-RegistryFailure $file.Name $_.Exception.Message
            continue
        }

        if ($process.ExitCode -ne 0) {
            Add-RegistryFailure $file.Name "reg.exe exited with code $($process.ExitCode)"
            continue
        }

        Write-Host "  [OK] $($file.Name)" -ForegroundColor Green
    }
}

function Invoke-RegistryFileGroup {
    param([object[]]$Files)

    $invokeParameters = @{
        Files = $Files
        WhatIf = [bool]$WhatIfPreference
    }
    if ($confirmRequested) {
        $invokeParameters.Confirm = $true
    }

    Invoke-RegistryFiles @invokeParameters
}

function Start-ElevatedMachinePhase {
    param([object[]]$Files)

    try {
        $powerShellPath = (Get-Process -Id $PID -ErrorAction Stop).Path
        $fileNames = ($Files.Name -join "|")
        $arguments = "-NoProfile -File `"$PSCommandPath`" -MachineOnly -MachineFileNames `"$fileNames`""
        if ($confirmRequested) {
            $arguments += " -Confirm"
        }

        $process = Start-Process -FilePath $powerShellPath -Verb RunAs -ArgumentList $arguments -Wait -PassThru -ErrorAction Stop
    } catch {
        Add-RegistryFailure "Machine-level registry settings" $_.Exception.Message
        return
    }

    if ($process.ExitCode -ne 0) {
        Add-RegistryFailure "Machine-level registry settings" "Elevated phase exited with code $($process.ExitCode)"
    }
}

function Complete-RegistrySettings {
    if ($failures.Count -eq 0) {
        if ($WhatIfPreference) {
            Write-Host "`nRegistry settings preview completed." -ForegroundColor Green
        } else {
            Write-Host "`nRegistry settings completed successfully." -ForegroundColor Green
        }
        exit 0
    }

    Write-Host "`nRegistry settings completed with $($failures.Count) failure(s):" -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host "  - $failure" -ForegroundColor Red
    }
    exit 1
}

if ($MachineOnly) {
    if ([string]::IsNullOrWhiteSpace($MachineFileNames)) {
        Add-RegistryFailure "Machine-level registry settings" "No registry files were provided"
        Complete-RegistrySettings
    }

    if (-not $WhatIfPreference -and -not (Test-IsAdministrator)) {
        Add-RegistryFailure "Machine-level registry settings" "Elevated phase is not running as an administrator"
        Complete-RegistrySettings
    }

    $requestedMachineFiles = @($MachineFileNames -split '\|' | Where-Object { $_ })
    $machineFiles = @(Resolve-RegistryFiles -Names $requestedMachineFiles -RequireMachineScope)
    Invoke-RegistryFileGroup $machineFiles
    Complete-RegistrySettings
}

$classifiedFiles = @(Resolve-RegistryFiles -Names $regFiles)
$currentUserFiles = @($classifiedFiles | Where-Object { $_.Scope -eq "CurrentUser" })
$machineFiles = @($classifiedFiles | Where-Object { $_.Scope -eq "Machine" })

Invoke-RegistryFileGroup $currentUserFiles

if ($WhatIfPreference -or (Test-IsAdministrator)) {
    Invoke-RegistryFileGroup $machineFiles
} elseif ($machineFiles.Count -gt 0) {
    Start-ElevatedMachinePhase $machineFiles
}

Complete-RegistrySettings
