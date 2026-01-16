#
# Media Functions
# Functions for media file processing and manipulation
#

function Remove-MkvTitle {
	<#
	.SYNOPSIS
		Removes the title metadata from MKV video files.
	
	.DESCRIPTION
		Uses mkvpropedit to remove title metadata from MKV files. This is useful for
		cleaning up downloaded media files that have unwanted title information.
	
	.PARAMETER FilePath
		The path to the MKV file to process. Supports pipeline input.
	
	.EXAMPLE
		Remove-MkvTitle "movie.mkv"
		Removes title from the specified MKV file
	
	.EXAMPLE
		Get-ChildItem *.mkv | Remove-MkvTitle
		Removes titles from all MKV files in current directory
	
	.NOTES
		Requires mkvtoolnix (mkvpropedit) to be installed and in PATH.
	#>
	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[ValidateScript({ Test-Path $_ })]
		[Alias('FullName')]
		[string]$FilePath
	)
	
	process {
		if (-not (Get-Command mkvpropedit -ErrorAction SilentlyContinue)) {
			Write-Error "mkvpropedit not found. Please install mkvtoolnix."
			return
		}
		
		$resolvedPath = Resolve-Path $FilePath
		
		if ($PSCmdlet.ShouldProcess($resolvedPath.Path, "Remove MKV title metadata")) {
			try {
				Write-Host "Removing title from: $($resolvedPath.Path)" -ForegroundColor Yellow
				& mkvpropedit $resolvedPath.Path --edit info --set "title="
				
				if ($LASTEXITCODE -eq 0) {
					Write-Host "Title removed successfully" -ForegroundColor Green
				} else {
					Write-Error "mkvpropedit failed with exit code: $LASTEXITCODE"
				}
			}
			catch {
				Write-Error "Failed to process '$FilePath': $($_.Exception.Message)"
			}
		}
	}
}

function Remove-MkvTitlesInDirectory {
	<#
	.SYNOPSIS
		Removes title metadata from all MKV files in a directory recursively.
	
	.DESCRIPTION
		Finds all MKV files in the specified directory and subdirectories, then removes
		their title metadata using mkvpropedit.
	
	.PARAMETER Directory
		The directory to process. Defaults to current location.
	
	.PARAMETER NoRecurse
		Process only the specified directory, not subdirectories.

	.EXAMPLE
		Remove-MkvTitlesInDirectory "C:\Movies"
		Removes titles from all MKV files in C:\Movies and subdirectories
	
	.EXAMPLE
		Remove-MkvTitlesInDirectory
		Processes current directory
	
	.NOTES
		Requires mkvtoolnix (mkvpropedit) to be installed and in PATH.
	#>
	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Position = 0)]
		[string]$Directory = (Get-Location),
		[switch]$NoRecurse = $false
	)

	if (-not (Test-Path $Directory)) {
		Write-Error "Directory does not exist: $Directory"
		return
	}
	
	$mkvFiles = Get-ChildItem -Path $Directory -File -Recurse:(-not $NoRecurse) -Filter "*.mkv"
	
	if ($mkvFiles.Count -eq 0) {
		Write-Host "No MKV files found in $Directory" -ForegroundColor Yellow
		return
	}
	
	Write-Host "Found $($mkvFiles.Count) MKV file(s)" -ForegroundColor Cyan
	
	foreach ($file in $mkvFiles) {
		Remove-MkvTitle -FilePath $file.FullName
	}
	
	Write-Host "Processing complete" -ForegroundColor Green
}

function Remove-MkvSubtitles {
	<#
	.SYNOPSIS
		Removes all subtitle tracks from an MKV file.
	
	.DESCRIPTION
		Creates a new MKV file without subtitle tracks using mkvmerge. The original file
		is preserved and a new file with ".nosubs" suffix is created.
	
	.PARAMETER FilePath
		The path to the MKV file to process.
	
	.PARAMETER OutputPath
		Custom output path. If not specified, creates file with ".nosubs" suffix.
	
	.PARAMETER ReplaceOriginal
		Replace the original file with the subtitle-free version.
	
	.EXAMPLE
		Remove-MkvSubtitles "movie.mkv"
		Creates movie.nosubs.mkv without subtitles
	
	.EXAMPLE
		Remove-MkvSubtitles "movie.mkv" -ReplaceOriginal
		Removes subtitles and replaces the original file
	
	.NOTES
		Requires mkvtoolnix (mkvmerge) to be installed and in PATH.
	#>
	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory, Position = 0)]
		[ValidateScript({ Test-Path $_ })]
		[string]$FilePath,
		
		[Parameter(Position = 1)]
		[string]$OutputPath,
		
		[switch]$ReplaceOriginal
	)
	
	if (-not (Get-Command mkvmerge -ErrorAction SilentlyContinue)) {
		Write-Error "mkvmerge not found. Please install mkvtoolnix."
		return
	}
	
	$resolvedPath = Resolve-Path $FilePath
	$directory = Split-Path $resolvedPath.Path
	$baseName = [System.IO.Path]::GetFileNameWithoutExtension($resolvedPath.Path)
	
	if (-not $OutputPath) {
		if ($ReplaceOriginal) {
			$OutputPath = Join-Path $directory "$baseName.temp.mkv"
		} else {
			$OutputPath = Join-Path $directory "$baseName.nosubs.mkv"
		}
	}
	
	if ($PSCmdlet.ShouldProcess($resolvedPath.Path, "Remove subtitle tracks")) {
		try {
			Write-Host "Removing subtitles from: $($resolvedPath.Path)" -ForegroundColor Yellow
			& mkvmerge -o $OutputPath --no-subtitles $resolvedPath.Path
			
			if ($LASTEXITCODE -eq 0) {
				Write-Host "Subtitles removed successfully" -ForegroundColor Green
				
				if ($ReplaceOriginal) {
					Move-Item $OutputPath $resolvedPath.Path -Force
					Write-Host "Original file replaced" -ForegroundColor Green
				} else {
					Write-Host "Output saved to: $OutputPath" -ForegroundColor Cyan
				}
			} else {
				Write-Error "mkvmerge failed with exit code: $LASTEXITCODE"
				if (Test-Path $OutputPath) {
					Remove-Item $OutputPath -Force
				}
			}
		}
		catch {
			Write-Error "Failed to process '$FilePath': $($_.Exception.Message)"
			if (Test-Path $OutputPath) {
				Remove-Item $OutputPath -Force
			}
		}
	}
}

# No aliases needed for these functions as they're quite specific
