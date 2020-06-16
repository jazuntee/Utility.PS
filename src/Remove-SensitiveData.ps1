<#
.SYNOPSIS
    Remove sensitive data from object or string.
.EXAMPLE
    PS C:\>$MyString = 'My password is: "SuperSecretString"'
    PS C:\>Remove-SensitiveData ([ref]$MyString) -FilterValues "Super","String"
    This removes the word "Super" and "String" from the input string with no output.
.EXAMPLE
    PS C:\>Remove-SensitiveData 'My password is: "SuperSecretString"' -FilterValues "Super","String" -PassThru
    This removes the word "Super" and "String" from the input string and return the result.
.INPUTS
    System.Object
#>
function Remove-SensitiveData {
    [CmdletBinding()]
    [OutputType([object])]
    param (
        # Object from which to remove sensitive data.
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object] $InputObjects,
        # Sensitive string values to remove from input object.
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyString()]
        [string[]] $FilterValues,
        # Replacement value for senstive data.
        [Parameter(Mandatory = $false)]
        [string] $ReplacementValue = '********',
        # Copy the input object rather than remove data directly from input.
        [Parameter(Mandatory = $false)]
        [switch] $Clone,
        # Output object with sensitive data removed.
        [Parameter(Mandatory = $false)]
        [switch] $PassThru
    )

    process {
        if ($InputObjects.GetType().FullName.StartsWith('System.Management.Automation.PSReference')) {
            if ($Clone) { $OutputObjects = $InputObjects.Value.Clone() }
            else { $OutputObjects = $InputObjects }
        }
        else {
            if ($Clone) { $OutputObjects = [ref]$InputObjects.Clone() }
            else {
                if ($InputObjects -is [System.ValueType] -or $InputObjects -is [string]) { Write-Warning ('The input of type [{0}] was not passed by reference. Senstive data will not be removed from the original input.' -f $InputObjects.GetType()) }
                $OutputObjects = [ref]$InputObjects
            }
        }

        if ($OutputObjects.Value -is [string]) {
            foreach ($FilterValue in $FilterValues) {
                if ($OutputObjects.Value -and $FilterValue) { $OutputObjects.Value = $OutputObjects.Value.Replace($FilterValue, $ReplacementValue) }
            }
        }
        elseif ($OutputObjects.Value -is [array] -or $OutputObjects.Value -is [System.Collections.ArrayList] -or $OutputObjects.Value.GetType().FullName.StartsWith('System.Collections.Generic.List')) {
            for ($ii = 0; $ii -lt $OutputObjects.Value.Count; $ii++) {
                if ($null -ne $OutputObjects.Value[$ii] -and $OutputObjects.Value[$ii] -isnot [ValueType]) {
                    $OutputObjects.Value[$ii] = Remove-SensitiveData ([ref]$OutputObjects.Value[$ii]) -FilterValues $FilterValues -PassThru
                }
            }
        }
        elseif ($OutputObjects.Value -is [hashtable] -or $OutputObjects.Value -is [System.Collections.Specialized.OrderedDictionary] -or $OutputObjects.Value.GetType().FullName.StartsWith('System.Collections.Generic.Dictionary')) {
            [array] $KeyNames = $OutputObjects.Value.Keys
            for ($ii = 0; $ii -lt $KeyNames.Count; $ii++) {
                if ($null -ne $OutputObjects.Value[$KeyNames[$ii]] -and $OutputObjects.Value[$KeyNames[$ii]] -isnot [ValueType]) {
                    $OutputObjects.Value[$KeyNames[$ii]] = Remove-SensitiveData ([ref]$OutputObjects.Value[$KeyNames[$ii]]) -FilterValues $FilterValues -PassThru
                }
            }
        }
        elseif ($OutputObjects.Value -is [object] -and $OutputObjects.Value -isnot [ValueType]) {
            [array] $PropertyNames = $OutputObjects.Value | Get-Member -MemberType Property, NoteProperty
            for ($ii = 0; $ii -lt $PropertyNames.Count; $ii++) {
                $PropertyName = $PropertyNames[$ii].Name
                if ($null -ne $OutputObjects.Value.$PropertyName -and $OutputObjects.Value.$PropertyName -isnot [ValueType]) {
                    $OutputObjects.Value.$PropertyName = Remove-SensitiveData ([ref]$OutputObjects.Value.$PropertyName) -FilterValues $FilterValues -PassThru
                }
            }
        }
        else {
            ## Non-Terminating Error
            $Exception = New-Object ArgumentException -ArgumentList ('Cannot remove senstive data from input of type {0}.' -f $OutputObjects.Value.GetType())
            Write-Error -Exception $Exception -Category ([System.Management.Automation.ErrorCategory]::ParserError) -CategoryActivity $MyInvocation.MyCommand -ErrorId 'RemoveSensitiveDataFailureTypeNotSupported' -TargetObject $OutputObjects.Value
            continue
        }

        if ($PassThru -or $Clone) {
            ## Return the object with sensitive data removed.
            if ($OutputObjects.Value -is [array] -or $OutputObjects.Value -is [System.Collections.ArrayList] -or $OutputObjects.Value.GetType().FullName.StartsWith('System.Collections.Generic.List')) {
                Write-Output $OutputObjects.Value -NoEnumerate
            }
            else {
                Write-Output $OutputObjects.Value
            }
        }
    }
}
