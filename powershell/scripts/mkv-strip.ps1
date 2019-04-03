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

Set-Alias mkvstrip Strip-Mkv-Title
Set-Alias mkvstripall Strip-All-Mkvs-In-Directory