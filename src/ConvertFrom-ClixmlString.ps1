<#
.SYNOPSIS
    Convert Clixml serialized string to object.
    
.EXAMPLE
    PS >ConvertFrom-ClixmlString '<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04"><S>A clixml serialized string</S></Objs>'

    Convert Clixml serialized string to object.

.INPUTS
    System.String

.LINK
    https://github.com/jasoth/Utility.PS
#>
function ConvertFrom-ClixmlString {
    [CmdletBinding()]
    [OutputType([object])]
    param (
        # Value to convert
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string[]] $InputString
    )

    process {
        #foreach ($_InputString in $InputString) {
            [System.Management.Automation.PSSerializer]::Deserialize($InputString)
        #}
    }
}
