<#
.SYNOPSIS
    Convert Hashtable to Query String.
.DESCRIPTION

.EXAMPLE
    PS C:\>ConvertTo-QueryString @{ name = 'path/file.json'; index = 10 }
    Convert hashtable to query string.
.EXAMPLE
    PS C:\>[ordered]@{ title = 'convert&prosper'; id = [guid]'352182e6-9ab0-4115-807b-c36c88029fa4' } | ConvertTo-QueryString
    Convert ordered dictionary to query string.
.INPUTS
    System.String
#>
function ConvertFrom-QueryString {
    [CmdletBinding()]
    [OutputType([psobject])]
    param (
        # Value to convert
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [string[]] $InputStrings
    )

    process {
        foreach ($InputString in $InputStrings) {
            [psobject] $OutputObject = New-Object psobject
            if ($InputString[0] -eq '?') { $InputString = $InputString.Substring(1) }
            [string[]] $QueryParameters = $InputString.Split('&')
            foreach ($QueryParameter in $QueryParameters) {
                [string[]] $QueryParameterPair = $QueryParameter.Split('=')
                $OutputObject | Add-Member $QueryParameterPair[0] -MemberType NoteProperty -Value ([System.Net.WebUtility]::UrlDecode($QueryParameterPair[1]))
            }
            Write-Output $OutputObject
        }
    }

}
