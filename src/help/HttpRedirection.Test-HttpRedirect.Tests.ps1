$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
. "$here\..\cmdlets\Trace-HttpRedirect.ps1";

Describe "Trace-HttpRedirect Contains Appropiate Help" {
	It "does not contain any TODO items in basic help" {
    $help = Get-Help Trace-HttpRedirect;
    $help | Out-String -Stream | Select-String "TODO" | Measure-Object | Select-Object -ExpandProperty Count | Should Be 0;
	}

  It "does not contain any TODO items in examples" {
    $help = Get-Help Trace-HttpRedirect;
    $help | Out-String -Stream | Select-String "TODO" | Measure-Object | Select-Object -ExpandProperty Count | Should Be 0;
  }

  It "contains two examples" {
    $help = Get-Help Trace-HttpRedirect -Examples;
    $help.examples.example.Count | Should Be 2;
  }

  It "does not contain any TODO items in parameters" {
    $help = Get-Help Trace-HttpRedirect;
    $help.Parameters | Out-String -Stream | Select-String "TODO" | Measure-Object | Select-Object -ExpandProperty Count | Should Be 0;
  }

  It "contains three parameters" {
    $help = Get-Help Trace-HttpRedirect;
    $help.Parameters.parameter.Count | Should Be 3;
  }
}