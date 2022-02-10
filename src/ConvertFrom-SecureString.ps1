# .ExternalHelp Utility.PS-help.xml
<#
.SYNOPSIS
    Converts a secure string to an encrypted standard string.
.DESCRIPTION
    The ConvertFrom-SecureString cmdlet converts a secure string ( System.Security.SecureString ) to an encrypted standard string ( System.String ). Unlike a secure string, an encrypted standard string can be saved in a file for later use. The encrypted standard string can be converted back to a secure string by using the ConvertTo-SecureString cmdlet.

    If an encryption key is specified by using the Key or SecureKey parameters, the Advanced Encryption Standard (AES) encryption algorithm is used. The specified key must have a length of 128, 192, or 256 bits, because those are the key lengths supported by the AES encryption algorithm. If no key is specified, the Windows Data Protection API (DPAPI) is used to encrypt the standard string representation.
.PARAMETER AsPlainText
    When set, ConvertFrom-SecureString will convert secure strings to the decrypted plaintext string as output.
.PARAMETER Key
    Specifies the encryption key as a byte array.
.PARAMETER SecureKey
    Specifies the encryption key as a secure string. The secure string value is converted to a byte array before being used as the key.
.PARAMETER SecureString
    Specifies the secure string to convert to an encrypted standard string.
.EXAMPLE
    Example 1: Create a secure string
    PS C:\>$SecureString = Read-Host -AsSecureString
    This command creates a secure string from characters that you type at the command prompt. After entering the command, type the string you want to store as a secure string. An asterisk (*) is displayed to represent each character that you type.
.EXAMPLE
    Example 2: Convert a secure string to an encrypted standard string
    PS C:\>$StandardString = ConvertFrom-SecureString $SecureString
    This command converts the secure string in the $SecureString variable to an encrypted standard string. The resulting encrypted standard string is stored in the $StandardString variable.
.EXAMPLE
    Example 3: Convert a secure string to an encrypted standard string with a 192-bit key
    PS C:\>$Key = (3,4,2,3,56,34,254,222,1,1,2,23,42,54,33,233,1,34,2,7,6,5,35,43)
    PS C:\>$StandardString = ConvertFrom-SecureString $SecureString -Key $Key
    These commands use the AES algorithm to convert the secure string stored in the $SecureString variable to an encrypted standard string with a 192-bit key. The resulting encrypted standard string is stored in the $StandardString variable.
    The first command stores a key in the $Key variable. The key is an array of 24 digits, all of which are less than 256.
    Because each digit represents a byte (8 bits), the key has 24 digits for a total of 192 bits (8 x 24). This is a valid key length for the AES algorithm. Each individual value is less than 256, which is the maximum value that can be stored in an unsigned byte.
    The second command uses the key in the $Key variable to convert the secure string to an encrypted standard string.
.INPUTS
    System.Security.SecureString
.OUTPUTS
    System.String
.NOTES
    To create a secure string from characters that are typed at the command prompt, use the AsSecureString parameter of the Read-Host cmdlet.
    When you use the Key or SecureKey parameters to specify a key, the key length must be correct. For example, a key of 128 bits can be specified as a byte array of 16 decimal numerals. Similarly, 192-bit and 256-bit keys correspond to byte arrays of 24 and 32 decimal numerals, respectively.
    Some characters, such as emoticons, correspond to several code points in the string that contains them. Avoid using these characters because they may cause problems and misunderstandings when used in a password.
.LINK
    https://go.microsoft.com/fwlink/?LinkID=113287
.LINK
    ConvertTo-SecureString
.LINK
    Read-Host
.LINK
    https://github.com/jasoth/Utility.PS
#>
function ConvertFrom-SecureString {
    [CmdletBinding(DefaultParameterSetName = 'Secure', HelpUri = 'https://go.microsoft.com/fwlink/?LinkID=113287')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [securestring]
        ${SecureString},

        [Parameter(ParameterSetName = 'PlainText')]
        [switch]
        ${AsPlainText},

        [Parameter(ParameterSetName = 'Secure', Position = 1)]
        [securestring]
        ${SecureKey},

        [Parameter(ParameterSetName = 'Open')]
        [byte[]]
        ${Key}
    )

    begin {
        ## Command Extension
        if ($PSBoundParameters.ContainsKey('AsPlainText') -and $PSVersionTable.PSVersion -lt [version]'7.0') {
            if (${AsPlainText}) { return }
            else { [void] $PSBoundParameters.Remove('AsPlainText') }
        }

        ## Resume Command
        try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
                $PSBoundParameters['OutBuffer'] = 1
            }
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Security\ConvertFrom-SecureString', [System.Management.Automation.CommandTypes]::Cmdlet)
            $scriptCmd = { & $wrappedCmd @PSBoundParameters }
            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        }
        catch {
            throw
        }
    }

    process {
        ## Command Extension
        if (${AsPlainText} -and $PSVersionTable.PSVersion -lt [version]'7.0') {
            try {
                [IntPtr] $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
                Write-Output ([System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($BSTR))
            }
            finally {
                [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
            }
            return
        }

        ## Resume Command
        try {
            $steppablePipeline.Process($_)
        }
        catch {
            throw
        }
    }

    end {
        ## Command Extension
        if (${AsPlainText} -and $PSVersionTable.PSVersion -lt [version]'7.0') { return }

        ## Resume Command
        try {
            $steppablePipeline.End()
        }
        catch {
            throw
        }
    }
    <#

    .ForwardHelpTargetName Microsoft.PowerShell.Security\ConvertFrom-SecureString
    .ForwardHelpCategory Cmdlet

    #>
}
