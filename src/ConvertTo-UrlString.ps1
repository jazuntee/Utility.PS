<#
.SYNOPSIS
    Convert string to URL encoded string.

.EXAMPLE
    PS >ConvertTo-UrlString 'A string with url encoding'

    Convert string to URL encoded string.

.INPUTS
    System.String

.LINK
    https://github.com/jasoth/Utility.PS
#>
function ConvertTo-UrlString {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        # Value to convert
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string[]] $InputStrings
    )

    process {
        foreach ($InputString in $InputStrings) {
            Write-Output ([System.Net.WebUtility]::UrlEncode($InputString))
        }
    }
}
