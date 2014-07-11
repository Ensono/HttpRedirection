$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
. "$here\..\cmdlets\Trace-HttpRedirect.ps1";
Update-FormatData "$here.\HttpRedirection.format.ps1xml";

function Get-Fields ([string[]]$lines) {
  $fields = New-Object System.Collections.Generic.List``1[String];
  $buffer = [String]::Empty;
  for ($i = 0; $i -le $lines[2].Length; $i++) {
    if ($lines[2][$i] -eq '-') {
      $buffer += [string]$lines[1][$i];
    } else {
      if (![String]::IsNullOrWhiteSpace($buffer)) {
        $fields.Add($buffer) | Out-Null;
        $buffer = [String]::Empty;
      }
    }
  }

  $fields;
}

Describe "Format Trace-HttpRedirect when Target URL returns 200-OK" {
  Mock -Verifiable -CommandName Invoke-WebRequest `
    -ParameterFilter { ($Uri -eq "http://final.site.test/") -And ($MaximumRedirection -eq 0) } `
    -MockWith { [String]::Empty | Select-Object @{ Name="StatusCode"; Expression={ "200" } }, @{ Name="StatusDescription"; Expression={ "OK" } } };

	It "includes Redirect in the output" {
    $output = Trace-HttpRedirect -Uri "http://final.site.test/";
    $lines = $output | Out-String -Stream;
    (Get-Fields $lines)[0] | Should Be "Redirect";  
	}

  It "includes Code in the output" {
    $output = Trace-HttpRedirect -Uri "http://final.site.test/";
    $lines = $output | Out-String -Stream;
    (Get-Fields $lines)[1] | Should Be "Code";  
  }

  It "includes Description in the output" {
    $output = Trace-HttpRedirect -Uri "http://final.site.test/";
    $lines = $output | Out-String -Stream;
    (Get-Fields $lines)[2] | Should Be "Description";  
  }

  It "includes Target URL in the output" {
    $output = Trace-HttpRedirect -Uri "http://final.site.test/";
    $lines = $output | Out-String -Stream;
    (Get-Fields $lines)[3] | Should Be "Target URL";  
  }

  It "has a Redirect value of 1" {
    $output = Trace-HttpRedirect -Uri "http://final.site.test/";
    $lines = $output | Out-String -Stream;
    $lines[3].Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)[0] | Should Be "1";
  }

  It "has a HTTP Status Code value of 200" {
    $output = Trace-HttpRedirect -Uri "http://final.site.test/";
    $lines = $output | Out-String -Stream;
    $lines[3].Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)[1] | Should Be "200";
  }

  It "has a HTTP Status Code Description value of OK" {
    $output = Trace-HttpRedirect -Uri "http://final.site.test/";
    $lines = $output | Out-String -Stream;
    $lines[3].Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)[2] | Should Be "OK";
  }
}