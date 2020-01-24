function FindConfig() {
    param($configName)

    if ($configName) {
        return "$configTargetDirectory\$configName.ini"
    } else {
        $configTargetFiles = Get-ChildItem -Path $configTargetDirectory
        return (Choose -Elements $configTargetFiles).FullName
    }
}

function Choose {
    param ($elements)

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
$exeFile = "$directory\cntlm-0.92.3\cntlm.exe"
$configTargetDirectory = "$directory\config-target"
$configTarget = FindConfig $args[0]

& $exeFile -c $configTarget -v
