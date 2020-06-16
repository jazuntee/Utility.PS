# .ExternalHelp Utility.PS-help.xml
function ConvertFrom-SecureString {
    [CmdletBinding(DefaultParameterSetName = 'Secure', HelpUri = 'https://go.microsoft.com/fwlink/?LinkID=113287')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [securestring]
        ${SecureString},

        [Parameter(ParameterSetName = 'PlainText')]
        [switch]
        ${AsPlainText},

        [Parameter(ParameterSetName = 'PlainText')]
        [switch]
        ${Force},

        [Parameter(ParameterSetName = 'Secure', Position = 1)]
        [securestring]
        ${SecureKey},

        [Parameter(ParameterSetName = 'Open')]
        [byte[]]
        ${Key}
    )

    begin {
        ## Command Extension
        if (${AsPlainText}) {
            if (!${Force}) {
                ## Non-Terminating Error
                $Exception = New-Object ArgumentException -ArgumentList 'The system cannot protect plain text output. To suppress this warning and convert a SecureString to plain text, reissue the command specifying the Force parameter.'
                Write-Error -Exception $Exception -Category ([System.Management.Automation.ErrorCategory]::InvalidArgument) -CategoryActivity $MyInvocation.MyCommand -ErrorId 'ConvertSecureStringFailureForceRequired' -TargetObject ${SecureString} #-ErrorAction Stop
            }
            return
        }

        ## Remove extra parameters (not needed because with these parameters the original command never executes)
        #if ($PSBoundParameters.ContainsKey('AsPlainText')) { [void] $PSBoundParameters.Remove('AsPlainText') }
        #if ($PSBoundParameters.ContainsKey('Force')) { [void] $PSBoundParameters.Remove('Force') }

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
        if (${AsPlainText}) {
            if (${Force}) {
                try {
                    [IntPtr] $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
                    Write-Output ([System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($BSTR))
                }
                finally {
                    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
                }
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
        if (${AsPlainText}) { return }

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
