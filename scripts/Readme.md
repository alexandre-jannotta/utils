# Container
Usefull docker containers

# Profile
```PowerShell
New-Item -ItemType Directory (Split-Path $profile)
New-Item -Path $profile -ItemType SymbolicLink -Value '.\Microsoft.PowerShell_profile.ps1'
```
