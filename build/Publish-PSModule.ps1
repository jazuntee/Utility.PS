param
(
	# Path to Module
    [parameter(Mandatory=$false)]
    [string] $ModulePath = ".\release\Utility.PS\1.0.0.3",
    # API Key for PowerShell Gallery
    [parameter(Mandatory=$true)]
    [string] $NuGetApiKey
)

Publish-Module -Path $ModulePath -NuGetApiKey $NuGetApiKey
