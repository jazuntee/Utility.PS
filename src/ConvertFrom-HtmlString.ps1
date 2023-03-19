<#
.SYNOPSIS
    Convert HTML encoded string to string.
    
.EXAMPLE
    PS >ConvertFrom-HtmlString 'A string with &lt;html&gt; encoding'

    Convert HTML encoded string to string.

.INPUTS
    System.String

.LINK
    https://github.com/jasoth/Utility.PS
#>
function ConvertFrom-HtmlString {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        # Value to convert
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string[]] $InputStrings
    )

    process {
        foreach ($InputString in $InputStrings) {
            Write-Output ([System.Net.WebUtility]::HtmlDecode($InputString))
        }
    }
}
