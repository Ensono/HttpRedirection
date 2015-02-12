# Dynamically populate the module, ignore any Pester test fixtures.
$functions = Get-ChildItem -Recurse "$PSScriptRoot\cmdlets" -Include *.ps1 | Where-Object { $_ -notmatch ".Tests.ps1" }

# dot source the individual scripts that make-up this module
foreach ($function in $functions) { . $function.FullName }

# Dynamically populate the aliases, ignore any Pester test fixtures.
$aliases = Get-ChildItem -Recurse "$PSScriptRoot\aliases" -Include *.ps1 | Where-Object { $_ -notmatch ".Tests.ps1" }

# dot source the individual aliases that make-up this module
foreach ($alias in $aliases) { . $alias.FullName }

# export the module members
Export-ModuleMember -Function * -Alias *

# Win!
Write-Host -ForegroundColor Green "Http Redirection Module was successfully loaded."
Write-Host -ForegroundColor Green "(c) 2014-$((Get-Date).Year) Amido Limited, All Rights Reserved."