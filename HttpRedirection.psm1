# Dynamically populate the module ignore any Pester test fixtures.
$functions = Get-ChildItem -Recurse "$PSScriptRoot\cmdlets" -Include *.ps1 | Where-Object { $_ -notmatch ".Tests.ps1" }

# dot source the individual scripts that make-up this module
foreach ($function in $functions) { . $function.FullName }

Write-Host -ForegroundColor Green "Module $(Split-Path $PSScriptRoot -Leaf) was successfully loaded."
