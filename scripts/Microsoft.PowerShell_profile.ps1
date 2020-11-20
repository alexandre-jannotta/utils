function prompt {
	$location = Get-Location
	$currentDirectory = Split-Path ($location) -Leaf
	$Host.UI.RawUI.WindowTitle = $location
	"$currentDirectory> "
}

function Set-Env($Name, $Value) {
	New-Item env:\$Name -Value $Value -Force
	[environment]::setEnvironmentVariable($Name, $Value, 'User')
}

function gssh($Name) {
	if (!$Name) {
		Write-Output 'Google SSH configuration...'
		gcloud compute config-ssh
		(Get-Content '~\.ssh\config').replace('HostName', "User ajannotta`n    HostName") | Set-Content '~\.ssh\config'
	} else {
		ssh "$Name.europe-west1-b.ajannotta-labs"
	}
}

function venv($Path) {
	if (!$Path) {
		venv('.venv')
	} else {
		Write-Output "python -m venv $Path"
		python -m venv $Path
	}
}

function activate($Path) {
	if (!$Path) {
		activate('.venv')
	} else {
		# source "$Path/bin/activate"
		Write-Output "$Path\Scripts\activate"
		& "$Path\Scripts\activate"
	}
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

#Set-Location $env:DEV
#$env:YARN_BIN = yarn global bin
#$env:Path = "$env:Path;$env:YARN_BIN"

Set-Alias -Name 'dc' -Value 'docker-compose'
Set-Alias -Name 'd' -Value 'docker'
