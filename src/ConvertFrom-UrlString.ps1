<#
.SYNOPSIS
    Convert URL encoded string to string.
.DESCRIPTION

.EXAMPLE
    PS C:\>ConvertFrom-UrlString 'A+string+with+url+encoding'
    Convert URL encoded string to string.
.INPUTS
    System.String
#>
function ConvertFrom-UrlString {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        # Value to convert
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string[]] $InputStrings
    )

    process {
        foreach ($InputString in $InputStrings) {
            Write-Output ([System.Net.WebUtility]::UrlDecode($InputString))
        }
    }
}
