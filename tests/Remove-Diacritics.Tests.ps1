[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string] $ModulePath = ".\src\*.psd1"
)

BeforeDiscovery {
    ## Load Test Helper Functions
    . (Join-Path $PSScriptRoot 'TestCommon.ps1')
}

BeforeAll {
    $CriticalError = $null
    $PSModule = Import-Module $ModulePath -Force -PassThru -ErrorVariable CriticalError
    if ($CriticalError) { throw $CriticalError }

    ## Load Test Helper Functions
    . (Join-Path $PSScriptRoot 'TestCommon.ps1')
}

Describe 'Remove-Diacritics' {

    class DefaultReplacement {
        [string] $CommandName = 'Remove-Diacritics'
        [hashtable] $BoundParameters = @{}
        [type] $ExpectedInputType = [string]
        [hashtable[]] $IO = @(
            @{
                Input  = 'àáâãäåÀÁÂÃÄÅ'
                Output = 'aaaaaaAAAAAA'
            }
            @{
                Input  = 'çćĉċčÇĆĈĊČ'
                Output = 'cccccCCCCC'
            }
        )
    }
    TestGroup DefaultReplacement
}
