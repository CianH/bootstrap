#
# FileSystem Functions
# Functions for file and directory operations
#

function New-TouchFile {
	<#
	.SYNOPSIS
		Creates a new file or updates the timestamp of an existing file (Unix touch equivalent).
	
	.DESCRIPTION
		Creates an empty file if it doesn't exist, or updates the LastWriteTime of an existing file to the current time.
		This mimics the behavior of the Unix 'touch' command.
	
	.PARAMETER Path
		The path to the file to create or touch. Supports wildcards and multiple files.
	
	.PARAMETER Time
		Optional timestamp to set. Defaults to current time.
	
	.EXAMPLE
		New-TouchFile "newfile.txt"
		Creates an empty file called newfile.txt
	
	.EXAMPLE
		New-TouchFile "file1.txt", "file2.txt"
		Creates or touches multiple files
	
	.EXAMPLE
		touch "test.log"
		Updates timestamp on test.log using alias
	
	.NOTES
		Available via alias: touch
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory, ValueFromPipeline, Position = 0)]
		[string[]]$Path,
		
		[DateTime]$Time = (Get-Date)
	)
	
	process {
		foreach ($FilePath in $Path) {
			try {
				if (Test-Path $FilePath) {
					(Get-Item $FilePath).LastWriteTime = $Time
					Write-Verbose "Updated timestamp for: $FilePath"
				} else {
					New-Item -Path $FilePath -ItemType File -Force | Out-Null
					Write-Verbose "Created new file: $FilePath"
				}
			}
			catch {
				Write-Error "Failed to process '$FilePath': $($_.Exception.Message)"
			}
		}
	}
}

function Get-DirectorySizes {
	<#
	.SYNOPSIS
		Gets the size of all subdirectories in the current or specified directory.
	
	.DESCRIPTION
		Calculates and displays the total size of each subdirectory, including all files recursively.
		Sizes are displayed in MB for easier reading.
	
	.PARAMETER Path
		The directory to analyze. Defaults to current directory.
	
	.PARAMETER SortBy
		Sort results by Name or Size. Defaults to Name.
	
	.EXAMPLE
		Get-DirectorySizes
		Shows sizes of all subdirectories in current location
	
	.EXAMPLE
		Get-DirectorySizes -Path "C:\Projects" -SortBy Size
		Shows subdirectory sizes for C:\Projects sorted by size
	
	.NOTES
		This function replaces the old Dir-Sizes function with better error handling and parameters.
	#>
	[CmdletBinding()]
	param(
		[Parameter(Position = 0)]
		[string]$Path = (Get-Location),
		
		[ValidateSet('Name', 'Size')]
		[string]$SortBy = 'Name'
	)
	
	try {
		$directories = Get-ChildItem -Path $Path -Directory -ErrorAction Stop
		
		$results = foreach ($dir in $directories) {
			try {
				$size = Get-ChildItem -Path $dir.FullName -Recurse -File -ErrorAction SilentlyContinue | 
					Measure-Object -Property Length -Sum | 
					Select-Object -ExpandProperty Sum
				
				[PSCustomObject]@{
					Directory = $dir.Name
					FullPath = $dir.FullName
					SizeMB = [math]::Round(($size / 1MB), 2)
					SizeBytes = $size
				}
			}
			catch {
				Write-Warning "Could not calculate size for directory: $($dir.FullName)"
				[PSCustomObject]@{
					Directory = $dir.Name
					FullPath = $dir.FullName
					SizeMB = 0
					SizeBytes = 0
				}
			}
		}
		
		if ($SortBy -eq 'Size') {
			$results | Sort-Object SizeBytes -Descending
		} else {
			$results | Sort-Object Directory
		}
	}
	catch {
		Write-Error "Failed to analyze directory '$Path': $($_.Exception.Message)"
	}
}

function Compress-DirectoriesToArchive {
	<#
	.SYNOPSIS
		Compresses all directories in the current location to 7z archives.
	
	.DESCRIPTION
		Creates a 7z archive for each directory in the current location.
		Optionally deletes the original directories after compression.
	
	.PARAMETER DeleteOriginal
		If specified, deletes the original directories after successful compression.
	
	.PARAMETER Path
		The directory to process. Defaults to current directory.
	
	.EXAMPLE
		Compress-DirectoriesToArchive
		Creates 7z archives for all directories, keeping originals
	
	.EXAMPLE
		zipall $true
		Creates 7z archives and deletes original directories (using alias)
	
	.NOTES
		Available via alias: zipall
		Requires 7-Zip to be installed and available via 'sz' alias.
	#>
	[CmdletBinding(SupportsShouldProcess)]
	param(
		[switch]$DeleteOriginal,
		
		[Parameter(Position = 0)]
		[string]$Path = (Get-Location)
	)
	
	$directories = Get-ChildItem -Path $Path -Directory
	
	foreach ($dir in $directories) {
		$archiveName = "$($dir.Name).7z"
		$archivePath = Join-Path $Path $archiveName
		
		if ($PSCmdlet.ShouldProcess($dir.FullName, "Compress to $archiveName")) {
			try {
				# Use 7-Zip to create archive
				& sz a -t7z $archivePath "$($dir.FullName)\*"
				
				if ($LASTEXITCODE -eq 0) {
					Write-Host "Created archive: $archiveName" -ForegroundColor Green
					
					if ($DeleteOriginal -and $PSCmdlet.ShouldProcess($dir.FullName, "Delete original directory")) {
						Remove-Item -Path $dir.FullName -Recurse -Force
						Write-Host "Deleted original directory: $($dir.Name)" -ForegroundColor Yellow
					}
				} else {
					Write-Error "Failed to create archive for: $($dir.Name)"
				}
			}
			catch {
				Write-Error "Error processing directory '$($dir.Name)': $($_.Exception.Message)"
			}
		}
	}
}

function Find-Files {
	<#
	.SYNOPSIS
		Recursively searches for files matching a pattern.
	
	.DESCRIPTION
		Searches for files recursively from the current or specified directory.
		Supports exact matches or wildcard patterns.
	
	.PARAMETER Pattern
		The search pattern. Will be wrapped with wildcards unless -Exact is specified.
	
	.PARAMETER Exact
		Search for exact filename matches instead of pattern matching.
	
	.PARAMETER Path
		The directory to search from. Defaults to current directory.
	
	.EXAMPLE
		Find-Files "*.log"
		Finds all .log files recursively
	
	.EXAMPLE
		find "config" -Exact
		Finds files named exactly "config" (using alias)
	
	.NOTES
		Available via alias: find
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory, Position = 0)]
		[string]$Pattern,
		
		[switch]$Exact,
		
		[Parameter(Position = 1)]
		[string]$Path = (Get-Location)
	)
	
	if ($Exact) {
		$searchPattern = $Pattern
	} else {
		$searchPattern = "*$Pattern*"
	}
	
	try {
		Get-ChildItem -Path $Path -Include $searchPattern -Recurse -ErrorAction Stop
	}
	catch {
		Write-Error "Search failed: $($_.Exception.Message)"
	}
}

function Invoke-ForEachDirectory {
	<#
	.SYNOPSIS
		Executes a command in each subdirectory of the current location.
	
	.DESCRIPTION
		Changes to each subdirectory and executes the specified command, then returns to the original location.
		Useful for performing operations across multiple project directories.
	
	.PARAMETER Command
		The command or script block to execute in each directory.
	
	.PARAMETER Path
		The parent directory to process. Defaults to current location.
	
	.EXAMPLE
		Invoke-ForEachDirectory "git status"
		Runs git status in each subdirectory
	
	.EXAMPLE
		fed "ls -la"
		Lists contents of each subdirectory using alias
	
	.EXAMPLE
		Invoke-ForEachDirectory { Get-ChildItem *.log | Remove-Item } -Path "C:\Projects"
		Removes log files from each project directory
	
	.NOTES
		Available via alias: fed
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory, Position = 0)]
		[object]$Command,
		
		[Parameter(Position = 1)]
		[string]$Path = (Get-Location)
	)
	
	$originalLocation = Get-Location
	
	try {
		$directories = Get-ChildItem -Path $Path -Directory
		
		foreach ($dir in $directories) {
			try {
				Write-Host "Processing directory: $($dir.Name)" -ForegroundColor Cyan
				Set-Location $dir.FullName
				
				if ($Command -is [scriptblock]) {
					& $Command
				} else {
					Invoke-Expression $Command
				}
			}
			catch {
				Write-Warning "Error processing directory '$($dir.Name)': $($_.Exception.Message)"
			}
			finally {
				Set-Location $originalLocation
			}
		}
	}
	catch {
		Write-Error "Failed to process directories: $($_.Exception.Message)"
	}
	finally {
		Set-Location $originalLocation
	}
}

function Get-FileCrc32 {
	<#
	.SYNOPSIS
		Calculates the CRC32 checksum of a file.
	
	.DESCRIPTION
		Computes the CRC32 checksum of the specified file using the Windows NT native API.
		Useful for file integrity verification and duplicate detection.
	
	.PARAMETER FilePath
		The path to the file to calculate CRC32 for. Supports pipeline input.
	
	.EXAMPLE
		Get-FileCrc32 "document.pdf"
		Returns the CRC32 checksum of document.pdf
	
	.EXAMPLE
		Get-ChildItem *.exe | Get-FileCrc32
		Calculates CRC32 for all exe files in current directory
	
	.EXAMPLE
		crc32 "file.zip"
		Calculate CRC32 using the alias
	
	.NOTES
		Available via alias: crc32
		Author: greg zakharov (original implementation)
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[ValidateScript({ Test-Path $_ })]
		[Alias('FullName')]
		[string]$FilePath
	)
	
	begin {
		# Define the CRC32 calculation type if not already defined
		if (-not ('Crc32.Check' -as [type])) {
			$crcType = Add-Type -TypeDefinition @'
using System;
using System.IO;
using System.Globalization;
using System.Runtime.InteropServices;

namespace Crc32
{
	public class Check
	{
		[DllImport("ntdll.dll")]
		internal static extern UInt32 RtlComputeCrc32(
			UInt32 InitialCrc,
			Byte[] Buffer,
			Int32 Length
		);

		public static String ComputeCrc32(String file) {
			UInt32 crc32 = 0;
			Int32  read;
			Byte[] buf = new Byte[4096];

			using (FileStream fs = File.OpenRead(file)) {
				while ((read = fs.Read(buf, 0, buf.Length)) != 0)
					crc32 = RtlComputeCrc32(crc32, buf, read);
			}

			return ("0x" + crc32.ToString("X", CultureInfo.CurrentCulture));
		}
	}
}
'@ -PassThru
		}
	}
	
	process {
		try {
			$resolvedPath = Resolve-Path $FilePath
			$result = [Crc32.Check]::ComputeCrc32($resolvedPath.Path)
			
			[PSCustomObject]@{
				File = Split-Path $resolvedPath.Path -Leaf
				FullPath = $resolvedPath.Path
				CRC32 = $result
			}
		}
		catch {
			Write-Error "Failed to calculate CRC32 for '$FilePath': $($_.Exception.Message)"
		}
	}
}

# Create aliases for backward compatibility
Set-Alias -Name touch -Value New-TouchFile
Set-Alias -Name zipall -Value Compress-DirectoriesToArchive
Set-Alias -Name find -Value Find-Files
Set-Alias -Name fed -Value Invoke-ForEachDirectory
Set-Alias -Name crc32 -Value Get-FileCrc32
