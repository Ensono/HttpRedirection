function Trace-HttpRedirect {
  param(
    [Uri]$Uri
  )
  process {
    $redirect = Invoke-WebRequest -Uri $Uri -MaximumRedirection 0;
    $redirectObject = New-Object PSObject;
    $redirectObject | Add-Member -MemberType NoteProperty -Name "Redirect" -Value 1;
    $redirectObject | Add-Member -MemberType NoteProperty -Name "StatusCode" -Value 200;
    $redirectObject | Add-Member -MemberType NoteProperty -Name "StatusDescription" -Value "OK";

    $redirectObject;
  }
}
