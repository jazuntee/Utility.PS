<#
.SYNOPSIS
    Convert string to HTML encoded string.

.EXAMPLE
    PS >ConvertTo-HtmlString 'A string with <html> encoding'

    Convert string to HTML encoded string.

.INPUTS
    System.String

.LINK
    https://github.com/jasoth/Utility.PS
#>
function ConvertTo-HtmlString {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        # Value to convert
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string[]] $InputStrings
    )

    process {
        foreach ($InputString in $InputStrings) {
            Write-Output ([System.Net.WebUtility]::HtmlEncode($InputString))
        }
    }
}
