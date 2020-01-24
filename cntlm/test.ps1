function FindConfig($configName) {
	if ($configName) {
		return "$configSourceDirectory\$configName.ini"
	}
	else {
		$configSourceFiles = Get-ChildItem -Path $configSourceDirectory
		return (Choose -Elements $configSourceFiles).FullName
	}
}

function Choose($elements) {
	Write-Host 'Elements:'
	$index = 0
	$elements | ForEach-Object {
		Write-Host "    [$index] $_"
		$index++
	}
	$index = Read-Host 'Please choose one'

	if ($index -lt 0 -or $index -ge $elements.Length) {
		Write-Error "'$index' : Is not a valid index"
		exit
	}

	return $elements[$index]
}

$directory = [io.path]::GetDirectoryName($MyInvocation.MyCommand.Source)

$runFile = "$directory\run.ps1"
$exeFile = "$directory\cntlm-0.92.3\cntlm.exe"
$configDefault = "$directory\default.ini"
$configSourceDirectory = "$directory\config-source"
$configTargetDirectory = "$directory\config-target"
$shortcutDirectory = "$directory\shortcuts"

$configSource = FindConfig $args[0]
$configName = [io.path]::GetFileNameWithoutExtension($configSource)
$configTarget = "$configTargetDirectory\$configName.ini"
$configShortcut = "$shortcutDirectory\$configName.lnk"

Write-Host '######################'
Write-Host "$configName : $configSource > $configTarget"
Write-Host '######################'
$password = Read-Host 'Password' -AsSecureString
Write-Host '######################'

$password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
$result = Write-Output $password | & $exeFile -c $configSource -M 'https://google.fr' | Out-String

Write-Host '######################'
Write-Host $result
Write-Host '######################'

$regex = '(?sm)[\-]+\[[ a-zA-Z0-9]+\][\-]+([^\-]+)[\-]+'
$match = [regex]::Matches($result, $regex)

if ($match.Success) {
	Write-Host $result.getType()
	Write-Host $match.getType()
	Write-Host '######################'

	$value = $match.Groups[1].Value

	Write-Host $value
	Write-Host '######################'
	Write-Host 'Success'

	Copy-Item $configSource $configTarget
	Add-Content $configTarget $value
	Get-Content $configDefault | Add-Content $configTarget

	$WScriptShell = New-Object -comObject WScript.Shell
	$Shortcut = $WScriptShell.CreateShortcut($configShortcut)
	$Shortcut.TargetPath = "powershell.exe"
	$Shortcut.Arguments = "-ExecutionPolicy Bypass -File ""$runFile"" $configName"
	$Shortcut.WorkingDirectory = $directory
	$Shortcut.Save()
}
else {
	Write-Error 'Failure'
	Pause
}
