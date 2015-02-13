Task default -Depends Test

Task Test {
  Get-Module -Name Pester | Remove-Module;
  Import-Module ".\build\modules\Pester\Pester.psd1";
  Invoke-Pester -ExcludeTag 'Integration' ".\src\";
}

Task Package -Depends Test{
  $SourceDirectory = Resolve-Path '.\src\';
  $PackageFile = "{0}/HttpRedirection.zip" -f $PSScriptRoot;
  if (Test-Path $PackageFile) {
    Remove-Item $PackageFile;
  }
  Add-Type -Assembly "System.IO.Compression.FileSystem";
  [System.IO.Compression.ZipFile]::CreateFromDirectory([string]$SourceDirectory, $PackageFile);
}