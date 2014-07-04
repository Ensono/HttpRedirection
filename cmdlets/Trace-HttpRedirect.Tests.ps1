$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".");
$mockTable = @{};
. "$here\$sut"

$invokeWebRequestFinalSite = { ($Uri -eq "http://final.site.test/") -And ($MaximumRedirection -eq 0) };
$invokeWebRequestMovedPermanentlySite = { ($Uri -eq "http://301.site.test/") -And ($MaximumRedirection -eq 0) };

Describe "Trace-HttpRedirection calls to URL which returns a 200-OK." {
	Mock -Verifiable -CommandName Invoke-WebRequest `
		-ParameterFilter $invokeWebRequestFinalSite `
		-MockWith { [String]::Empty | Select-Object @{ Name="StatusCode"; Expression={ "200" } }, @{ Name="StatusDescription"; Expression={ "OK" } } };

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

	It "Calls Invoke-WebRequest As Mocked" {
		Trace-HttpRedirect -Uri "http://final.site.test/";
		Assert-VerifiableMocks;
	}
}

Describe "Trace-HttpRedirection calls to URL which returns a 301-PermanantRedirect to a URL which returns 200-OK." {
	Mock -Verifiable -CommandName Invoke-WebRequest `
		-ParameterFilter $invokeWebRequestMovedPermanentlySite `
		-MockWith { return [String]::Empty | Select-Object @{ Name="StatusCode"; Expression={ "301" } }, @{ Name="StatusDescription"; Expression={ "MovedPermanently" } } , @{ Name="Headers"; Expression={ return @{ "Location"="http://final.site.test/" } } } };

	Mock -Verifiable -CommandName Invoke-WebRequest `
		-ParameterFilter $invokeWebRequestFinalSite `
		-MockWith { return [String]::Empty | Select-Object @{ Name="StatusCode"; Expression={ "200" } }, @{ Name="StatusDescription"; Expression={ "OK" } } };

	It "Returns a two objects." {
		$output = Trace-HttpRedirect -Uri "http://301.site.test/";
		$output | Measure-Object | Select-Object -ExpandProperty Count | Should Be 2;
	}

	It "Returns the redirect numbers starting at 1 and finishing at 2." {
		$output = Trace-HttpRedirect -Uri "http://301.site.test/";
		$output | Select-Object -First 1 -ExpandProperty Redirect | Should Be 1;
		$output | Select-Object -Last 1 -ExpandProperty Redirect | Should Be 2;
	}

	It "Returns the status code set to 301 first, followed by 200." {
		$output = Trace-HttpRedirect -Uri "http://301.site.test/";
		$output | Select-Object -First 1 -ExpandProperty StatusCode | Should Be "301";
		$output | Select-Object -Last 1 -ExpandProperty StatusCode | Should Be "200";
	}

	It "Returns the status description set to MovedPermanently first, followed by OK." {
		$output = Trace-HttpRedirect -Uri "http://301.site.test/";
		$output | Select-Object -First 1 -ExpandProperty StatusDescription | Should Be "MovedPermanently";
		$output | Select-Object -Last 1 -ExpandProperty StatusDescription | Should Be "OK";
	}

	It "Calls Invoke-WebRequest As Mocked" {
		Trace-HttpRedirect -Uri "http://301.site.test/";
		Assert-VerifiableMocks;
	}
}
