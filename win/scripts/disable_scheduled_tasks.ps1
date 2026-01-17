# Disable telemetry-related scheduled tasks
# Requires Admin

$tasks = @(
    "Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
    "Microsoft\Windows\Shell\FamilySafetyMonitor",
    "Microsoft\Windows\Shell\FamilySafetyMonitorToastTask",
    "Microsoft\Windows\Shell\FamilySafetyRefreshTask",
    "Microsoft\Windows\PI\Sqm-Tasks"
)

foreach ($task in $tasks) {
    try {
        $t = Get-ScheduledTask -TaskPath "\$($task | Split-Path -Parent)\" -TaskName ($task | Split-Path -Leaf) -ErrorAction SilentlyContinue
        if ($t) {
            Disable-ScheduledTask -TaskPath $t.TaskPath -TaskName $t.TaskName | Out-Null
            Write-Host "Disabled: $task" -ForegroundColor Green
        } else {
            Write-Host "Not found: $task" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Warning "Failed to disable $task : $($_.Exception.Message)"
    }
}
