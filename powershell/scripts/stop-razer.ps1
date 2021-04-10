# Razer has an annoying amount of services, that are inter-dependant and must be stopped in a particular order
# BUG: This only seems to work when already inside an admin prompt, why?
function Stop-RazerServices {
	# Requires Admin prompt
	if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
	{
		$arguments = "& '" + $myinvocation.mycommand.definition + "'"
		Start-Process powershell -Verb runAs -ArgumentList $arguments
		Break
	}

	function Service-Is-Running([String] $serviceName) {
		return (Get-Service $serviceName | Select -expand Status) -eq "Running"
	}

	function Stop-Service-And-Wait(
		[parameter(Mandatory=$true)][String] $serviceName,
		[int] $sleepTime = 0) {
		if (Service-Is-Running($serviceName)) {
			Write-Output "$serviceName is running, stopping"
			Stop-Service $serviceName
			if ($sleepTime -gt 0) {
				Write-Output "Waiting for $sleepTime seconds"
				Start-Sleep $sleepTime
			}
		}
		else { 
			Write-Output "$serviceName is already stopped"
		}
	}

	$services = @(
		"Razer Synapse Service",
		"Razer Chroma SDK Service",
		"RzActionSvc", # Razer Central Service
		"Razer Game Manager Service")

	foreach ($service in $services) {
		Stop-Service-And-Wait -serviceName $service -sleepTime 5
	}
}