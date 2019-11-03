function Invoke-NitradoRestMethod
{
  <#
    .SYNOPSIS
    Invoke-RestMethod Wrapper for macmon API

    .DESCRIPTION
    Invoke-RestMethod Wrapper for macmon API

    .EXAMPLE
    $Properties = @{
      $Token = Get-NitradoToken -Path ('{0}/.nitradotoken' -f $Env:HOME)
      ...
    }
    Invoke-ZammadRestMethod -Token $Token -Uri $Uri -Method 'Get'

    .NOTES
     n.a.
    #>

  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [string]
    $Token,

    [Parameter(Mandatory)]
    [string]
    $Uri,

    [string]
    $Body,

    [string]
    $OutFile,

    [Parameter(Mandatory)]
    [ValidateSet('Get', 'Post', 'Delete', 'Patch', 'Put')]
    [string]
    $Method
  )

  begin
  {
  }
  process
  {
    try
    {
      $PSBoundParameters.Add('Headers', @{Authorization = ("Bearer {0}" -f $Token) })
      $null = $PSBoundParameters.Remove('Token')
      $PSBoundParameters.Add('ContentType', 'application/json; charset=utf-8')
      $PSBoundParameters.Add('ErrorAction', 'Stop')
      Invoke-RestMethod @PSBoundParameters
    }
    catch
    {
      $Response = $($_.Exception | Select-Object -ExpandProperty 'Response' -ErrorAction Ignore)
      switch ($($Response.StatusCode.value__))
      {
        201
        {
          Write-Warning -Message ('Created. Uri: {0} Method: {1}' -f $Uri, $Method)
          continue
        }
        { $PSItem -ge 200 -and $PSItem -le 300 }
        {
          Write-Warning -Message ('OK. Uri: {0} Method: {1}' -f $Uri, $Method)
        }
        401
        {
          Write-Warning -Message ('The provided access token is not valid (anymore). Uri: {0} Method: {1}' -f $Uri, $Method)
        }
        404
        {
          Write-Warning -Message ('Uri not found. Uri: {0} Method: {1}' -f $Uri, $Method)
        }
        429
        {
          Write-Warning -Message ('The rate limit has been exceeded. Uri: {0} Method: {1}' -f $Uri, $Method)
        }
        503
        {
          Write-Warning -Message ('Maintenance. API is currently not available. Please come back in a few minutes and try it again. Uri: {0} Method: {1}' -f $Uri, $Method)
        }
        default
        {
          Write-Warning -Message ('Some error occured, see HTTP status code for further details. Uri: {0} Method: {1}.' -f $Uri, $Method)
        }
      }
    }
  }
  end
  {
  }
}