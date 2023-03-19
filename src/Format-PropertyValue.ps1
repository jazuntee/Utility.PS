<#
.SYNOPSIS
    Format objects as readable strings for CSV output.

.EXAMPLE
    PS > Format-PropertyValue @{ NestedHashtables = @{ lvl1 = @{ lvl2 = @('value1','value2') } }; Array = @('value1','value2') } -SingleLineOutput

    Format property values to a single line string for CSV output.

.INPUTS
    System.Object

.LINK
    https://github.com/jasoth/Utility.PS
#>
function Format-PropertyValue {
    [CmdletBinding()]
    [OutputType([psobject])]
    param (
        # Specifies the objects that are converted to CSV strings.
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [psobject[]] $InputObject,
        # Property names to include in the output.
        [Parameter(Mandatory = $false, Position = 1)]
        [string[]] $Property,
        # Specify how objects are represented in the output.
        [Parameter(Mandatory = $false)]
        [ValidateSet('PsFormat', 'PsFormatExpression', 'ToString', 'Json', 'Html')]
        [string] $ObjectFormat,
        # Determines how many items are enumerated. Set to 0 to enumerate all items. Default is $global:FormatEnumerationLimit.
        [Parameter(Mandatory = $false)]
        [int] $EnumerationLimit = $global:FormatEnumerationLimit,
        # Specifies how many levels of nested objects are included. This does not apply to ToString object representation.
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 100)]
        [int] $Depth = 1,
        # Formatted output is a single line.
        [Parameter(Mandatory = $false)]
        [switch] $SingleLineOutput,
        # Format root level object properties in addition to nested properties.
        [Parameter(Mandatory = $false)]
        [switch] $FormatRootLevelProperties
    )

    begin {
        ## Initalize variables
        $TopLevelTypes = [string], [ValueType], [version]
        if ($PSVersionTable.PSVersion -ge '6.0') { $TopLevelTypes += [semver] }
        $PrevFormatEnumerationLimit = $global:FormatEnumerationLimit
        $NewLineReplacement = '; '
        $ArrayDelimiter = "`r`n"
        $PsFormatWidth = 2147483646

        ## Set default values
        if (!$ObjectFormat) {
            if ($SingleLineOutput) {
                $ObjectFormat = 'ToString'
            }
            else {
                $ObjectFormat = 'PsFormat'
            }
        }

        ## ToDo: Find a way to replicate SmartToString function to replace current PsFormatExpression/ToString object representation implementation.
        # https://github.com/PowerShell/PowerShell/blob/08baf27b80e604d1685c065ea75761508634de12/src/System.Management.Automation/FormatAndOutput/common/Utilities/MshObjectUtil.cs#L213

        function IsTopLevelType ($InputObject) {
            foreach ($TopLevelType in $TopLevelTypes) {
                if ($InputObject -is $TopLevelType) { return $true }
            }
            return $false
        }

        function TransformObject ($InputObject, [string]$ObjectFormat) {
            if ($InputObject -is [System.Collections.IList]) {
                $Truncated = $false
                if ($EnumerationLimit -gt 0 -and $InputObject.Count -gt $EnumerationLimit) { $InputObject = $InputObject[0..($EnumerationLimit - 1)] + '...'; $Truncated = $true }
                # if (IsTopLevelType $InputObject[0]) {
                #     $OutputObject = $InputObject -join $ArrayDelimiter
                # }
            }

            if ($ObjectFormat -eq 'Json') {
                $JsonDepth = if ($FormatRootLevelProperties -or $Depth -eq 0) { $Depth } else { $Depth - 1 }
                $OutputObject = $InputObject | ConvertTo-Json -Depth $JsonDepth -Compress:$SingleLineOutput
            }
            elseif ($ObjectFormat -eq 'Html') {
                if ($InputObject -is [System.Collections.IList]) {
                    if (IsTopLevelType $InputObject[0]) {
                        $OutputObject = $InputObject -join $ArrayDelimiter
                    }
                    else {
                        if ($Truncated) { $InputObject = $InputObject[0..($InputObject.Count - 2)] }
                        $OutputObject = $InputObject | ConvertTo-Html -Fragment -As Table
                        if ($Truncated) { $OutputObject[-1] += '...' }
                    }
                }
                else {
                    if (IsTopLevelType $InputObject) { $OutputObject = $InputObject }
                    else { $OutputObject = $InputObject | ConvertTo-Html -Fragment -As List }
                }
                if ($SingleLineOutput) { $OutputObject = $OutputObject -join "" }
                else { $OutputObject = $OutputObject -join "`r`n" }

                ## Decode inner HTML table tags
                #$OutputObject = [System.Net.WebUtility]::HtmlDecode($OutputObject)  # Not ConstrainedLanguage safe
                $OutputObject = $OutputObject -replace '&lt;(/?(?:table|th|tr|td|colgroup|col)/?)&gt;', '<$1>'  # Escape nested table tags
                $OutputObject = $OutputObject -replace '&amp;(?=[a-zA-Z0-9]+;)', '&'  # Decode HTML ampersands due to double encoding
            }
            elseif ($ObjectFormat -eq 'PsFormat') {
                try {
                    if ($EnumerationLimit) { $global:FormatEnumerationLimit = $EnumerationLimit }
                    if ($InputObject -is [System.Collections.IList]) {
                        if (IsTopLevelType $InputObject[0]) {
                            $OutputObject = $InputObject -join $ArrayDelimiter
                        }
                        else {
                            $OutputObject = $InputObject | Format-Table -AutoSize | Out-String -Width $PsFormatWidth
                        }
                    }
                    else {
                        if (IsTopLevelType $InputObject) { $OutputObject = $InputObject }
                        else { $OutputObject = $InputObject | Format-List | Out-String -Width $PsFormatWidth }
                    }
                }
                finally {
                    if ($EnumerationLimit) { $global:FormatEnumerationLimit = $PrevFormatEnumerationLimit }
                }
                ## Remove trailing new line from Out-String
                $OutputObject = $OutputObject.Trim("`r", "`n")
            }
            elseif ($ObjectFormat -eq 'ToString') {
                if ($InputObject -is [System.Collections.IList]) {
                    ## Expand array items
                    [array]$ArrayObject = New-Object -TypeName object[] -ArgumentList $InputObject.Count  # ConstrainedLanguage safe
                    for ($i = 0; $i -lt $InputObject.Count; $i++) {
                        $ArrayObject[$i] = $InputObject[$i].ToString()
                        if (!$ArrayObject[$i]) { $ArrayObject[$i] = $InputObject[$i].psobject.TypeNames[0] }
                    }

                    $OutputObject = $ArrayObject -join $ArrayDelimiter
                }
                else {
                    $OutputObject = $InputObject.ToString()
                    if (!$OutputObject) { $OutputObject = $InputObject.psobject.TypeNames[0] }
                }
            }
            else {
                $OutputObject = $InputObject
            }
            return $OutputObject
        }

        function Transform ($InputObject, [int]$CurrentDepth = 0) {
            if ($InputObject) {
                if ($InputObject -is [string]) {
                    $OutputObject = $InputObject.ToString()
                }
                elseif ($InputObject -is [DateTime]) {
                    $OutputObject = $InputObject.ToString("o")
                }
                elseif (IsTopLevelType $InputObject) {
                    $OutputObject = $InputObject.ToString()
                }
                elseif ($InputObject -is [System.Collections.IDictionary]) {
                    ## Convert hashtables to PSObjects and shallow copy object
                    $OutputObject = New-Object -TypeName PSObject -Property $InputObject  # ConstrainedLanguage safe

                    if ($ObjectFormat -in 'Html', 'PsFormat', 'PsFormatExpression' -and $CurrentDepth -lt $Depth) {
                        foreach ($Key in $InputObject.Keys) {
                            $OutputObject.$Key = Transform $InputObject[$Key] ($CurrentDepth + 1)
                        }
                    }

                    $OutputObject = TransformObject $OutputObject -ObjectFormat $ObjectFormat
                }
                elseif ($InputObject -is [System.Collections.ICollection]) {
                    ## Shallow copy array
                    [array]$OutputObject = $InputObject | ForEach-Object { $_ }  # ConstrainedLanguage safe

                    if ($ObjectFormat -in 'Html', 'PsFormat', 'PsFormatExpression' -and $CurrentDepth -lt $Depth) {
                        # foreach ($_OutputObject in $OutputObject) {
                        #     $_OutputObject = Transform $_OutputObject ($CurrentDepth + 1)
                        # }
                        # for ($i = 0; $i -lt $InputObject.Count; $i++) {
                        #     $OutputObject[$i] = Transform $InputObject[$i] ($CurrentDepth + 1)
                        # }
                        for ($i = 0; $i -lt $OutputObject.Count; $i++) {
                            $OutputObject[$i] = Transform $OutputObject[$i] ($CurrentDepth + 1)
                        }
                    }
                    
                    $OutputObject = TransformObject $OutputObject -ObjectFormat $ObjectFormat
                }
                elseif ($InputObject -is [psobject]) {
                    ## Shallow copy PSObject
                    $OutputObject = Select-Object -InputObject $InputObject -Property "*"  # ConstrainedLanguage safe

                    if ($ObjectFormat -in 'Html', 'PsFormat', 'PsFormatExpression' -and $CurrentDepth -lt $Depth) {
                        foreach ($objProperty in $InputObject.psobject.Properties) {
                            $PropertyName = $objProperty.Name
                            $OutputObject.$PropertyName = Transform $objProperty.Value ($CurrentDepth + 1)
                        }
                    }

                    $OutputObject = TransformObject $OutputObject -ObjectFormat $ObjectFormat
                }
                else {
                    $OutputObject = $InputObject.ToString()
                }

                if ($SingleLineOutput) { $OutputObject = $OutputObject -replace '[\r\n]+', $NewLineReplacement }

                return $OutputObject
            }
            return $InputObject
        }

    }

    process {
        foreach ($_InputObject in $InputObject) {

            if ($_InputObject -is [string]) {
                $OutputObject = $_InputObject
                if ($SingleLineOutput) { $OutputObject = $OutputObject -replace '[\r\n]+', $NewLineReplacement }
            }
            elseif ($_InputObject -is [System.ValueType]) {
                $OutputObject = Transform $_InputObject
                if ($SingleLineOutput) { $OutputObject = $OutputObject -replace '[\r\n]+', $NewLineReplacement }
            }
            elseif ($_InputObject -is [System.Collections.IDictionary] -or $_InputObject -is [psobject]) {
                if ($_InputObject -is [System.Collections.IDictionary]) {
                    ## Convert IDictionary to PSObject
                    $_InputObject = New-Object -TypeName PSObject -Property $_InputObject  # ConstrainedLanguage safe
                }

                if ($Property) {
                    $OutputObject = Select-Object -InputObject $_InputObject -Property $Property
                }
                else {
                    $OutputObject = Select-Object -InputObject $_InputObject -Property "*"
                }
                
                if ($FormatRootLevelProperties) {
                    $OutputObject = Transform $OutputObject -CurrentDepth 0
                }
                else {
                    foreach ($objProperty in $OutputObject.psobject.Properties) {
                        $PropertyName = $objProperty.Name
                        if (!$Property -or $objProperty.Name -in $Property) {
                            $OutputObject.$PropertyName = Transform $objProperty.Value -CurrentDepth 1
                        }
                    }
                }
            }
            else {
                $OutputObject = Transform $_InputObject
                if ($SingleLineOutput) { $OutputObject = $OutputObject -replace '[\r\n]+', $NewLineReplacement }
            }

            try {
                if ($EnumerationLimit) { $global:FormatEnumerationLimit = $EnumerationLimit }
                Write-Output $OutputObject
            }
            finally {
                if ($EnumerationLimit) { $global:FormatEnumerationLimit = $PrevFormatEnumerationLimit }
            }

        }
    }
}
