<#
.SYNOPSIS
    Get object property value in a manner that satifies strict mode.

.EXAMPLE
    PS >$object = New-Object psobject -Property @{ title = 'title value' }
    PS >$object | Get-PropertyValue -Property 'title'

    Get value of object property named title.

.EXAMPLE
    PS >$object = New-Object psobject -Property @{ lvl1 = (New-Object psobject -Property @{ nextLevel = 'lvl2 data' }) }
    PS >Get-PropertyValue $object -Property 'lvl1', 'nextLevel'

    Get value of nested object property named nextLevel.

.INPUTS
    System.Collections.IDictionary
    System.Management.Automation.PSObject

.LINK
    https://github.com/jasoth/Utility.PS
#>
function Get-PropertyValue {
    [CmdletBinding()]
    [OutputType([psobject])]
    param (
        # Object containing property values
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [AllowNull()]
        [psobject] $InputObjects,
        # Name of property. Specify an array of property names to tranverse nested objects.
        [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
        [string[]] $Property
    )

    process {
        foreach ($InputObject in $InputObjects) {
            for ($iProperty = 0; $iProperty -lt $Property.Count; $iProperty++) {
                ## Get property value
                if ($InputObject -is [System.Collections.IDictionary]) {
                    if ($InputObject.Contains($Property[$iProperty])) {
                        $PropertyValue = $InputObject[$Property[$iProperty]]
                    }
                    else { $PropertyValue = $null }
                }
                else {
                    $PropertyValue = Select-Object -InputObject $InputObject -ExpandProperty $Property[$iProperty] -ErrorAction Ignore
                }
                ## Check for more nested properties
                if ($iProperty -lt $Property.Count - 1) {
                    $InputObject = $PropertyValue
                    if ($null -eq $InputObject) { break }
                }
                else {
                    Write-Output $PropertyValue
                }
            }
        }
    }
}
