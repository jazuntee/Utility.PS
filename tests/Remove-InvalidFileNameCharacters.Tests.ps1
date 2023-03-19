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

Describe 'Remove-InvalidFileNameCharacters' {

    class DefaultReplacement {
        [string] $CommandName = 'Remove-InvalidFileNameCharacters'
        [hashtable] $BoundParameters = @{}
        [type] $ExpectedInputType = [string]
        [hashtable[]] $IO = @(
            @{
                Input  = 'à/1\b?2|ć*3<d>4 ē'
                Output = 'à-1-b-2-ć-3-d-4 ē'
            }
            @{
                Input  = '/\?|*<>'
                Output = '-------'
            }
        )
    }
    TestGroup DefaultReplacement

    class NoDiacritic {
        [string] $CommandName = 'Remove-InvalidFileNameCharacters'
        [hashtable] $BoundParameters = @{
            ReplacementCharacter = ''
            RemoveDiacritics     = $true
        }
        [type] $ExpectedInputType = [string]
        [hashtable[]] $IO = @(
            @{
                Input  = 'à/1\b?2|ć*3<d>4 ē'
                Output = 'a1b2c3d4 e'
            }
            @{
                Input  = '/\?|*<>'
                Output = ''
            }
        )
    }
    TestGroup NoDiacritic
}
