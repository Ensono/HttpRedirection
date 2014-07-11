<# .ExternalHelp ../help/HttpRedirection.Test-HttpRedirect.xml #>
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
    for ($redirect = 1; $redirect -le $MaximumRedirection; $redirect++) {
      if ($ForceGet) {
        $method = "GET";
      } else {
        $method = "HEAD";
      }

      $result = Invoke-WebRequest -Uri $Uri -MaximumRedirection 0 -ErrorAction SilentlyContinue -Method $method;
      $redirectObject = New-Object PSObject;
      $redirectObject.PSObject.TypeNames.Insert(0, "HttpRedirection.RedirectResult")
      $redirectObject | Add-Member -MemberType NoteProperty -Name "Redirect" -Value $redirect;
      $redirectObject | Add-Member -MemberType NoteProperty -Name "StatusCode" -Value $result.StatusCode;
      $redirectObject | Add-Member -MemberType NoteProperty -Name "StatusDescription" -Value $result.StatusDescription;

      if ($result.Headers -And $result.Headers.ContainsKey("Location")) {
        $Uri = $result.Headers["Location"];
        $redirectObject | Add-Member -MemberType NoteProperty -Name "Location" -Value $Uri;
      }

      $redirectObject;

      if (-Not ($result.Headers)) {
        return; # no headers; ergo we have no Location header.
      }

      if (-Not ($result.Headers.ContainsKey("Location"))) {
        return; # no Location header so this is the end of the line.
      }
    }
  }
}