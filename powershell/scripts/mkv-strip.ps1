function Strip-Mkv-Title() { 
	param(
		[parameter(Mandatory=$true)]
		[String]$filePath
	)
	echo "Stripping title from $filePath"
	mkvpropedit $filePath --edit info --set "title="
}

function Strip-All-Mkvs-In-Directory() {
	param(
		[parameter(Mandatory=$true)]
		[string]$directory
	)
	ls $directory -File -Recurse -Filter "*.mkv" | % {Strip-Mkv-Title $_.FullName}
}

function Remove-All-Subtitles() {
	param(
		[parameter(Mandatory=$true)]
		[String]$filePath
	)
	# TODO: verify the path is valid
	# TODO: only operate on the file if there are subtitle tracks present
	$outputDirectory = Split-Path $filePath
	$outputFilename = [System.IO.Path]::Combine($outputDirectory, [System.IO.Path]::GetFileNameWithoutExtension($filepath) + ".nosubs.mkv")
	echo "Stripping subtitles from $filePath"
	mkvmerge -o $outputFilename --no-subtitles "$filepath"
}

function Remove-All-Subtitles-From-Mkvs-In-Directory() {
	param(
		[parameter(Mandatory=$true)]
		[string]$directory
	)
	ls $directory -File -Recurse -Filter "*.mkv" | % {Remove-All-Subtitles $_.FullName}
}

	# TODO: Test & Implement more cleanup
	# mkvpropedit $filePath --tags all:"" --delete title
function Clean-Mkv() {
	param(
		[parameter(Mandatory=$true)]
		[String]$filePath
	)
	$outputDirectory = Split-Path $filePath
	$outputFilename = [System.IO.Path]::Combine($outputDirectory, [System.IO.Path]::GetFileNameWithoutExtension($filepath) + ".clean.mkv")
	echo "Removing non-English audio and subtitles from $filePath"
	mkvmerge --output $outputFilename -a "eng" -s "eng" "$filePath"
}

function Clean-All-Mkvs-In-Directory() {
	param(
		[parameter(Mandatory=$true)]
		[string]$directory
	)
	ls $directory -File -Recurse -Filter "*.mkv" | % {Clean-Mkv $_.FullName}
}

Set-Alias mkvstrip Strip-Mkv-Title
Set-Alias mkvstripall Strip-All-Mkvs-In-Directory