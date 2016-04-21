function Block-Host() { 
	param(
		[parameter(Mandatory=$true)]
		[String]$url
	)
	$hostsPath = "$env:windir\system32\drivers\etc\hosts"
	if ((sls -Pattern $url -Path $hostspath).count -eq 0){
		ac -Path $hostsPath -Value "`r`n0.0.0.0 $url" -NoNewline
		echo "Blocked $url"
	}
	else{
		echo "$url already present in hosts file"
	}
}

Set-Alias block Block-Host