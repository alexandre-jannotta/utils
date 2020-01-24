function prompt {
	$location = Get-Location
	$currentDirectory = Split-Path ($location) -Leaf
	$Host.UI.RawUI.WindowTitle = $location
	"$currentDirectory> "
}

# Ssl
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Encoding
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$OutputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::UTF8

# Proxy
if ($env:HTTP_PROXY) {
	Write-Host 'Proxy'
	[net.webrequest]::defaultwebproxy.credentials = [net.credentialcache]::defaultcredentials
}
else {
	Write-Host 'No proxy'
}

Set-PSReadlineOption -BellStyle None

Set-Location $env:DEV
