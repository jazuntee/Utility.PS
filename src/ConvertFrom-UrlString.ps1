<#
.SYNOPSIS
    Convert URL encoded string to string.

.EXAMPLE
    PS >ConvertFrom-UrlString 'A+string+with+url+encoding'

    Convert URL encoded string to string.

.INPUTS
    System.String

.LINK
    https://github.com/jasoth/Utility.PS
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
