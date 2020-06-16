<#
.SYNOPSIS
    Convert HTML encoded string to string.
.DESCRIPTION

.EXAMPLE
    PS C:\>ConvertFrom-HtmlString 'A string with &lt;html&gt; encoding'
    Convert HTML encoded string to string.
.INPUTS
    System.String
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
