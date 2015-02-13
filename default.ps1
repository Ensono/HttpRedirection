Task default -Depends Test

Task BuildOutputDirectory -PreCondition { -Not (Test-Path '.\build\output') } {
  New-Item -Path '.\build\output' -Type Container;
}

Task Test -Depends BuildOutputDirectory {  
  Get-Module -Name Pester | Remove-Module;
  Import-Module '.\build\modules\Pester\Pester.psd1';
  Invoke-Pester -OutputFile 'build/output/Test-Results.xml' -OutputFormat NUnitXml -ExcludeTag 'Integration' ".\src\";
}

Task Package -Depends Test, BuildOutputDirectory {
  $SourceDirectory = Resolve-Path '.\src\';
  $PackageFile = '{0}/build/output/HttpRedirection.zip' -f $PSScriptRoot;
  if (Test-Path $PackageFile) {
    Remove-Item $PackageFile;
  }
  Add-Type -Assembly 'System.IO.Compression.FileSystem';
  [System.IO.Compression.ZipFile]::CreateFromDirectory([string]$SourceDirectory, $PackageFile);
}