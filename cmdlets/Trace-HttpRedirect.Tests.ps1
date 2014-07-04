$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".");
$mockTable = @{};
. "$here\$sut"

Mock -Verifiable -CommandName Invoke-WebRequest `
  -ParameterFilter { ($Uri -eq "http://final.site.test/") -And ($MaximumRedirection -eq 0) } `
  -MockWith { return Select-Object @{ Name="StatusCode"; Expression="200" }, @{ Name="StatusDescription"; Expression="OK" } };

Describe "Trace-HttpRedirection calls to URL which returns a 200-OK." {
	It "Returns a single object." {
		$output = Trace-HttpRedirect -Uri "http://final.site.test/";
    $output | Measure-Object | Select-Object -ExpandProperty Count | Should Be 1;
	}

	It "Returns the redirect number equal to 1." {
		$output = Trace-HttpRedirect -Uri "http://final.site.test/";
    $output.PSObject.Properties.Match("Redirect").Count | Should Be 1;
    $output.Redirect | Should Be 1;
	}

	It "Returns the status code set to 200." {
		$output = Trace-HttpRedirect -Uri "http://final.site.test/";
    $output.PSObject.Properties.Match("StatusCode").Count | Should Be 1;
    $output.StatusCode | Should Be "200";
	}

	It "Returns the status description set to OK." {
		$output = Trace-HttpRedirect -Uri "http://final.site.test/";
    $output.PSObject.Properties.Match("StatusDescription").Count | Should Be 1;
    $output.StatusDescription | Should Be "OK";
	}

	It "Calls Invoke-WebRequest Once" {
		Trace-HttpRedirect -Uri "http://final.site.test/";
    Assert-VerifiableMocks;
	}
}
