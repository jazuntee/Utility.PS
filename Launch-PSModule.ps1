param
(
    # Module to Launch
    [parameter(Mandatory=$false)]
    [string] $ModuleManifestPath = ".\src\Utility.PS.psd1",
    # Import Module into the same session
    [parameter(Mandatory=$false)]
    [switch] $NoNewWindow
)

if ($NoNewWindow) {
    Import-Module $ModuleManifestPath -PassThru
}
else {
    $strScriptBlock = 'Import-Module {0} -PassThru' -f $ModuleManifestPath
    #$strScriptBlock = '$PSModule = Import-Module {0} -PassThru; Get-Command -Module $PSModule' -f $ModuleManifestPath
    Start-Process powershell -ArgumentList ('-NoExit','-NoProfile','-EncodedCommand',[Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($strScriptBlock)))
    Start-Process pwsh -ArgumentList ('-NoExit','-NoProfile','-EncodedCommand',[Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($strScriptBlock)))
}
