# Set-ExecutionPolicy RemoteSigned -scope CurrentUser -Force
# Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/alexandre-jannotta/utils/master/scripts/install.ps1')

function Set-Env($Name, $Value) {
	New-Item env:\$Name -Value $Value -Force
	[environment]::setEnvironmentVariable($Name, $Value, 'User')
}

function Get-Response($Uri) {
	try {
		$request = [System.Net.WebRequest]::Create($Uri)
		$request.Method = 'HEAD'
		return $request.GetResponse()
	}
	catch [Net.WebException] {
		Write-Error $_.Exception.Message
		return $_.Exception.Response
	}
}

function SetupConnection {
	Write-Host 'Setup connection'
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	
	$response = Get-Response -Uri 'https://github.com'
	switch ([int]$response.StatusCode) {
		200 { Write-Host 'Connected' }
		407 {
			Write-Host 'Authentication required, configuring default credentials'
			[net.webrequest]::defaultwebproxy.credentials = [net.credentialcache]::defaultcredentials
		}
		Default { Write-Host 'Disconnected' }
	}
}

function SetupEnv {
	Write-Host 'Setup env'

	Set-Env -Name 'DEV' -Value $PWD
	Set-Env -Name 'SCOOP' -Value "$env:DEV\scoop"
	Set-Env -Name 'SCOOP_GLOBAL' -Value "$env:ProgramData\scoop"
	Set-Env -Name 'XDG_CONFIG_HOME' -Value "$env:DEV\.config"

	$env:pathDocuments = [Environment]::GetFolderPath("MyDocuments")
	$env:pathDesktop = [Environment]::GetFolderPath("Desktop")

	$env:pathUtils = "$env:DEV\utils2"
	$env:pathCntlm = "$env:pathUtils\cntlm"
	$env:pathShorcuts = "$env:pathCntlm\shortcuts"
}

function DirectoryExists($Path) {
	return (Test-Path $Path) -and (Get-Item $Path) -is [System.IO.DirectoryInfo]
}
function FileExists($Path) {
	return (Test-Path $Path) -and (Get-Item $Path) -is [System.IO.FileInfo]
}

function InstallScoop {
	Write-Host 'Install scoop'

	if (DirectoryExists $env:SCOOP) {
		Write-Host 'Already installed'
	}
	else {
		Set-ExecutionPolicy RemoteSigned -scope CurrentUser -Force
		Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
	}

	## Packages
	scoop install 7zip git concfg sudo innounp dark
	## Config
	Start-Process -FilePath powershell.exe -ArgumentList {
		Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1
		Add-MpPreference -ExclusionPath $env:SCOOP
		Add-MpPreference -ExclusionPath $env:SCOOP_GLOBAL
	} -verb RunAs
	## Theme
	concfg import -n vs-code-dark-plus
}

function InstallTools {
	Write-Host 'Install tools'

	scoop install nodejs maven python
	scoop bucket add java
	scoop install ojdkbuild11 ojdkbuild13
}

function InstallUtils {
	Write-Host 'Install utils'

	if (DirectoryExists $env:pathUtils) {
		Push-Location $env:pathUtils
		git pull --ff
		Pop-Location
	}
	else {
		$Uri = 'https://github.com/alexandre-jannotta/utils/archive/master.zip'
		Invoke-WebRequest -Uri $Uri -OutFile "$env:DEV\utils.zip"
		7z x .\utils.zip "-o$env:pathUtils" -y
		Move-Item "$env:pathUtils\utils-master\*" $env:pathUtils
		Remove-Item "$env:DEV\utils.zip"
		Remove-Item "$env:pathUtils\utils-master"
	}

	# Profile
	$profilePath = "$env:DEV\utils\scripts\Microsoft.PowerShell_profile.ps1"
	if (-not (FileExists $profilePath)) {
		New-Item -ItemType HardLink -Path "$env:pathDocuments\WindowsPowerShell" -Name 'Microsoft.PowerShell_profile.ps1' -Target $profilePath
	}
	# Ctnlm
	Copy-Item "$env:pathShorcuts\test.lnk" $env:pathDesktop
	Copy-Item "$env:pathShorcuts\none.lnk" $env:pathDesktop
	Copy-Item "$env:pathShorcuts\cntlm.lnk" $env:pathDesktop
	Copy-Item "$env:pathShorcuts\run.lnk" $env:pathDesktop
}

function SetupProxy {
	Write-Host 'Setup proxy'

	
	$proxy = Read-Host 'Proxy'
	
	if ($proxy) {
		Out-File -FilePath "$env:pathCntlm\config-source\default.ini" -InputObject "
Proxy		$proxy
Domain		$env:USERDOMAIN
Username	$env:USERNAME"

		& $env:pathCntlm\test.ps1 'default'

		Set-Env -Name 'HTTP_PROXY' -Value 'http://localhost:3128'
		Set-Env -Name 'HTTPS_PROXY' -Value 'http://localhost:3128'

		Copy-Item "$env:pathShorcuts\default.lnk" $env:pathDesktop

		& $env:pathCntlm\run.ps1 'default'
	}
}

function SyncUtils {
	$env:pathUtils = "$env:DEV\utils2"

	git clone --bare 'https://github.com/alexandre-jannotta/utils' "$env:pathUtils\.git"
	Push-Location $env:pathUtils
	git config --bool core.bare false
	git add *
}

SetupEnv
SetupConnection
InstallScoop
InstallUtils
SetupProxy
InstallTools
