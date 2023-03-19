<#
.SYNOPSIS
    Converts an object to a markdown table.

.EXAMPLE
    PS >ConvertTo-MarkdownTable $PsVersionTable

    Converts the PsVersionTable variable object to markdown table.

.EXAMPLE
    PS >Get-PSHostProcessInfo | ConvertTo-MarkdownTable -Compact

    Converts PSHostProcessInfo objects to markdown table.

.INPUTS
    System.Object

.LINK
    https://github.com/jasoth/Utility.PS
#>
function ConvertTo-MarkdownTable {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        # Objects to convert
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object[]] $InputObject,
        # Property names to include in the output.
        [Parameter(Mandatory = $false, Position = 1)]
        [string[]] $Property,
        # Output one row per input object or one keypair list table per input object
        [Parameter(Mandatory = $false)]
        [ValidateSet('Table', 'List')]
        [string] $As,
        # Do not include whitespace padding in table
        [Parameter(Mandatory = $false)]
        [switch] $Compact,
        # String to use as delimiter for array values
        [Parameter(Mandatory = $false)]
        [string] $ArrayDelimiter,
        # Format second level depth objects with the specified format
        [Parameter(Mandatory = $false)]
        [ValidateSet('ToString', 'PsFormat', 'Html')]
        [string] $ObjectFormat = 'PsFormat'
    )

    begin {
        ## Initalize variables
        $NewLineReplacement = '<br>'

        function FormatMarkdownTableHeaderRow ($ColumnWidths) {
            if ($ColumnWidths.Count -gt 0) {
                $InitialColumn = $true
                [string]$TableRow = '| '
                [string]$DelimiterRow = '| '
                foreach ($PropertyName in $ColumnWidths.Keys) {
                    if (!$InitialColumn) { $TableRow += ' | ' }
                    $TableRow += $PropertyName.PadRight($ColumnWidths[$PropertyName], ' ')

                    if (!$InitialColumn) { $DelimiterRow += ' | ' }
                    if ($ColumnWidths[$PropertyName] -gt 0) {
                        $DelimiterRow += '---'.PadRight($ColumnWidths[$PropertyName], '-')
                    }
                    else {
                        $DelimiterRow += '---' #.PadRight($PropertyName.Length, '-')
                    }

                    $InitialColumn = $false
                }
                $TableRow += ' |'
                $DelimiterRow += ' |'

                $TableRow
                $DelimiterRow
            }
        }

        function FormatMarkdownTableRow ($ColumnWidths, $InputObject) {
            $InitialColumn = $true
            [string]$TableRow = '| '
            foreach ($PropertyName in $ColumnWidths.Keys) {
                if (!$InitialColumn) { $TableRow += ' | ' }

                if ($InputObject) {
                    $StringValue = ''

                    $PropertyValue = Get-PropertyValue $InputObject $PropertyName
                    $StringValue = Transform $PropertyValue
                    
                    $TableRow += $StringValue.PadRight($ColumnWidths[$PropertyName], ' ')
                }

                $InitialColumn = $false
            }
            $TableRow += ' |'

            return $TableRow
        }

        function FormatMarkdownKeyPairRows ($ColumnWidths, $InputObject) {
            foreach ($Property in $InputObject.PSObject.Properties) {
                $InitialColumn = $true
                [string]$TableRow = '| '

                foreach ($PropertyName in $ColumnWidths.Keys) {
                    if (!$InitialColumn) { $TableRow += ' | ' }

                    if ($InputObject) {
                        if ($PropertyName -eq 'Name') {
                            $TableRow += $Property.Name.PadRight($ColumnWidths['Name'], ' ')
                        }
                        else {
                            $StringValue = ''

                            $PropertyValue = $Property.Value
                            $StringValue = Transform $PropertyValue
                    
                            $TableRow += $StringValue.PadRight($ColumnWidths['Value'], ' ')
                        }
                    }

                    $InitialColumn = $false
                }
                $TableRow += ' |'

                Write-Output $TableRow
            }
            
        }

        function Transform ($PropertyValue) {
            $StringValue = ''
            if ($null -ne $PropertyValue) {
                if ($ArrayDelimiter -ne '' -and $PropertyValue -is [System.Collections.IList]) {
                    [array]$ArrayObject = New-Object -TypeName object[] -ArgumentList $PropertyValue.Count  # ConstrainedLanguage safe
                    for ($i = 0; $i -lt $PropertyValue.Count; $i++) {
                        $ArrayObject[$i] = $PropertyValue[$i].ToString()
                        if (!$ArrayObject[$i]) { $ArrayObject[$i] = $PropertyValue[$i].psobject.TypeNames[0] }
                    }
                    $StringValue = ($ArrayObject -join $ArrayDelimiter)
                }
                elseif ($PropertyValue -is [System.Collections.IDictionary] -or $PropertyValue -is [psobject]) {
                    if ($PropertyValue -is [System.Collections.IDictionary]) {
                        $PropertyValue = New-Object -TypeName PSObject -Property $PropertyValue  # ConstrainedLanguage safe
                    }
                    
                    if ($ObjectFormat -eq 'PsFormat') {
                        $FormattedObject = $PropertyValue | Format-List | Out-String -Width 2147483647
                        $StringValue = $FormattedObject.Trim("`r", "`n")
                    }
                    elseif ($ObjectFormat -eq 'Html') {
                        $HtmlTable = $PropertyValue | ConvertTo-Html -Fragment -As List
                        $StringValue = $HtmlTable -join ''
                    }
                    else {
                        $StringValue = $PropertyValue.ToString()
                        if (!$StringValue) { $StringValue = $PropertyValue.psobject.TypeNames[0] }
                    }
                }
                else {
                    $StringValue = $PropertyValue.ToString()
                }
            }
            $StringValue = $StringValue.Replace('\', '\\').Replace('|', '\|') # Escape backslash and pipe characters
            $StringValue = $StringValue -replace '(?<=[>])[\r\n]+(?=[<])', '' # Remove newlines between html tags
            $StringValue = $StringValue -replace '[\r\n]+', $NewLineReplacement # Replace newlines

            return $StringValue
        }

        $TableObjects = @()
    }

    process {
        foreach ($_InputObject in $InputObject) {
            ## Convert dictionaries
            if ($_InputObject -is [System.Collections.IDictionary]) {
                $_InputObject = New-Object -TypeName PSObject -Property $_InputObject  # ConstrainedLanguage safe
            }
            
            if ($Property) {
                $OutputObject = Select-Object -InputObject $_InputObject -Property $Property
            }
            else {
                $OutputObject = Select-Object -InputObject $_InputObject -Property "*"
            }

            $TableObjects += $OutputObject
        }
    }

    end {
        
        if (!$As) {
            if ($TableObjects.Count -gt 1) { $As = 'Table' }
            else { $As = 'List' }
        }

        if ($As -eq 'List') {
            foreach ($ObjectTable in $TableObjects) {
                ## Get column names and widths
                $KeyPairWidths = [ordered]@{ Name = 0; Value = 0 }
                foreach ($objProperty in $ObjectTable.PSObject.Properties) {
                    if (!$Compact -and $KeyPairWidths['Name'] -lt $objProperty.Name.Length) {
                        $KeyPairWidths['Name'] = $objProperty.Name.Length
                    }

                    $PropertyValue = Transform $objProperty.Value
                    if (!$Compact -and $null -ne $PropertyValue) {
                        if ($KeyPairWidths['Value'] -lt $PropertyValue.Length) {
                            $KeyPairWidths['Value'] = $PropertyValue.Length
                        }
                    }
                }

                ## Output Header and Separator Rows
                FormatMarkdownTableHeaderRow $KeyPairWidths
                ## Output Object Rows
                FormatMarkdownKeyPairRows $KeyPairWidths $ObjectTable
                ''
            }
        }
        else {
            ## Get column names and widths
            $ColumnWidths = [ordered]@{}
            foreach ($ObjectRow in $TableObjects) {
                foreach ($objProperty in $ObjectRow.PSObject.Properties) {
                    if ($Compact) {
                        $ColumnWidths[$objProperty.Name] = 0
                    }
                    elseif ($null -eq $ColumnWidths[$objProperty.Name]) {
                        $ColumnWidths[$objProperty.Name] = $objProperty.Name.Length
                    }
                    
                    $PropertyValue = Transform $objProperty.Value
                    if (!$Compact -and $null -ne $PropertyValue) {
                        if ($ColumnWidths[$objProperty.Name] -lt $PropertyValue.Length) {
                            $ColumnWidths[$objProperty.Name] = $PropertyValue.Length
                        }
                    }
                }
            }

            ## Output Header and Separator Rows
            FormatMarkdownTableHeaderRow $ColumnWidths

            ## Output Object Rows
            foreach ($ObjectRow in $TableObjects) {
                FormatMarkdownTableRow $ColumnWidths $ObjectRow
            }
        }

    }
}
