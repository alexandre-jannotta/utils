$prefix = 'Microsoft.PowerShell.Core\FileSystem::\\wsl$\Ubuntu'
$dev = '\\wsl$\Ubuntu\home\wlmitch\dev'

function prompt {
	[string] $location = Get-Location
	if ($location.StartsWith($prefix)) {
		$location = $location.Substring($prefix.Length).Replace('\', '/')
		$dev = 'C:\dev'
	} else {
		$dev = '\\wsl$\Ubuntu\home\wlmitch\dev'
	}
	$currentDirectory = Split-Path ($location) -Leaf

	$Host.UI.RawUI.WindowTitle = $location
	"$currentDirectory> "
}

function dev {
	Write-Output "Moving to: $dev"
	Set-Location $dev
}

function Set-Env($Name, $Value) {
	New-Item env:\$Name -Value $Value -Force
	[environment]::setEnvironmentVariable($Name, $Value, 'User')
}

function gssh($Name) {
	if (!$Name) {
		Write-Output 'Google SSH configuration...'
		gcloud compute config-ssh
		(Get-Content '~\.ssh\config').replace('HostName', "User ajannotta`n    ForwardAgent=yes`n    HostName") | Set-Content '~\.ssh\config'
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

Set-PSReadlineOption -BellStyle None

Set-Alias -Name 'dc' -Value 'docker-compose'
Set-Alias -Name 'd' -Value 'docker'
Set-Alias -Name 'gcl' -Value 'gcloud'
Set-Alias -Name 'gcp' -Value 'gcloud'
