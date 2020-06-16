param
(
    # Path to Module
    [Parameter(Mandatory = $false)]
    [string] $ModulePath = ".\release\Utility.PS\1.0.2",
    # API Key for PowerShell Gallery
    [Parameter(Mandatory = $true)]
    [string] $NuGetApiKey
)

Publish-Module -Path $ModulePath -NuGetApiKey $NuGetApiKey
