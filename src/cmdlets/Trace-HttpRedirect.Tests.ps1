$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace('.Tests.', '.');
$mockTable = @{};
. "$here\$sut"

$invokeWebRequestFinalSite = { ($Uri -eq 'http://final.site.test/') -And ($MaximumRedirection -eq 0) };
$invokeWebRequestMovedPermanentlySite = { ($Uri -eq 'http://301.site.test/') -And ($MaximumRedirection -eq 0) };
$invokeWebRequestFoundSite = { ($Uri -eq 'http://302.site.test/') -And ($MaximumRedirection -eq 0) };
$invokeWebRequestSeeOtherSite = { ($Uri -eq 'http://303.site.test/') -And ($MaximumRedirection -eq 0) };
$invokeWebRequestTemporaryRedirectSite = { ($Uri -eq 'http://307.site.test/') -And ($MaximumRedirection -eq 0) };
$invokeWebRequestPermanenentRedirectSite = { ($Uri -eq 'http://308.site.test/') -And ($MaximumRedirection -eq 0) };
$invokeWebRequestInfiniteRedirect = { ($Uri -eq 'http://infinite.site.test/') -And ($MaximumRedirection -eq 0) };
$invokeWebRequestUsingGetMethod = { ($Uri -eq 'http://final.site.test/') -And ($MaximumRedirection -eq 0) -And ($Method -eq 'GET') };

Describe 'Trace-HttpRedirection calls to URL which returns a 200-OK.' {
	Mock -Verifiable -CommandName Invoke-WebRequest `
		-ParameterFilter $invokeWebRequestFinalSite `
		-MockWith { [String]::Empty | Select-Object @{ Name='StatusCode'; Expression={ '200' } }, @{ Name='StatusDescription'; Expression={ 'OK' } } };

	It 'returns a single object.' {
		$output = Trace-HttpRedirect -Uri 'http://final.site.test/';
		$output | Measure-Object | Select-Object -ExpandProperty Count | Should Be 1;
	}

	It 'returns an object of type HttpRedirection.RedirectResult' {
		$output = Trace-HttpRedirect -Uri 'http://final.site.test/';
		$output | Get-Member | Select-Object -First 1 -ExpandProperty TypeName | Should Be 'HttpRedirection.RedirectResult';
	}

	It 'returns the redirect number equal to 1.' {
		$output = Trace-HttpRedirect -Uri 'http://final.site.test/';
		$output.PSObject.Properties.Match('Redirect').Count | Should Be 1;
		$output.Redirect | Should Be 1;
	}

	It 'returns the status code set to 200.' {
		$output = Trace-HttpRedirect -Uri 'http://final.site.test/';
		$output.PSObject.Properties.Match('StatusCode').Count | Should Be 1;
		$output.StatusCode | Should Be '200';
	}

	It 'returns the status description set to OK.' {
		$output = Trace-HttpRedirect -Uri 'http://final.site.test/';
		$output.PSObject.Properties.Match('StatusDescription').Count | Should Be 1;
		$output.StatusDescription | Should Be 'OK';
	}

	It 'calls Invoke-WebRequest As Mocked' {
		Trace-HttpRedirect -Uri 'http://final.site.test/';
		Assert-VerifiableMocks;
	}
}

Describe 'Trace-HttpRedirection calls to URL which returns a 301-PermanantRedirect to a URL which returns 200-OK.' {
	Mock -Verifiable -CommandName Invoke-WebRequest `
		-ParameterFilter $invokeWebRequestMovedPermanentlySite `
		-MockWith { return [String]::Empty | Select-Object @{ Name='StatusCode'; Expression={ '301' } }, @{ Name='StatusDescription'; Expression={ 'MovedPermanently' } } , @{ Name='Headers'; Expression={ return @{ 'Location'='http://final.site.test/' } } } };

	Mock -Verifiable -CommandName Invoke-WebRequest `
		-ParameterFilter $invokeWebRequestFinalSite `
		-MockWith { return [String]::Empty | Select-Object @{ Name='StatusCode'; Expression={ '200' } }, @{ Name='StatusDescription'; Expression={ 'OK' } } };

	It 'returns a two objects.' {
		$output = Trace-HttpRedirect -Uri 'http://301.site.test/';
		$output | Measure-Object | Select-Object -ExpandProperty Count | Should Be 2;
	}

	It 'returns the redirect numbers starting at 1 and finishing at 2.' {
		$output = Trace-HttpRedirect -Uri 'http://301.site.test/';
		$output | Select-Object -First 1 -ExpandProperty Redirect | Should Be 1;
		$output | Select-Object -Last 1 -ExpandProperty Redirect | Should Be 2;
	}

	It 'returns the status code set to 301 first, followed by 200.' {
		$output = Trace-HttpRedirect -Uri 'http://301.site.test/';
		$output | Select-Object -First 1 -ExpandProperty StatusCode | Should Be '301';
		$output | Select-Object -Last 1 -ExpandProperty StatusCode | Should Be '200';
	}

	It 'returns the status description set to MovedPermanently first, followed by OK.' {
		$output = Trace-HttpRedirect -Uri 'http://301.site.test/';
		$output | Select-Object -First 1 -ExpandProperty StatusDescription | Should Be 'MovedPermanently';
		$output | Select-Object -Last 1 -ExpandProperty StatusDescription | Should Be 'OK';
	}

	It 'calls Invoke-WebRequest As Mocked' {
		Trace-HttpRedirect -Uri 'http://301.site.test/';
		Assert-VerifiableMocks;
	}
}

Describe 'Trace-HttpRedirection calls to URL which returns a 302-Found to a URL which returns 200-OK.' {
	Mock -Verifiable -CommandName Invoke-WebRequest `
		-ParameterFilter $invokeWebRequestFoundSite `
		-MockWith { return [String]::Empty | Select-Object @{ Name='StatusCode'; Expression={ '302' } }, @{ Name='StatusDescription'; Expression={ 'Found' } } , @{ Name='Headers'; Expression={ return @{ 'Location'='http://final.site.test/' } } } };

	Mock -Verifiable -CommandName Invoke-WebRequest `
		-ParameterFilter $invokeWebRequestFinalSite `
		-MockWith { return [String]::Empty | Select-Object @{ Name='StatusCode'; Expression={ '200' } }, @{ Name='StatusDescription'; Expression={ 'OK' } } };

	It 'returns a two objects.' {
		$output = Trace-HttpRedirect -Uri 'http://302.site.test/';
		$output | Measure-Object | Select-Object -ExpandProperty Count | Should Be 2;
	}

	It 'returns the redirect numbers starting at 1 and finishing at 2.' {
		$output = Trace-HttpRedirect -Uri 'http://302.site.test/';
		$output | Select-Object -First 1 -ExpandProperty Redirect | Should Be 1;
		$output | Select-Object -Last 1 -ExpandProperty Redirect | Should Be 2;
	}

	It 'returns the status code set to 302 first, followed by 200.' {
		$output = Trace-HttpRedirect -Uri 'http://302.site.test/';
		$output | Select-Object -First 1 -ExpandProperty StatusCode | Should Be '302';
		$output | Select-Object -Last 1 -ExpandProperty StatusCode | Should Be '200';
	}

	It 'returns the status description set to Found first, followed by OK.' {
		$output = Trace-HttpRedirect -Uri 'http://302.site.test/';
		$output | Select-Object -First 1 -ExpandProperty StatusDescription | Should Be 'Found';
		$output | Select-Object -Last 1 -ExpandProperty StatusDescription | Should Be 'OK';
	}

	It 'calls Invoke-WebRequest As Mocked' {
		Trace-HttpRedirect -Uri 'http://302.site.test/';
		Assert-VerifiableMocks;
	}
}

Describe 'Trace-HttpRedirection calls to URL which returns a 303-See Other to a URL which returns 200-OK.' {
	Mock -Verifiable -CommandName Invoke-WebRequest `
		-ParameterFilter $invokeWebRequestSeeOtherSite `
		-MockWith { return [String]::Empty | Select-Object @{ Name='StatusCode'; Expression={ '303' } }, @{ Name='StatusDescription'; Expression={ 'See Other' } } , @{ Name='Headers'; Expression={ return @{ 'Location'='http://final.site.test/' } } } };

	Mock -Verifiable -CommandName Invoke-WebRequest `
		-ParameterFilter $invokeWebRequestFinalSite `
		-MockWith { return [String]::Empty | Select-Object @{ Name='StatusCode'; Expression={ '200' } }, @{ Name='StatusDescription'; Expression={ 'OK' } } };

	It 'returns a two objects.' {
		$output = Trace-HttpRedirect -Uri 'http://303.site.test/';
		$output | Measure-Object | Select-Object -ExpandProperty Count | Should Be 2;
	}

	It 'returns the redirect numbers starting at 1 and finishing at 2.' {
		$output = Trace-HttpRedirect -Uri 'http://303.site.test/';
		$output | Select-Object -First 1 -ExpandProperty Redirect | Should Be 1;
		$output | Select-Object -Last 1 -ExpandProperty Redirect | Should Be 2;
	}

	It 'returns the status code set to 303 first, followed by 200.' {
		$output = Trace-HttpRedirect -Uri 'http://303.site.test/';
		$output | Select-Object -First 1 -ExpandProperty StatusCode | Should Be '303';
		$output | Select-Object -Last 1 -ExpandProperty StatusCode | Should Be '200';
	}

	It 'returns the status description set to See Other first, followed by OK.' {
		$output = Trace-HttpRedirect -Uri 'http://303.site.test/';
		$output | Select-Object -First 1 -ExpandProperty StatusDescription | Should Be 'See Other';
		$output | Select-Object -Last 1 -ExpandProperty StatusDescription | Should Be 'OK';
	}

	It 'calls Invoke-WebRequest As Mocked' {
		Trace-HttpRedirect -Uri 'http://303.site.test/';
		Assert-VerifiableMocks;
	}
}

Describe 'Trace-HttpRedirection calls to URL which returns a 307-Temporary Redirect to a URL which returns 200-OK.' {
	Mock -Verifiable -CommandName Invoke-WebRequest `
		-ParameterFilter $invokeWebRequestTemporaryRedirectSite `
		-MockWith { return [String]::Empty | Select-Object @{ Name='StatusCode'; Expression={ '307' } }, @{ Name='StatusDescription'; Expression={ 'Temporary Redirect' } } , @{ Name='Headers'; Expression={ return @{ 'Location'='http://final.site.test/' } } } };

	Mock -Verifiable -CommandName Invoke-WebRequest `
		-ParameterFilter $invokeWebRequestFinalSite `
		-MockWith { return [String]::Empty | Select-Object @{ Name='StatusCode'; Expression={ '200' } }, @{ Name='StatusDescription'; Expression={ 'OK' } } };

	It 'returns a two objects.' {
		$output = Trace-HttpRedirect -Uri 'http://307.site.test/';
		$output | Measure-Object | Select-Object -ExpandProperty Count | Should Be 2;
	}

	It 'returns the redirect numbers starting at 1 and finishing at 2.' {
		$output = Trace-HttpRedirect -Uri 'http://307.site.test/';
		$output | Select-Object -First 1 -ExpandProperty Redirect | Should Be 1;
		$output | Select-Object -Last 1 -ExpandProperty Redirect | Should Be 2;
	}

	It 'returns the status code set to 307 first, followed by 200.' {
		$output = Trace-HttpRedirect -Uri 'http://307.site.test/';
		$output | Select-Object -First 1 -ExpandProperty StatusCode | Should Be '307';
		$output | Select-Object -Last 1 -ExpandProperty StatusCode | Should Be '200';
	}

	It 'returns the status description set to Temporary Redirect first, followed by OK.' {
		$output = Trace-HttpRedirect -Uri 'http://307.site.test/';
		$output | Select-Object -First 1 -ExpandProperty StatusDescription | Should Be 'Temporary Redirect';
		$output | Select-Object -Last 1 -ExpandProperty StatusDescription | Should Be 'OK';
	}

	It 'calls Invoke-WebRequest As Mocked' {
		Trace-HttpRedirect -Uri 'http://307.site.test/';
		Assert-VerifiableMocks;
	}
}

Describe 'Trace-HttpRedirection calls to URL which returns a 308-Permanenent Redirect to a URL which returns 200-OK.' {
	Mock -Verifiable -CommandName Invoke-WebRequest `
		-ParameterFilter $invokeWebRequestPermanenentRedirectSite `
		-MockWith { return [String]::Empty | Select-Object @{ Name='StatusCode'; Expression={ '308' } }, @{ Name='StatusDescription'; Expression={ 'Permanenent Redirect' } } , @{ Name='Headers'; Expression={ return @{ 'Location'='http://final.site.test/' } } } };

	Mock -Verifiable -CommandName Invoke-WebRequest `
		-ParameterFilter $invokeWebRequestFinalSite `
		-MockWith { return [String]::Empty | Select-Object @{ Name='StatusCode'; Expression={ '200' } }, @{ Name='StatusDescription'; Expression={ 'OK' } } };

	It 'returns a two objects.' {
		$output = Trace-HttpRedirect -Uri 'http://308.site.test/';
		$output | Measure-Object | Select-Object -ExpandProperty Count | Should Be 2;
	}

	It 'returns the redirect numbers starting at 1 and finishing at 2.' {
		$output = Trace-HttpRedirect -Uri 'http://308.site.test/';
		$output | Select-Object -First 1 -ExpandProperty Redirect | Should Be 1;
		$output | Select-Object -Last 1 -ExpandProperty Redirect | Should Be 2;
	}

	It 'returns the status code set to 308 first, followed by 200.' {
		$output = Trace-HttpRedirect -Uri 'http://308.site.test/';
		$output | Select-Object -First 1 -ExpandProperty StatusCode | Should Be '308';
		$output | Select-Object -Last 1 -ExpandProperty StatusCode | Should Be '200';
	}

	It 'returns the status description set to Permanenent Redirect first, followed by OK.' {
		$output = Trace-HttpRedirect -Uri 'http://308.site.test/';
		$output | Select-Object -First 1 -ExpandProperty StatusDescription | Should Be 'Permanenent Redirect';
		$output | Select-Object -Last 1 -ExpandProperty StatusDescription | Should Be 'OK';
	}

	It 'calls Invoke-WebRequest As Mocked' {
		Trace-HttpRedirect -Uri 'http://308.site.test/';
		Assert-VerifiableMocks;
	}
}

Describe 'Trace-HttpRedirection makes call to URL which redirects to itself.' {
	Mock -Verifiable -CommandName Invoke-WebRequest `
		-ParameterFilter $invokeWebRequestInfiniteRedirect `
		-MockWith { return [String]::Empty | Select-Object @{ Name='StatusCode'; Expression={ '301' } }, @{ Name='StatusDescription'; Expression={ 'Moved Permanently' } } , @{ Name='Headers'; Expression={ return @{ 'Location'='http://infinite.site.test/' } } } };

	It 'returns a five objects when defaults used.' {
		$output = Trace-HttpRedirect -Uri 'http://infinite.site.test/';
		$output | Measure-Object | Select-Object -ExpandProperty Count | Should Be 5;
	}

	It 'returns a 30 objects when MaximumRedirection of 30 is set.' {
		$output = Trace-HttpRedirect -Uri 'http://infinite.site.test/' -MaximumRedirection 30;
		$output | Measure-Object | Select-Object -ExpandProperty Count | Should Be 30;
	}

	It 'calls Invoke-WebRequest As Mocked' {
		Trace-HttpRedirect -Uri 'http://infinite.site.test/';
		Assert-VerifiableMocks;
	}
}

Describe 'Trace-HttpRedirection makes call to URL which redirects to itself.' {
	Mock -Verifiable -CommandName Invoke-WebRequest `
		-ParameterFilter $invokeWebRequestInfiniteRedirect `
		-MockWith { return [String]::Empty | Select-Object @{ Name='StatusCode'; Expression={ '301' } }, @{ Name='StatusDescription'; Expression={ 'Moved Permanently' } } , @{ Name='Headers'; Expression={ return @{ 'Location'='http://infinite.site.test/' } } } };

	It 'returns a five objects when defaults used.' {
		$output = Trace-HttpRedirect -Uri 'http://infinite.site.test/';
		$output | Measure-Object | Select-Object -ExpandProperty Count | Should Be 5;
	}

	It 'returns a 30 objects when MaximumRedirection of 30 is set.' {
		$output = Trace-HttpRedirect -Uri 'http://infinite.site.test/' -MaximumRedirection 30;
		$output | Measure-Object | Select-Object -ExpandProperty Count | Should Be 30;
	}

	It 'calls Invoke-WebRequest As Mocked' {
		Trace-HttpRedirect -Uri 'http://infinite.site.test/';
		Assert-VerifiableMocks;
	}
}

Describe 'Trace-HttpRedirection makes call to URL using the GET method.' {
	Mock -Verifiable -CommandName Invoke-WebRequest `
		-ParameterFilter $invokeWebRequestUsingGetMethod `
		-MockWith { return [String]::Empty | Select-Object @{ Name='StatusCode'; Expression={ '200' } }, @{ Name='StatusDescription'; Expression={ 'OK' } } };

	It 'calls Invoke-WebRequest with HTTP GET method.' {
		$output = Trace-HttpRedirect -Uri 'http://final.site.test/' -ForceGet;
	}
}

Describe 'Trace-HttpRedirect completes after a single call to a terminating endpoint.' {
	It 'returns after one call which returns a 200-OK.' {
		Mock -Verifiable -CommandName Invoke-WebRequest `
			-ParameterFilter $invokeWebRequestFinalSite `
			-MockWith { return [String]::Empty | Select-Object @{ Name='StatusCode'; Expression={ '200' } }, @{ Name='StatusDescription'; Expression={ 'OK' } } };

		$output = Trace-HttpRedirect -Uri 'http://final.site.test/';
		$output | Measure-Object | Select-Object -ExpandProperty Count | Should Be 1;
		Assert-VerifiableMocks;
	}

	It 'returns after one call which returns a 404-File Not Found.' {
		Mock -Verifiable -CommandName Invoke-WebRequest `
			-ParameterFilter $invokeWebRequestFinalSite `
			-MockWith { return [String]::Empty | Select-Object @{ Name='StatusCode'; Expression={ '404' } }, @{ Name='StatusDescription'; Expression={ 'File Not Found' } } };

		$output = Trace-HttpRedirect -Uri 'http://final.site.test/';
		$output | Measure-Object | Select-Object -ExpandProperty Count | Should Be 1;
		Assert-VerifiableMocks;
	}
}