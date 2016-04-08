function For-EachDirectory() { 
	param(
		[parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
		[String]$commands
	)
	ls -Directory | % { pushd $_; Invoke-Expression $commands; popd }
}

Set-Alias fed For-EachDirectory