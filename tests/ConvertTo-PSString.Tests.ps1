[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string] $ModulePath = "..\src\*.psd1"
)

Import-Module $ModulePath -Force

## Load Test Helper Functions
. (Join-Path $PSScriptRoot 'TestCommon.ps1')

function TestGroup ([type]$TestClass, [int]$StartIndex = 0) {
    Context $TestClass.Name {
        $TestValues = New-Object $TestClass.Name -ErrorAction Stop
        $BoundParameters = $TestValues.BoundParameters

        for ($i = $StartIndex; $i -lt $TestValues.IO.Count; $i++) {
            [hashtable[]] $TestIO = $TestValues.IO[$i]

            It ('Single Input [Index:{0}] of Type [{1}] as Positional Parameter' -f $i, $TestIO[0].Input.GetType().Name) {
                $TestInput = GetInput $TestIO[0] -AssertType $TestValues.ExpectedInputType
                $PSString = & $TestValues.CommandName $TestInput @BoundParameters
                #Write-Host ($PSString -join "`r`n")
                if ($TestIO[0].ContainsKey('Output'))  { Test-ComparisionAssertions $TestIO[0].Output $PSString }
                $PSString = [string[]]$PSString
                $TestInputArray = [array]$TestInput
                for ($ii = 0; $ii -lt $PSString.Count; $ii++) {
                    Invoke-Expression ('$Output = {0}' -f $PSString[$ii])  # Variable set inside expression because arrays, lists, and arraylists do not retain strong type through Invoke-Expression output
                    if ($PSString.Count -eq 1) {
                        Test-ComparisionAssertions $TestInput $Output
                    }
                    else {
                        Test-ComparisionAssertions $TestInputArray[$ii] $Output
                    }
                }
            }

            It ('Single Input [Index:{0}] of Type [{1}] as Pipeline Input' -f $i, $TestIO[0].Input.GetType().Name) {
                $TestInput = GetInput $TestIO[0] -AssertType $TestValues.ExpectedInputType
                $PSString = $TestInput | & $TestValues.CommandName -WarningAction SilentlyContinue @BoundParameters
                #Write-Host ($PSString -join "`r`n")
                if ($TestIO[0].ContainsKey('PipeOutput')) { Test-ComparisionAssertions $TestIO[0].PipeOutput $PSString }
                elseif ($TestIO[0].ContainsKey('Output'))  { Test-ComparisionAssertions $TestIO[0].Output $PSString }
                $PSString = [string[]]$PSString
                $TestInputArray = [array]$TestInput
                for ($ii = 0; $ii -lt $PSString.Count; $ii++) {
                    Invoke-Expression ('$Output = {0}' -f $PSString[$ii])  # Variable set inside expression because arrays, lists, and arraylists do not retain strong type through Invoke-Expression output
                    if ($PSString.Count -eq 1) {
                        Test-ComparisionAssertions $TestInput $Output -ArrayBaseTypeMatch
                    }
                    else {
                        Test-ComparisionAssertions $TestInputArray[$ii] $Output
                    }
                }
            }
        }

        if ($TestValues.IO.Count -gt 1) {
            $TestIO = $TestValues.IO

            It ('Multiple Inputs [Total:{0}] as Positional Parameter' -f $TestIO.Count) {
                $TestInput = GetInput $TestIO -AssertType $TestValues.ExpectedInputType
                $PSString = & $TestValues.CommandName $TestInput @BoundParameters
                #Write-Host ($PSString -join "`r`n")
                $PSString = [string[]]$PSString
                $TestInputArray = [array]$TestInput
                for ($ii = 0; $ii -lt $PSString.Count; $ii++) {
                    Invoke-Expression ('$Output = {0}' -f $PSString[$ii])  # Variable set inside expression because arrays, lists, and arraylists do not retain strong type through Invoke-Expression output
                    if ($PSString.Count -eq 1) {
                        Test-ComparisionAssertions $TestInput $Output
                    }
                    else {
                        Test-ComparisionAssertions $TestInputArray[$ii] $Output
                    }
                }
            }

            It ('Multiple Inputs [Total:{0}] as Pipeline Input' -f $TestIO.Count) {
                $TestInput = GetInput $TestIO -AssertType $TestValues.ExpectedInputType
                $PSString = $TestInput | & $TestValues.CommandName -WarningAction SilentlyContinue @BoundParameters
                #Write-Host ($PSString -join "`r`n")
                $PSString = [string[]]$PSString
                $TestInputArray = [array]$TestInput
                for ($ii = 0; $ii -lt $PSString.Count; $ii++) {
                    Invoke-Expression ('$Output = {0}' -f $PSString[$ii])  # Variable set inside expression because arrays, lists, and arraylists do not retain strong type through Invoke-Expression output
                    if ($PSString.Count -eq 1) {
                        Test-ComparisionAssertions $TestInput $Output -ArrayBaseTypeMatch
                    }
                    else {
                        Test-ComparisionAssertions $TestInputArray[$ii] $Output
                    }
                }
            }
        }
    }
}

Describe 'ConvertTo-PsString' {

    It 'parses null object' {
        $PSString = ConvertTo-PsString $null
        $PSString | Should -BeOfType [System.String]
        $PSString | Should -BeExactly '$null'
        $null -eq (Invoke-Expression $PSString) | Should -BeTrue
    }

    ## Reference: https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/keywords/value-types-table
    class ValueTypeInput {
        [string] $CommandName = 'ConvertTo-PsString'
        [hashtable] $BoundParameters = @{}
        [type] $ExpectedInputType
        [hashtable[]] $IO = @(
            ## Integral numeric types
            @{
                Input = [Sbyte](Get-Random -Minimum ([Sbyte]::MinValue) -Maximum ([Sbyte]::MaxValue))
            }
            @{
                Input = [Byte](Get-Random -Minimum ([Byte]::MinValue) -Maximum ([Byte]::MaxValue))
            }
            @{
                Input = [Int16](Get-Random -Minimum ([Int16]::MinValue) -Maximum ([Int16]::MaxValue))
            }
            @{
                Input = [UInt16](Get-Random -Minimum ([UInt16]::MinValue) -Maximum ([UInt16]::MaxValue))
            }
            @{
                Input = [Int32](Get-Random -Minimum ([Int32]::MinValue) -Maximum ([Int32]::MaxValue))
            }
            @{
                Input = [UInt32](Get-Random -Minimum ([UInt32]::MinValue) -Maximum ([UInt32]::MaxValue))
            }
            @{
                Input = [Int64](Get-Random -Minimum ([Int64]::MinValue) -Maximum ([Int64]::MaxValue))
            }
            @{
                Input = [UInt64](Get-Random -Minimum ([UInt64]::MinValue) -Maximum ([UInt64]::MaxValue))
            }
            ## Floating-point numeric types
            @{
                Input = [Single](Get-Random -Minimum ([Single]::MinValue) -Maximum ([Single]::MaxValue))
            }
            @{
                Input = [Double](Get-Random -Minimum ([Double]::MinValue) -Maximum ([Double]::MaxValue))
            }
            @{
                Input = [Decimal](Get-Random -Minimum ([Decimal]::MinValue) -Maximum ([Decimal]::MaxValue))
            }
            ## Other value types
            @{
                Input = [Boolean](Get-Random -Minimum 0 -Maximum 2)
            }
            @{
                Input = [switch][bool](Get-Random -Minimum 0 -Maximum 2)
            }
            @{
                Input = [Char]''''
            }
            @{
                Input = [String]''
            }
            @{
                Input = [String]'string''string'
            }
            @{
                Input = [DateTime](Get-Date)
            }
            @{
                Input = [System.IO.FileAttributes]::Archive
            }
        )
    }
    TestGroup ValueTypeInput

    class ValueTypeInputCompactNoEnumerate {
        [string] $CommandName = 'ConvertTo-PsString'
        [hashtable] $BoundParameters = @{
            Compact = $true
            NoEnumerate = $true
        }
        [type] $ExpectedInputType
        [hashtable[]] $IO = @(
            ## Integral numeric types
            @{
                Input = [Sbyte](Get-Random -Minimum ([Sbyte]::MinValue) -Maximum ([Sbyte]::MaxValue))
            }
            @{
                Input = [Byte](Get-Random -Minimum ([Byte]::MinValue) -Maximum ([Byte]::MaxValue))
            }
            @{
                Input = [Int16](Get-Random -Minimum ([Int16]::MinValue) -Maximum ([Int16]::MaxValue))
            }
            @{
                Input = [UInt16](Get-Random -Minimum ([UInt16]::MinValue) -Maximum ([UInt16]::MaxValue))
            }
            @{
                Input = [Int32](Get-Random -Minimum ([Int32]::MinValue) -Maximum ([Int32]::MaxValue))
            }
            @{
                Input = [UInt32](Get-Random -Minimum ([UInt32]::MinValue) -Maximum ([UInt32]::MaxValue))
            }
            @{
                Input = [Int64](Get-Random -Minimum ([Int64]::MinValue) -Maximum ([Int64]::MaxValue))
            }
            @{
                Input = [UInt64](Get-Random -Minimum ([UInt64]::MinValue) -Maximum ([UInt64]::MaxValue))
            }
            ## Floating-point numeric types
            @{
                Input = [Single](Get-Random -Minimum ([Single]::MinValue) -Maximum ([Single]::MaxValue))
            }
            @{
                Input = [Double](Get-Random -Minimum ([Double]::MinValue) -Maximum ([Double]::MaxValue))
            }
            @{
                Input = [Decimal](Get-Random -Minimum ([Decimal]::MinValue) -Maximum ([Decimal]::MaxValue))
            }
            ## Other value types
            @{
                Input = [Boolean](Get-Random -Minimum 0 -Maximum 2)
            }
            @{
                Input = [switch][bool](Get-Random -Minimum 0 -Maximum 2)
            }
            @{
                Input = [Char]''''
            }
            @{
                Input = [String]''
            }
            @{
                Input = [String]'string''string'
            }
            @{
                Input = [DateTime](Get-Date)
            }
            @{
                Input = [System.IO.FileAttributes]::Archive
            }
        )
    }
    TestGroup ValueTypeInputCompactNoEnumerate

    class ObjectInput {
        [string] $CommandName = 'ConvertTo-PsString'
        [hashtable] $BoundParameters = @{}
        [type] $ExpectedInputType
        [hashtable[]] $IO = @(
            @{
                Input = [hashtable]@{
                    [UInt16]1 = 'value1'
                }
                Output = '[System.Collections.Hashtable]@{[System.UInt16]1=[System.String]''value1''}'
            }
            @{
                Input = [hashtable]@{
                    key2 = [int]3
                }
                Output = '[System.Collections.Hashtable]@{[System.String]''key2''=[System.Int32]3}'
            }
            @{
                Input = [ordered]@{
                    key1 = 'value1'
                    key2 = 2
                    key3 = [UInt16]3
                }
                Output = '[ordered]@{[System.String]''key1''=[System.String]''value1'';[System.String]''key2''=[System.Int32]2;[System.String]''key3''=[System.UInt16]3}'
            }
            @{
                Input = [Array]@()
                Output = $null
            }
            @{
                Input = [string[]]@(
                    'arrayValue1'
                    'arrayValue2'
                )
                Output = [object[]]@(
                    '[System.String]''arrayValue1'''
                    '[System.String]''arrayValue2'''
                )
            }
            @{
                Input = [int[]]@(
                    1
                    2
                )
                Output = [object[]]@(
                    '[System.Int32]1'
                    '[System.Int32]2'
                )
            }
            @{
                Input = [object[]]@(
                    'arrayValue1'
                    'arrayValue2'
                    3
                    4
                )
                Output = [object[]]@(
                    '[System.String]''arrayValue1'''
                    '[System.String]''arrayValue2'''
                    '[System.Int32]3'
                    '[System.Int32]4'
                )
            }
            @{
                Input = [object[]]@(
                    Write-Output ([string[]]('arrayValue1','arrayValue2')) -NoEnumerate
                    Write-Output ([int[]](1,2)) -NoEnumerate
                    $null
                    Write-Output ([hashtable[]](@{h1k1='v1'},@{h2k2='v2'})) -NoEnumerate
                )
                Output = [object[]]@(
                    '[System.String[]](Write-Output @([System.String]''arrayValue1'',[System.String]''arrayValue2'') -NoEnumerate)'
                    '[System.Int32[]](Write-Output @([System.Int32]1,[System.Int32]2) -NoEnumerate)'
                    '$null'
                    '[System.Collections.Hashtable[]](Write-Output @([System.Collections.Hashtable]@{[System.String]''h1k1''=[System.String]''v1''},[System.Collections.Hashtable]@{[System.String]''h2k2''=[System.String]''v2''}) -NoEnumerate)'
                )
            }
            @{
                Input = [System.Collections.ArrayList]@(
                    'arrayListValue1'
                    'arrayListValue2'
                    3
                    4
                )
                Output = [object[]]@(
                    '[System.String]''arrayListValue1'''
                    '[System.String]''arrayListValue2'''
                    '[System.Int32]3'
                    '[System.Int32]4'
                )
            }
            @{
                Input = [System.Collections.Generic.List[string]]@(
                    'listValue1'
                    'listValue2'
                )
                Output = [object[]]@(
                    '[System.String]''listValue1'''
                    '[System.String]''listValue2'''
                )
            }
            @{
                Input = [System.Collections.Generic.List[int]]@(
                    1
                    2
                )
                Output = [object[]]@(
                    '[System.Int32]1'
                    '[System.Int32]2'
                )
            }
            @{
                Input = [System.Collections.Generic.Dictionary[string,int]](Invoke-Command { $D = New-Object 'System.Collections.Generic.Dictionary[string,int]'; $D.Add('key1',1); $D.Add('key2',2); $D })
                Output = '(Invoke-Command { $D = New-Object ''System.Collections.Generic.Dictionary[[System.String],[System.Int32]]''; $D.Add([System.String]''key1'',[System.Int32]1); $D.Add([System.String]''key2'',[System.Int32]2); $D })'
            }
            @{
                Input = [xml]@'
    <nodeRoot>
    <nodeChild>'singleQuote'</nodeChild>
    <nodeChild>"doubleQuote"</nodeChild>
    </nodeRoot>
'@
                Output = '[System.Xml.XmlDocument]''<nodeRoot><nodeChild>''''singleQuote''''</nodeChild><nodeChild>"doubleQuote"</nodeChild></nodeRoot>'''
            }
        )
    }
    TestGroup ObjectInput

    class ObjectInputCompactNoEnumerate {
        [string] $CommandName = 'ConvertTo-PsString'
        [hashtable] $BoundParameters = @{
            Compact = $true
            NoEnumerate = $true
        }
        [type] $ExpectedInputType
        [hashtable[]] $IO = @(
            @{
                Input = [hashtable]@{
                    [byte]1 = 'value1'
                }
                Output = '[hashtable]@{[byte]1=''value1''}'
            }
            @{
                Input = [hashtable]@{
                    key2 = [int]3
                }
                Output = '[hashtable]@{''key2''=3}'
            }
            @{
                Input = [ordered]@{
                    key1 = 'value1'
                    key2 = 2
                    key3 = $null
                }
                Output = '[ordered]@{''key1''=''value1'';''key2''=2;''key3''=$null}'
            }
            @{
                Input = [Array]@()
                Output = '[Object[]](Write-Output @() -NoEnumerate)'
                PipeOutput = '(Write-Output @() -NoEnumerate)'
            }
            @{
                Input = [string[]]@(
                    'arrayValue1'
                    'arrayValue2'
                )
                Output = '[String[]](Write-Output @(''arrayValue1'',''arrayValue2'') -NoEnumerate)'
                PipeOutput = '(Write-Output @(''arrayValue1'',''arrayValue2'') -NoEnumerate)'
            }
            @{
                Input = [int[]]@(
                    1
                    2
                )
                Output = '[Int32[]](Write-Output @(1,2) -NoEnumerate)'
                PipeOutput = '(Write-Output @(1,2) -NoEnumerate)'
            }
            @{
                Input = [object[]]@(
                    'arrayValue1'
                    'arrayValue2'
                    3
                    4
                )
                Output = '[Object[]](Write-Output @([string]''arrayValue1'',[string]''arrayValue2'',[int]3,[int]4) -NoEnumerate)'
                PipeOutput = '(Write-Output @(''arrayValue1'',''arrayValue2'',3,4) -NoEnumerate)'
            }
            @{
                Input = [object[]]@(
                    Write-Output ([string[]]('arrayValue1','arrayValue2')) -NoEnumerate
                    Write-Output ([int[]](1,2)) -NoEnumerate
                    $null
                    Write-Output ([hashtable[]](@{h1k1='v1'},@{h2k2='v2'})) -NoEnumerate
                )
                Output = '[Object[]](Write-Output @([String[]](Write-Output @(''arrayValue1'',''arrayValue2'') -NoEnumerate),[Int32[]](Write-Output @(1,2) -NoEnumerate),$null,[Collections.Hashtable[]](Write-Output @(@{''h1k1''=''v1''},@{''h2k2''=''v2''}) -NoEnumerate)) -NoEnumerate)'
                PipeOutput = '(Write-Output @([String[]](Write-Output @(''arrayValue1'',''arrayValue2'') -NoEnumerate),[Int32[]](Write-Output @(1,2) -NoEnumerate),$null,[Collections.Hashtable[]](Write-Output @(@{''h1k1''=''v1''},@{''h2k2''=''v2''}) -NoEnumerate)) -NoEnumerate)'
            }
            @{
                Input = [System.Collections.ArrayList]@(
                    'arrayListValue1'
                    'arrayListValue2'
                    3
                    4
                )
                Output = '[Collections.ArrayList]@(''arrayListValue1'',''arrayListValue2'',3,4)'
                PipeOutput = '(Write-Output @(''arrayListValue1'',''arrayListValue2'',3,4) -NoEnumerate)'
            }
            @{
                Input = [System.Collections.Generic.List[string]]@(
                    'listValue1'
                    'listValue2'
                )
                Output = '[Collections.Generic.List[[string]]]@(''listValue1'',''listValue2'')'
                PipeOutput = '(Write-Output @(''listValue1'',''listValue2'') -NoEnumerate)'
            }
            @{
                Input = [System.Collections.Generic.List[int]]@(
                    1
                    2
                )
                Output = '[Collections.Generic.List[[int]]]@(1,2)'
                PipeOutput = '(Write-Output @(1,2) -NoEnumerate)'
            }
            @{
                Input = [System.Collections.Generic.Dictionary[string,int]](Invoke-Command { $D = New-Object 'System.Collections.Generic.Dictionary[string,int]'; $D.Add('key1',1); $D.Add('key2',2); $D })
                Output = '(Invoke-Command { $D = New-Object ''Collections.Generic.Dictionary[[string],[int]]''; $D.Add(''key1'',1); $D.Add(''key2'',2); $D })'
            }
            @{
                Input = [xml]@'
    <nodeRoot>
    <nodeChild>'singleQuote'</nodeChild>
    <nodeChild>"doubleQuote"</nodeChild>
    </nodeRoot>
'@
                Output = '[xml]''<nodeRoot><nodeChild>''''singleQuote''''</nodeChild><nodeChild>"doubleQuote"</nodeChild></nodeRoot>'''
            }
        )
    }
    TestGroup ObjectInputCompactNoEnumerate

}
