[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string] $ModulePath = "..\src\*.psd1"
)

Import-Module $ModulePath -Force

## Load Test Helper Functions
. (Join-Path $PSScriptRoot "TestCommon.ps1")

Describe "ConvertTo-QueryString" {

    class HashtableInput {
        [string] $CommandName = 'ConvertTo-QueryString'
        [hashtable] $BoundParameters = @{}
        [type] $ExpectedInputType = [hashtable]
        [hashtable[]] $IO = @(
            @{
                Input = [hashtable]@{ name = 'path/file.json' }
                Output = 'name=path%2Ffile.json'
            }
            @{
                Input = [hashtable]@{ id = [guid]'352182e6-9ab0-4115-807b-c36c88029fa4' }
                Output = 'id=352182e6-9ab0-4115-807b-c36c88029fa4'
            }
            @{
                Input = [hashtable]@{}
                Output = ''
            }
        )
    }
    TestGroup HashtableInput

    class OrderedDictionaryInput {
        [string] $CommandName = 'ConvertTo-QueryString'
        [hashtable] $BoundParameters = @{}
        [type] $ExpectedInputType = [System.Collections.Specialized.OrderedDictionary]
        [hashtable[]] $IO = @(
            @{
                Input = [ordered]@{ name = 'path/file.json'; index = 10 }
                Output = 'name=path%2Ffile.json&index=10'
            }
            @{
                Input = [ordered]@{ title = 'convert&prosper'; id = [guid]'352182e6-9ab0-4115-807b-c36c88029fa4' }
                Output = 'title=convert%26prosper&id=352182e6-9ab0-4115-807b-c36c88029fa4'
            }
        )
    }
    TestGroup OrderedDictionaryInput

    class DictionaryInput {
        [string] $CommandName = 'ConvertTo-QueryString'
        [hashtable] $BoundParameters = @{}
        [type] $ExpectedInputType = [object]
        [hashtable[]] $IO = @(
            @{
                Input = Invoke-Command { $D = New-Object 'System.Collections.Generic.Dictionary[string,object]'; $D.Add('name','path/file.json'); $D.Add('index',10); $D }
                Output = 'name=path%2Ffile.json&index=10'
            }
            @{
                Input = Invoke-Command { $D = New-Object 'System.Collections.Generic.Dictionary[string,object]'; $D.Add('title','convert&prosper'); $D.Add('id',[guid]'352182e6-9ab0-4115-807b-c36c88029fa4'); $D }
                Output = 'title=convert%26prosper&id=352182e6-9ab0-4115-807b-c36c88029fa4'
            }
        )
    }
    TestGroup DictionaryInput

    class ObjectInput {
        [string] $CommandName = 'ConvertTo-QueryString'
        [hashtable] $BoundParameters = @{}
        [type] $ExpectedInputType = [object]
        [hashtable[]] $IO = @(
            @{
                Input = New-Module -AsCustomObject { $index = 10; $name = 'path/file.json'; Export-ModuleMember -Variable * }
                Output = 'index=10&name=path%2Ffile.json'
            }
            @{
                Input = [int]127
                Error = $true
            }
            @{
                Input = New-Module -AsCustomObject { $id = [guid]'352182e6-9ab0-4115-807b-c36c88029fa4'; $title = 'convert&prosper'; Export-ModuleMember -Variable * }
                Output = 'id=352182e6-9ab0-4115-807b-c36c88029fa4&title=convert%26prosper'
            }
        )
    }
    TestGroup ObjectInput

    Write-Host
    It "Terminating Errors" {
        $ScriptBlock = { ([ordered]@{ name = 'path/file.json'; index = 10 }),([int]127),([ordered]@{ title = 'convert&prosper'; id = [guid]'352182e6-9ab0-4115-807b-c36c88029fa4' }) | ConvertTo-QueryString -ErrorAction Stop }
        $ScriptBlock | Should -Throw
        try {
            $Output = & $ScriptBlock
        }
        catch {
            Test-ErrorOutput $_
        }
        $Output | Should -BeNullOrEmpty
    }
}
