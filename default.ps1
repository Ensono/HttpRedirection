Task default -Depends Test

Task BuildOutputDirectory -PreCondition { -Not (Test-Path '.\build\output') } {
  New-Item -Path '.\build\output' -Type Container -Force | Out-Null;
}

Task Test -Depends BuildOutputDirectory {  
  Get-Module -Name Pester | Remove-Module;
  Import-Module '.\build\modules\Pester\Pester.psd1';
  Invoke-Pester -OutputFile 'build/output/Test-Results.xml' -OutputFormat NUnitXml -ExcludeTag 'Integration' ".\src\";
}

Task UpdateVersion -PreCondition { Test-Path Env:\APPVEYOR_BUILD_NUMBER } {
  if (Test-Path '.\src\HttpRedirection-temp.psd1') {
    Remove-Item '.\src\HttpRedirection-temp.psd1' -Force | Out-Null;
  }

  Get-Content .\src\HttpRedirection.psd1 `
    | ForEach-Object { 
      if ($_.Contains('ModuleVersion = ')) {
        "ModuleVersion = '1.1.0.{0}'" -f $env:APPVEYOR_BUILD_NUMBER;
      } else {
        $_
      }
    } | Out-File -Append .\src\HttpRedirection-temp.psd1;

  Remove-Item '.\src\HttpRedirection.psd1';
  Move-Item '.\src\HttpRedirection-temp.psd1' '.\src\HttpRedirection.psd1';
}

Task Package -Depends Test, BuildOutputDirectory, UpdateVersion {
  $SourceDirectory = Resolve-Path '.\src\';
  $PackageFile = '{0}/build/output/HttpRedirection.zip' -f $PSScriptRoot;
  if (Test-Path $PackageFile) {
    Remove-Item $PackageFile;
  }
  Add-Type -Assembly 'System.IO.Compression.FileSystem';
  [System.IO.Compression.ZipFile]::CreateFromDirectory([string]$SourceDirectory, $PackageFile);
}