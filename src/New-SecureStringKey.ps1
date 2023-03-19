<#
.SYNOPSIS
    Generate random key for securestring encryption.

.EXAMPLE
    PS >New-SecureStringKey

    Generate random 16 byte (128-bit) key.

.EXAMPLE
    PS >$SecureKey = New-SecureStringKey -Length 32
    PS >$SecureString = ConvertTo-SecureString "Super Secret String" -AsPlainText -Force
    PS >$EncryptedSecureString = ConvertFrom-SecureString $SecureString -SecureKey $SecureKey
    PS >$DecryptedSecureString = ConvertTo-SecureString $EncryptedSecureString -SecureKey $SecureKey
    PS >ConvertFrom-SecureStringAsPlainText $DecryptedSecureString

    Generate random 32 byte (256-bit) key and use it to encrypt another string.

.INPUTS
    System.Int32

.LINK
    https://github.com/jasoth/Utility.PS
#>
function New-SecureStringKey {
    [CmdletBinding()]
    param (
        # Key length
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true)]
        [ValidateSet(16, 24, 32)]
        [int] $Length = 16
    )

    [byte[]] $Key = Get-Random -InputObject ((0..255)*$Length) -Count $Length
    [securestring] $SecureKey = ConvertTo-SecureString -String ([System.Text.Encoding]::ASCII.GetString($Key)) -AsPlainText -Force

    return $SecureKey
}
