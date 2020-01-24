
$sourceDir = '.\certificates'
$targetBundleFile = 'bundle.crt'
$targetKeystoreFile = 'jssecacerts'
$keystorePassword = 'changeit'

#Remove-Item $targetBundleFile -ErrorAction Ignore
Clear-Content $targetBundleFile

# find existing aliases
$aliases = @{}
keytool -list -v -keystore $targetKeystoreFile -storepass $keystorePassword |
Select-String 'Alias name: ' |
ForEach-Object {
    $alias = $_.ToString().Substring(12)
    $aliases.Add($alias, $true)
}

# for each certificates in directory
Get-ChildItem -Path $sourceDir | 
ForEach-Object {
    $alias = $_.BaseName
    Write-Debug "Certificate '$($_.Name)'"
    
    Write-Debug "    Copy into $targetBundleFile"
    Get-Content $_.FullName |
    Out-File $targetBundleFile -Append
    
    if ($aliases.ContainsKey($alias)) {
        Write-Debug "    Already existing in '$targetKeystoreFile'"
        $aliases.Remove($alias)
    } else {
        Write-Debug "    Importing into '$targetKeystoreFile'"
        keytool -import -keystore $targetKeystoreFile -storepass $keystorePassword -file $_.FullName -alias $alias -noprompt
    }
}

# remove deprecated certificates
foreach($alias in $aliases.Keys) {
    Write-Debug "Deleting '$alias' from '$targetKeystoreFile'"
    keytool -delete -keystore $targetKeystoreFile -storepass $keystorePassword -alias $alias
}
