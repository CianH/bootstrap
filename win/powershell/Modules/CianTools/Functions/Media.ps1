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
		Removes non-English subtitle tracks from an MKV file.
	
	.DESCRIPTION
		Creates a new MKV file keeping only English subtitle tracks using mkvmerge.
		Useful for cleaning up media files with many unwanted subtitle languages.
		Unknown/undefined language tracks are kept by default with a warning.
	
	.PARAMETER FilePath
		The path to the MKV file to process.
	
	.PARAMETER KeepLanguages
		Languages to keep. Defaults to @('eng', 'en'). Unknown tracks are always kept with a warning.
	
	.PARAMETER ReplaceOriginal
		Replace the original file with the processed version.
	
	.PARAMETER RemoveUnknown
		Also remove tracks with unknown/undefined language. By default these are kept.
	
	.EXAMPLE
		Remove-MkvSubtitles "movie.mkv"
		Removes non-English subtitles, creates movie.ensubs.mkv
	
	.EXAMPLE
		Remove-MkvSubtitles "movie.mkv" -ReplaceOriginal
		Removes non-English subtitles and replaces the original file
	
	.EXAMPLE
		Remove-MkvSubtitles "movie.mkv" -KeepLanguages @('eng', 'spa')
		Keeps only English and Spanish subtitles
	
	.EXAMPLE
		Remove-MkvSubtitles "movie.mkv" -RemoveUnknown
		Removes non-English subtitles including tracks with unknown language
	
	.NOTES
		Requires mkvtoolnix (mkvmerge) to be installed and in PATH.
	#>
	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[ValidateScript({ Test-Path $_ })]
		[Alias('FullName')]
		[string]$FilePath,
		
		[Parameter()]
		[string[]]$KeepLanguages = @('eng', 'en'),
		
		[switch]$ReplaceOriginal,
		
		[switch]$RemoveUnknown
	)
	
	process {
		if (-not (Get-Command mkvmerge -ErrorAction SilentlyContinue)) {
			Write-Error "mkvmerge not found. Please install mkvtoolnix."
			return
		}
		
		$resolvedPath = Resolve-Path $FilePath
		$directory = Split-Path $resolvedPath.Path
		$baseName = [System.IO.Path]::GetFileNameWithoutExtension($resolvedPath.Path)
		
		# Get track info
		$trackInfo = & mkvmerge -J $resolvedPath.Path | ConvertFrom-Json
		$subTracks = $trackInfo.tracks | Where-Object { $_.type -eq 'subtitles' }
		
		if ($subTracks.Count -eq 0) {
			Write-Host "No subtitle tracks found in: $($resolvedPath.Path)" -ForegroundColor Yellow
			return
		}
		
		# Identify unknown language tracks
		$unknownTracks = $subTracks | Where-Object {
			$lang = $_.properties.language
			$langIetf = $_.properties.language_ietf
			(-not $lang -or $lang -eq 'und' -or $lang -eq '') -and (-not $langIetf -or $langIetf -eq 'und' -or $langIetf -eq '')
		}
		
		# Find tracks to keep (requested languages)
		$keepTrackIds = @($subTracks | Where-Object { 
			$_.properties.language -in $KeepLanguages -or 
			$_.properties.language_ietf -in $KeepLanguages 
		} | ForEach-Object { $_.id })
		
		# Handle unknown tracks
		if ($unknownTracks.Count -gt 0) {
			if ($RemoveUnknown) {
				Write-Warning "Removing $($unknownTracks.Count) track(s) with unknown language"
			} else {
				Write-Warning "Keeping $($unknownTracks.Count) track(s) with unknown language (use -RemoveUnknown to remove)"
				$keepTrackIds += $unknownTracks | ForEach-Object { $_.id }
			}
		}
		
		# Deduplicate
		$keepTrackIds = $keepTrackIds | Select-Object -Unique
		
		if ($keepTrackIds.Count -eq $subTracks.Count) {
			Write-Host "All subtitle tracks are already in requested languages: $($resolvedPath.Path)" -ForegroundColor Green
			return
		}
		
		if ($keepTrackIds.Count -eq 0) {
			Write-Warning "No subtitle tracks match requested languages. All subtitles would be removed."
			return
		}
		
		$outputPath = if ($ReplaceOriginal) {
			Join-Path $directory "$baseName.temp.mkv"
		} else {
			Join-Path $directory "$baseName.ensubs.mkv"
		}
		
		if ($PSCmdlet.ShouldProcess($resolvedPath.Path, "Remove non-English subtitle tracks")) {
			try {
				Write-Host "Keeping $($keepTrackIds.Count) of $($subTracks.Count) subtitle tracks from: $($resolvedPath.Path)" -ForegroundColor Yellow
				$subTrackArg = ($keepTrackIds -join ',')
				& mkvmerge -o $outputPath --subtitle-tracks $subTrackArg $resolvedPath.Path
				
				if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq 1) {
					Write-Host "Non-English subtitles removed successfully" -ForegroundColor Green
					
					if ($ReplaceOriginal) {
						Move-Item $outputPath $resolvedPath.Path -Force
						Write-Host "Original file replaced" -ForegroundColor Green
					} else {
						Write-Host "Output saved to: $outputPath" -ForegroundColor Cyan
					}
				} else {
					Write-Error "mkvmerge failed with exit code: $LASTEXITCODE"
					if (Test-Path $outputPath) { Remove-Item $outputPath -Force }
				}
			}
			catch {
				Write-Error "Failed to process '$FilePath': $($_.Exception.Message)"
				if (Test-Path $outputPath) { Remove-Item $outputPath -Force }
			}
		}
	}
}

function Export-MkvSubtitles {
	<#
	.SYNOPSIS
		Extracts subtitle tracks from an MKV file to external sidecar files.
	
	.DESCRIPTION
		Extracts embedded subtitles from MKV files and saves them as external files
		with proper language codes (e.g., "Movie.en.srt", "Movie.es.srt").
	
	.PARAMETER FilePath
		The path to the MKV file to process.
	
	.PARAMETER Languages
		Languages to extract. If not specified, extracts all subtitles.
		Use language codes like 'eng', 'spa', 'fre', etc.
	
	.PARAMETER OutputDirectory
		Directory for extracted subtitles. Defaults to same directory as source.
	
	.EXAMPLE
		Export-MkvSubtitles "MyMovie (2016).mkv"
		Extracts all subtitles, e.g., "MyMovie (2016).en.srt"
	
	.EXAMPLE
		Export-MkvSubtitles "movie.mkv" -Languages @('eng', 'spa')
		Extracts only English and Spanish subtitles
	
	.EXAMPLE
		Get-ChildItem *.mkv | Export-MkvSubtitles
		Extracts subtitles from all MKV files in current directory
	
	.NOTES
		Requires mkvtoolnix (mkvmerge, mkvextract) to be installed and in PATH.
		Subtitle format in output matches source (SRT stays SRT, ASS stays ASS, etc.)
	#>
	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[ValidateScript({ Test-Path $_ })]
		[Alias('FullName')]
		[string]$FilePath,
		
		[Parameter()]
		[string[]]$Languages,
		
		[Parameter()]
		[string]$OutputDirectory
	)
	
	process {
		if (-not (Get-Command mkvmerge -ErrorAction SilentlyContinue)) {
			Write-Error "mkvmerge not found. Please install mkvtoolnix."
			return
		}
		if (-not (Get-Command mkvextract -ErrorAction SilentlyContinue)) {
			Write-Error "mkvextract not found. Please install mkvtoolnix."
			return
		}
		
		$resolvedPath = Resolve-Path $FilePath
		$directory = if ($OutputDirectory) { $OutputDirectory } else { Split-Path $resolvedPath.Path }
		$baseName = [System.IO.Path]::GetFileNameWithoutExtension($resolvedPath.Path)
		
		# Get track info as JSON
		$trackInfo = & mkvmerge -J $resolvedPath.Path | ConvertFrom-Json
		$subTracks = $trackInfo.tracks | Where-Object { $_.type -eq 'subtitles' }
		
		if ($subTracks.Count -eq 0) {
			Write-Host "No subtitle tracks found in: $($resolvedPath.Path)" -ForegroundColor Yellow
			return
		}
		
		# Filter by language if specified
		if ($Languages) {
			$subTracks = $subTracks | Where-Object {
				$_.properties.language -in $Languages -or
				$_.properties.language_ietf -in $Languages
			}
			if ($subTracks.Count -eq 0) {
				Write-Host "No subtitle tracks match requested languages in: $($resolvedPath.Path)" -ForegroundColor Yellow
				return
			}
		}
		
		Write-Host "Found $($subTracks.Count) subtitle track(s) in: $($resolvedPath.Path)" -ForegroundColor Cyan
		
		# Map codec to file extension
		$codecExtensions = @{
			'SubRip/SRT' = 'srt'
			'SubStationAlpha' = 'ass'
			'HDMV PGS' = 'sup'
			'VobSub' = 'sub'
			'WebVTT' = 'vtt'
		}
		
		foreach ($track in $subTracks) {
			$trackId = $track.id
			$lang = if ($track.properties.language_ietf) { 
				# Use IETF tag, convert to 2-letter if possible
				$ietf = $track.properties.language_ietf
				if ($ietf -match '^([a-z]{2})') { $Matches[1] } else { $ietf }
			} elseif ($track.properties.language -and $track.properties.language -ne 'und') {
				# Convert 3-letter to 2-letter codes for common languages
				$langMap = @{ 'eng'='en'; 'spa'='es'; 'fre'='fr'; 'fra'='fr'; 'ger'='de'; 'deu'='de'; 
				              'ita'='it'; 'por'='pt'; 'rus'='ru'; 'jpn'='ja'; 'chi'='zh'; 'zho'='zh';
				              'kor'='ko'; 'ara'='ar'; 'hin'='hi'; 'dut'='nl'; 'nld'='nl'; 'pol'='pl' }
				$threeLetter = $track.properties.language
				if ($langMap.ContainsKey($threeLetter)) { $langMap[$threeLetter] } else { $threeLetter }
			} else {
				"track$trackId"
			}
			
			# Handle track name for forced/SDH indicators
			$trackName = $track.properties.track_name
			$suffix = ""
			if ($track.properties.forced_track) { $suffix = ".forced" }
			elseif ($trackName -match 'SDH|CC|Hearing') { $suffix = ".sdh" }
			
			# Determine extension from codec
			$codec = $track.codec
			$ext = 'srt'  # default
			foreach ($key in $codecExtensions.Keys) {
				if ($codec -match $key) { $ext = $codecExtensions[$key]; break }
			}
			
			$outputFile = Join-Path $directory "$baseName.$lang$suffix.$ext"
			
			# Handle duplicates
			$counter = 2
			while (Test-Path $outputFile) {
				$outputFile = Join-Path $directory "$baseName.$lang$suffix.$counter.$ext"
				$counter++
			}
			
			if ($PSCmdlet.ShouldProcess($outputFile, "Extract subtitle track $trackId ($lang)")) {
				try {
					Write-Host "  Extracting track $trackId ($lang) -> $(Split-Path $outputFile -Leaf)" -ForegroundColor Yellow
					& mkvextract tracks $resolvedPath.Path "${trackId}:${outputFile}"
					
					if ($LASTEXITCODE -eq 0) {
						Write-Host "  Extracted: $(Split-Path $outputFile -Leaf)" -ForegroundColor Green
					} else {
						Write-Warning "  Failed to extract track $trackId (exit code: $LASTEXITCODE)"
					}
				}
				catch {
					Write-Error "  Failed to extract track $trackId`: $($_.Exception.Message)"
				}
			}
		}
	}
}

# No aliases needed for these functions as they're quite specific
