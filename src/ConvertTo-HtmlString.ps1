<#
.SYNOPSIS
    Convert string to HTML encoded string.
.DESCRIPTION

.EXAMPLE
    PS C:\>ConvertTo-HtmlString 'A string with <html> encoding'
    Convert string to HTML encoded string.
.INPUTS
    System.String
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
