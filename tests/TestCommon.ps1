
function AutoEnumerate ($Output) {
    if ($null -eq $Output) { }
    elseif ($Output -is [array] -or $Output -is [System.Collections.ArrayList] -or $Output.GetType().FullName.StartsWith('System.Collections.Generic.List')) { Write-Output $Output -NoEnumerate }
    else { Write-Output $Output }
}

function GetInput ([hashtable[]]$TestIO, [type]$AssertType) {
    if ($TestIO.Count -gt 1) {
        $Input = New-Object object[] $TestIO.Count
        for ($i = 0; $i -lt $TestIO.Count; $i++) {
            $Input[$i] = $TestIO[$i].Input
            if ($AssertType) { AutoEnumerate $Input[$i] | Should -BeOfType $AssertType }
        }
        Write-Output $Input -NoEnumerate
    }
    else {
        if ($AssertType) { AutoEnumerate $TestIO[0].Input | Should -BeOfType $AssertType }
        AutoEnumerate $TestIO[0].Input
    }
}

function Test-ComparisionAssertions ($Reference, $Difference, [switch]$ArrayBaseTypeMatch) {
    ## Check Type
    # if ($Reference -is [array] -or $Reference -is [System.Collections.ArrayList] -or $Reference.GetType().FullName.StartsWith('System.Collections.Generic.List')) {
    #     Write-Output $Difference -NoEnumerate | Should -BeOfType $Reference.GetType()
    # }
    # else {
    #     $Difference | Should -BeOfType $Reference.GetType()
    # }
    if ($null -ne $Reference) {
        if ($ArrayBaseTypeMatch) {
            AutoEnumerate $Difference | Should -BeOfType $Reference.GetType().BaseType
        }
        else {
            AutoEnumerate $Difference | Should -BeOfType $Reference.GetType()
        }
    }

    ## Check Content
    if ($null -eq $Reference) {
        $null -eq $Difference | Should -BeTrue
    }
    elseif ($Reference -is [array] -or $Reference -is [System.Collections.ArrayList] -or $Reference.GetType().FullName.StartsWith('System.Collections.Generic.List')) {
        $Difference | Should -HaveCount $Reference.Count
        for ($i = 0; $i -lt $Reference.Count; $i++) {
            Test-ComparisionAssertions $Reference[$i] $Difference[$i]
        }
    }
    elseif ($Reference -is [hashtable] -or $Reference -is [System.Collections.Specialized.OrderedDictionary] -or $Reference.GetType().FullName.StartsWith('System.Collections.Generic.Dictionary')) {
        $Difference.Keys | Should -HaveCount $Reference.Keys.Count
        foreach ($Item in $Reference.GetEnumerator()) {
            Test-ComparisionAssertions $Item.Value $Difference[$Item.Key]
        }
    }
    elseif ($Reference -is [xml]) {
        $Difference.OuterXml | Should -BeExactly $Reference.OuterXml
    }
    elseif ($Reference -is [System.IO.FileSystemInfo]) {
        $Difference.ToString() | Should -BeExactly $Reference.ToString()
    }
    elseif ($Reference -is [psobject]) {
        $ReferenceProperty = $Reference | Get-Member -MemberType Property, NoteProperty
        $DifferenceProperty = $Difference | Get-Member -MemberType Property, NoteProperty
        $ReferenceProperty | Should -HaveCount $DifferenceProperty.Count
        for ($i = 0; $i -lt $ReferenceProperty.Count; $i++) {
            $ReferencePropertyName = $ReferenceProperty[$i].Name
            $DifferencePropertyName = $DifferenceProperty[$i].Name
            Test-ComparisionAssertions $Reference.$ReferencePropertyName $Difference.$DifferencePropertyName
        }
    }
    elseif ($Reference -is [Single] -or $Reference -is [Double]) {
        ## Depending on the random floating point number choosen, sometimes the values are slightly off?
        $Difference.ToString() | Should -BeExactly $Reference.ToString()
    }
    else {
        $Difference | Should -BeExactly $Reference
    }
}

function Test-ErrorOutput ($ErrorRecord, [switch]$SkipCategory, [switch]$SkipErrorId, [switch]$SkipTargetObject) {
    $ErrorRecord | Should -BeOfType [System.Management.Automation.ErrorRecord]
    $ErrorRecord.Exception | Should -Not -BeOfType [Microsoft.PowerShell.Commands.WriteErrorException]
    $ErrorRecord.Exception.Message | Should -Not -BeNullOrEmpty
    if ($PSVersionTable.PSVersion -ge [version]'6.0') { $ErrorRecord.CategoryInfo.Activity | Should -Not -BeExactly 'Write-Error' }
    if (!$SkipCategory) { $ErrorRecord.CategoryInfo.Category | Should -Not -BeExactly ([System.Management.Automation.ErrorCategory]::NotSpecified) }
    if (!$SkipErrorId) { $ErrorRecord.FullyQualifiedErrorId | Should -Not -BeLike ("{0}*" -f $ErrorRecord.Exception.GetType().FullName) }
    if (!$SkipTargetObject) { $ErrorRecord.TargetObject | Should -Not -BeNullOrEmpty }
}

# It 'Non-Terminating Errors' {
#     $ScriptBlock = { ([int]127),([decimal]127),([long]127) | ConvertTo-HexString -ErrorAction SilentlyContinue }
#     $ScriptBlock | Should -Not -Throw
#     $Output = Invoke-Expression $ScriptBlock.ToString() -ErrorVariable ErrorObjects
#     $ErrorObjects | Should -HaveCount 1
#     $Output | Should -HaveCount (3 - $ErrorObjects.Count)
#     foreach ($ErrorObject in $ErrorObjects) {
#         [System.Management.Automation.ErrorRecord] $ErrorRecord = $null
#         if ($ErrorObject -is [System.Management.Automation.ErrorRecord]) { $ErrorRecord = $ErrorObject }
#         else { $ErrorRecord = $ErrorObject.ErrorRecord }

#         Test-ErrorOutput $ErrorRecord
#     }
# }

function TestGroup ([type]$TestClass, [int]$StartIndex = 0) {
    Context $TestClass.Name {
        $TestValues = New-Object $TestClass.Name -ErrorAction Stop
        $BoundParameters = $TestValues.BoundParameters

        for ($i = $StartIndex; $i -lt $TestValues.IO.Count; $i++) {
            $TestIO = $TestValues.IO[$i]

            It ('Single Input [Index:{0}] of Type [{1}] as Positional Parameter{2}' -f $i, $TestIO.Input.GetType().Name, $(if ($TestIO.Error.Count -gt 0) { ' with Error' })) {
                $Input = GetInput $TestIO -AssertType $TestValues.ExpectedInputType
                $Output = & $TestValues.CommandName $Input -ErrorAction SilentlyContinue -ErrorVariable ErrorObjects @BoundParameters
                $ErrorObjects | Should -HaveCount $TestIO.Error.Count
                AutoEnumerate $Output | Should -HaveCount (1 - $TestIO.Error.Count)
                if ($TestIO.ContainsKey('Error')) {
                    Test-ErrorOutput $ErrorObjects
                }
                else {
                    #AutoEnumerate $Output | Should -BeOfType $TestIO.Output.GetType()
                    #$Output | Should -BeExactly $TestIO.Output
                    Test-ComparisionAssertions $TestIO.Output $Output
                }
            }

            It ('Single Input [Index:{0}] of Type [{1}] as Pipeline Input{2}' -f $i, $TestIO.Input.GetType().Name, $(if ($TestIO.Error.Count -gt 0) { ' with Error' })) {
                $Input = GetInput $TestIO -AssertType $TestValues.ExpectedInputType
                $Output = $Input | & $TestValues.CommandName -ErrorAction SilentlyContinue -ErrorVariable ErrorObjects @BoundParameters
                $ErrorObjects | Should -HaveCount $TestIO.Error.Count
                AutoEnumerate $Output | Should -HaveCount (1 - $TestIO.Error.Count)
                if ($TestIO.ContainsKey('Error')) {
                    Test-ErrorOutput $ErrorObjects
                }
                else {
                    if ($TestIO.ContainsKey('PipeOutput')) { $TestIOOutput = $TestIO.PipeOutput }
                    else { $TestIOOutput = $TestIO.Output }
                    #AutoEnumerate $Output | Should -BeOfType $TestIOOutput.GetType()
                    #$Output | Should -BeExactly $TestIOOutput
                    Test-ComparisionAssertions $TestIOOutput $Output
                }
            }
        }

        if ($TestValues.IO.Count -gt 1) {
            $TestIO = $TestValues.IO

            It ('Multiple Inputs [Total:{0}] as Positional Parameter{1}' -f $TestIO.Count, $(if ($TestIO.Error.Count -gt 0) { ' with Error' })) {
                $Input = GetInput $TestIO -AssertType $TestValues.ExpectedInputType
                $Output = & $TestValues.CommandName $Input -ErrorAction SilentlyContinue -ErrorVariable ErrorObjects @BoundParameters
                $ErrorObjects | Should -HaveCount $TestIO.Error.Count
                $Output | Should -HaveCount ($TestIO.Count - $TestIO.Error.Count)
                [int] $iError = 0
                for ($i = 0; $i -lt $TestIO.Count; $i++) {
                    if ($TestIO[$i].ContainsKey('Error')) {
                        Test-ErrorOutput $ErrorObjects[$iError]
                        $iError++
                    }
                    else {
                        #AutoEnumerate $Output[$i-$iError] | Should -BeOfType $TestIO[$i].Output.GetType()
                        #$Output[$i] | Should -BeExactly $TestIO[$i].Output
                        Test-ComparisionAssertions $TestIO[$i].Output $Output[$i - $iError]
                    }
                }
            }

            It ('Multiple Inputs [Total:{0}] as Pipeline Input{1}' -f $TestIO.Count, $(if ($TestIO.Error.Count -gt 0) { ' with Error' })) {
                $Input = GetInput $TestIO -AssertType $TestValues.ExpectedInputType
                $Output = $Input | & $TestValues.CommandName -ErrorAction SilentlyContinue -ErrorVariable ErrorObjects @BoundParameters
                $ErrorObjects | Should -HaveCount $TestIO.Error.Count
                $Output | Should -HaveCount ($TestIO.Count - $TestIO.Error.Count)
                [int] $iError = 0
                for ($i = 0; $i -lt $TestIO.Count; $i++) {
                    if ($TestIO[$i].ContainsKey('Error')) {
                        Test-ErrorOutput $ErrorObjects[$iError]
                        $iError++
                    }
                    else {
                        #AutoEnumerate $Output[$i-$iError] | Should -BeOfType $TestIO[$i].Output.GetType()
                        #$Output[$i] | Should -BeExactly $TestIO[$i].Output
                        Test-ComparisionAssertions $TestIO[$i].Output $Output[$i - $iError]
                    }
                }
            }
        }
    }
}
