<# .ExternalHelp ../help/HttpRedirection.Trace-HttpRedirect.xml #>
function Trace-HttpRedirect {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$True, Position=1)]
    [Uri]$Uri,
    [Parameter(Mandatory=$False, Position=2)]
    [int]$MaximumRedirection = 5,
    [switch]$ForceGet
  )
  process {
    $previousUri = $null;

    if ($ForceGet) {
      $method = 'GET';
    } else {
      $method = 'HEAD';
    }

    Write-Debug ("Invoking HTTP Trace of {0} using the {1} method." -f $Uri, $method)

    for ($redirect = 1; $redirect -le $MaximumRedirection; $redirect++) {

      # Handle relative URIs being returned in the Location Header by
      # converting them into absolute URIs based upon the previous URI.
      $relativeUri = [Uri]$null;
      if ($previousUri -And [System.Uri]::TryCreate([String]$Uri, [UriKind]::Relative, [ref]$relativeUri)) {
        $Uri = New-Object System.Uri -ArgumentList @($previousUri, $relativeUri);
      }

      try {
        $result = Invoke-WebRequest -Uri $Uri -MaximumRedirection 0 -ErrorAction SilentlyContinue -Method $method;
      }
      catch {
        $result = $_.Exception.Response;
      }
      
      $redirectObject = New-Object PSObject;
      $redirectObject.PSObject.TypeNames.Insert(0, 'HttpRedirection.RedirectResult')
      $redirectObject | Add-Member -MemberType NoteProperty -Name 'Redirect' -Value $redirect;
      $redirectObject | Add-Member -MemberType NoteProperty -Name 'StatusCode' -Value $result.StatusCode;
      $redirectObject | Add-Member -MemberType NoteProperty -Name 'StatusDescription' -Value $result.StatusDescription;

      if ($result.PSObject.Properties['Headers'] -And ($result.Headers['Location'] -ne $null)) {
        $previousUri = $Uri;
        $Uri = $result.Headers['Location'];
        $redirectObject | Add-Member -MemberType NoteProperty -Name 'Location' -Value $Uri;
      }

      $redirectObject;

      if (-Not ($result.PSObject.Properties['Headers'])) {
        return; # no headers; ergo we have no Location header.
      }

      if (-Not ($result.Headers['Location'])) {
        return; # no Location header so this is the end of the line.
      }
    }
  }
}