function Trace-HttpRedirect {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$True, Position=1)]
    [Uri]$Uri,
    [Parameter(Mandatory=$False, Position=2)]
    [int]$MaximumRedirection = 30
  )
  process {
    for ($redirect = 1; $redirect -le $MaximumRedirection; $redirect++) {
      $result = Invoke-WebRequest -Uri $Uri -MaximumRedirection 0 -ErrorAction SilentlyContinue;
      $redirectObject = New-Object PSObject;
      $redirectObject | Add-Member -MemberType NoteProperty -Name "Redirect" -Value $redirect;
      $redirectObject | Add-Member -MemberType NoteProperty -Name "StatusCode" -Value $result.StatusCode;
      $redirectObject | Add-Member -MemberType NoteProperty -Name "StatusDescription" -Value $result.StatusDescription;

      if ($result.Headers -And $result.Headers.ContainsKey("Location")) {
        $Uri = $result.Headers["Location"];
        $redirectObject | Add-Member -MemberType NoteProperty -Name "Location" -Value $Uri;
      }

      $redirectObject;

      if ($result.StatusCode -eq 200) {
        return;
      }
    }
  }
}
