@{
	# Script module or binary module file associated with this manifest.
	RootModule = 'CianTools.psm1'

	# Version number of this module.
	ModuleVersion = '1.0.0'

	# Supported PSEditions
	# CompatiblePSEditions = @()

	# ID used to uniquely identify this module
	GUID = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'

	# Author of this module
	Author = 'Cian'

	# Company or vendor of this module
	CompanyName = 'Personal'

	# Copyright statement for this module
	Copyright = '(c) 2025 Cian. All rights reserved.'

	# Description of the functionality provided by this module
	Description = 'Personal PowerShell utilities and helper functions for development and system administration'

	# Minimum version of the PowerShell engine required by this module
	PowerShellVersion = '5.1'

	# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
	FunctionsToExport = @(
		# FileSystem Functions
		'New-TouchFile',
		'Get-DirectorySizes',
		'Compress-DirectoriesToArchive',
		'Convert-DirectoriesToCBZ',
		'Find-Files',
		'Invoke-ForEachDirectory',
		'Get-FileCrc32',
		
		# Development Functions
		'Edit-Profile',
		'Get-CommandPath',
		'Find-CommandAlias',
		'Import-Profile',
		'Push-Project',
		
		# System Functions
		'Edit-HostsFile',
		'New-SymbolicLink',
		'New-DirectoryLink',
		'Backup-HostsFile',
		'Restore-HostsFile',
		'Block-Host',
		'Stop-RazerServices',
		
		# Utilities Functions
		'ConvertTo-Binary',
		'ConvertTo-Hex',
		'Get-CianTools',
		
		# Media Functions
		'Remove-MkvTitle',
		'Remove-MkvTitlesInDirectory', 
		'Remove-MkvSubtitles',
		'Export-MkvSubtitles',
		
		# Configuration Functions
		'Get-CianToolsConfig',
		'Set-CianToolsConfig',
		'Reset-CianToolsConfig',
		'Show-CianToolsConfig'
	)

	# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
	CmdletsToExport = @()

	# Variables to export from this module
	VariablesToExport = '*'

	# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
	AliasesToExport = @(
		# FileSystem aliases
		'touch',
		'zipall',
		'dirs2cbz',
		'find',
		'fed',
		'crc32',
		
		# Development aliases  
		'pro',
		'which',
		'gas',
		'reload',
		'pp',
		
		# System aliases
		'hosts',
		'mklink',
		'mkdlink', 
		'hostsb',
		'hostsr',
		'block',
		
		# Utilities aliases
		'mytools',
		
		# Configuration aliases
		'ctconfig',
		'ctset',
		'ctreset',
		'ctshow'
	)

	# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData = @{

		PSData = @{

			# Tags applied to this module. These help with module discovery in online galleries.
			Tags = @('Utilities', 'Development', 'Personal')

			# A URL to the license for this module.
			# LicenseUri = ''

			# A URL to the main website for this project.
			# ProjectUri = ''

			# A URL to an icon representing this module.
			# IconUri = ''

			# ReleaseNotes of this module
			ReleaseNotes = 'Initial release of personal PowerShell utilities'

		} # End of PSData hashtable

	} # End of PrivateData hashtable
}
