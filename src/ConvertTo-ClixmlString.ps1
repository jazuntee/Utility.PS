<#
.SYNOPSIS
    Convert string to Clixml serialized string.

.EXAMPLE
    PS >ConvertTo-ClixmlString 'A clixml serialized string'

    Convert string to Clixml serialized string.

.INPUTS
    System.Object

.LINK
    https://github.com/jasoth/Utility.PS
#>
function ConvertTo-ClixmlString {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        # Value to convert
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object] $InputObject,
        # Omits white space and indented formatting in the output string.
        [Parameter(Mandatory = $false)]
        [switch] $Compress,
        # Specifies how many levels of nested objects are included.
        [Parameter(Mandatory = $false)]
        [int] $Depth
    )

    process {
        #foreach ($_InputObject in $InputObject) {
            if ($Depth) {
                $OutputString = [System.Management.Automation.PSSerializer]::Serialize($InputObject, $Depth)
            }
            else {
                $OutputString = [System.Management.Automation.PSSerializer]::Serialize($InputObject)
            }

            if ($Compress) { $OutputString = $OutputString -replace '\r?\n\s*', '' }

            return $OutputString
        #}
    }
}
