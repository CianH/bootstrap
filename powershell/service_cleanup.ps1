function StopAndDisableService {
	param(
		$Name
	)

	$service = Get-Service $Name
	if ($service) {
		$service | Stop-Service -PassThru | Set-Service -StartupType Disabled
	}
}

function StopProcessSilentlyAndForceFully {
	param (
		$Name
	)

	$process = Get-Process $Name -ErrorAction SilentlyContinue
	if ($process) {
		$process | Stop-Process -Force
	}
}

function SleepIfTask {
	# Script runs at login - give time for services to establish themselves so we don't try to kill before they've even started.
	$task = Get-ScheduledTask -TaskName "Startup Service Killer"
	if ($task.State -eq 'Running') {
		Start-Sleep -Seconds 20 
	} else {
		Write-Output "Skipping Sleep, task is not running"
	}
}

SleepIfTask
StopAndDisableService -Name "AsusUpdateCheck"
StopProcessSilentlyAndForceFully -Name "WidgetService"
StopProcessSilentlyAndForceFully -Name "Widgets"