<#
.SYNOPSIS
    Generate random key for securestring encryption.
.DESCRIPTION
    Generate random key for securestring encryption.
.EXAMPLE
    PS C:\>New-SecureStringKey
    Generate random 16 byte (128-bit) key.
.EXAMPLE
    PS C:\>$SecureKey = New-SecureStringKey -Length 32
    PS C:\>$SecureString = ConvertTo-SecureString "Super Secret String" -AsPlainText -Force
    PS C:\>$EncryptedSecureString = ConvertFrom-SecureString $SecureString -SecureKey $SecureKey
    PS C:\>$DecryptedSecureString = ConvertTo-SecureString $EncryptedSecureString -SecureKey $SecureKey
    PS C:\>ConvertFrom-SecureStringAsPlainText $DecryptedSecureString
    Generate random 32 byte (256-bit) key and use it to encrypt another string.
#>
function New-SecureStringKey {
    param
    (
        # Key length
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true)]
        [ValidateSet(16, 24, 32)]
        [int] $Length = 16
    )

    [byte[]] $Key = Get-Random -InputObject ((0..255)*$Length) -Count $Length
    [securestring] $SecureKey = ConvertTo-SecureString -String ([System.Text.Encoding]::ASCII.GetString($Key)) -AsPlainText -Force

    return $SecureKey
}
