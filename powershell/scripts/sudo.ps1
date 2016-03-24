<#
.SYNOPSIS
	Runs the specified command in an elevated context.
.DESCRIPTION
	Runs the specified command in an elevated context.  This is useful on Windows Vista
	and Windows 7 when you run with a standard user token but can elevate to Admin when needed.
.EXAMPLE
	C:\PS> Invoke-Elevated
	Opens a new PowerShell instance as admin.
.EXAMPLE
	C:\PS> Invoke-Elevated Notepad C:\windows\system32\drivers\etc\hosts
	Opens notepad elevated with the hosts file so that you can save changes to the file.
.EXAMPLE
	C:\PS> Invoke-Elevated {gci c:\windows\temp | export-clixml tempdir.xml; exit}
	Executes the scriptblock in an elevated PowerShell instance.
.EXAMPLE
	C:\PS> Invoke-Elevated {gci c:\windows\temp | export-clixml tempdir.xml; exit} | %{$_.WaitForExit(5000)} | %{Import-Clixml tempdir.xml}
	Executes the scriptblock in an elevated PowerShell instance, waits for that elevated process to execute, then
	retrieves the results.
.NOTES
	Aliases: sudo
	Author:  Keith Hill
	GitHub: https://github.com/Pscx/Pscx
#>
function Invoke-Elevated 
{
	Write-Debug "`$MyInvocation:`n$($MyInvocation | Out-String)"
 
	$startProcessArgs = @{
		FilePath     = "PowerShell.exe"
		ArgumentList = "-NoExit", "-Command", "& {Set-Location '$pwd'}"
		Verb         = "runas"
		PassThru     = $true
		WorkingDir   = $pwd
	}
 
	$OFS = " "
	if ($args.Count -eq 0)      
	{
		Write-Debug "  Starting Powershell without no supplied args"
	}
	elseif ($args[0] -is [Scriptblock]) 
	{
		$script = $args[0]
		if ($script -match '(?si)\s*param\s*\(')
		{
			$startProcessArgs['ArgumentList'] = "-NoExit", "-Command", "& {$script}"
		}
		else
		{
			$startProcessArgs['ArgumentList'] = "-NoExit", "-Command", "& {Set-Location '$pwd'; $script}"
		}
		[string[]]$cmdArgs = @()
		if ($args.Count -gt 1)
		{
			$cmdArgs = $args[1..$($args.Length-1)]
			$startProcessArgs['ArgumentList'] += $cmdArgs
		}
		Write-Debug "  Starting PowerShell with scriptblock: {$script} and args: $cmdArgs"
	}
	else
	{
		$app = Get-Command $args[0] | Select -First 1 | Where {$_.CommandType -eq 'Application'}
		[string[]]$cmdArgs = @()
		if ($args.Count -gt 1)
		{
			$cmdArgs = $args[1..$($args.Length-1)]
		}
		if ($app) {
			$startProcessArgs['FilePath'] = $app.Path
			if ($cmdArgs.Count -eq 0)
			{
				$startProcessArgs.Remove('ArgumentList')
			}
			else
			{
				$startProcessArgs['ArgumentList'] = $cmdArgs
			}
			Write-Debug "  Starting app $app with args: $cmdArgs"
		}
		else {
			$poshCmd = $args[0]
			$startProcessArgs['ArgumentList'] = "-NoExit", "-Command", "& {Set-Location '$pwd'; $poshCmd $cmdArgs}"
			Write-Debug "  Starting PowerShell command $poshCmd with args: $cmdArgs"
		}
	}
 
	Write-Debug "  Invoking Start-Process with args: $($startProcessArgs | Format-List | Out-String)" 
	Microsoft.PowerShell.Management\Start-Process @startProcessArgs
}

Set-Alias sudo Invoke-Elevated
Set-Alias su Invoke-Elevated