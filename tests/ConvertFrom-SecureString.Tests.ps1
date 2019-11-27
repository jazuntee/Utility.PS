[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string] $ModulePath = "..\src\*.psd1"
)

Import-Module $ModulePath -Force

## Load Test Helper Functions
. (Join-Path $PSScriptRoot "TestCommon.ps1")

Describe "ConvertFrom-SecureString" {

    class SecureStringInput {
        [string] $CommandName = 'ConvertFrom-SecureString'
        [hashtable] $BoundParameters = @{
            AsPlainText = $true
            Force = $true
        }
        [type] $ExpectedInputType = [securestring]
        [hashtable[]] $IO = @(
            @{
                Input = (ConvertTo-SecureString 'SuperSecretString' -AsPlainText -Force)
                Output = 'SuperSecretString'
            }
        )
    }
    TestGroup SecureStringInput

    Write-Host
    It "StandardInput" {
        $Input = (ConvertTo-SecureString 'SuperSecretString' -AsPlainText -Force -OutBuffer 1)
        $Input | Should -BeOfType [securestring]
        $Output = ConvertFrom-SecureString $Input
        AutoEnumerate $Output | Should -HaveCount 1
        AutoEnumerate $Output | Should -BeOfType [string]
        $Output.Length -eq 524 | Should -BeTrue
    }

    It "Non-Terminating Errors" {
        $ScriptBlock = { ConvertFrom-SecureString (ConvertTo-SecureString 'SuperSecretString' -AsPlainText -Force) -AsPlainText -ErrorAction SilentlyContinue }
        $ScriptBlock | Should -Not -Throw
        $Output = Invoke-Expression $ScriptBlock.ToString() -ErrorVariable ErrorObjects
        $ErrorObjects | Should -HaveCount 1
        $Output | Should -HaveCount (1 - $ErrorObjects.Count)
        foreach ($ErrorObject in $ErrorObjects) {
            [System.Management.Automation.ErrorRecord] $ErrorRecord = $null
            if ($ErrorObject -is [System.Management.Automation.ErrorRecord]) { $ErrorRecord = $ErrorObject }
            else { $ErrorRecord = $ErrorObject.ErrorRecord }

            Test-ErrorOutput $ErrorRecord
        }
    }

    It "Terminating Errors" {
        $ScriptBlock = { ConvertFrom-SecureString (ConvertTo-SecureString 'SuperSecretString' -AsPlainText -Force) -AsPlainText -ErrorAction Stop }
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
