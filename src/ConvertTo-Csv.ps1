# .ExternalHelp Utility.PS-help.xml
function ConvertTo-Csv {
    [CmdletBinding(DefaultParameterSetName='DelimiterPath', HelpUri='https://go.microsoft.com/fwlink/?LinkID=135203', RemotingCapability='None')]
    param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [psobject]
        ${InputObject},

        [Parameter(ParameterSetName='Delimiter', Position=1)]
        [ValidateNotNull()]
        [char]
        ${Delimiter},

        [Parameter(ParameterSetName='UseCulture')]
        [switch]
        ${UseCulture},

        [Alias('ITI')]
        [switch]
        ${IncludeTypeInformation},

        [Alias('NTI')]
        [switch]
        ${NoTypeInformation},

        [ValidateNotNull()]
        [string]
        ${ArrayDelimiter} = "`r`n"
        )

    begin
    {
        function Transform (${InputObject}, ${ArrayDelimiter}) {
            [bool] $ContainsArray = $false
            [System.Collections.Generic.List[object]] $SelectProperties = New-Object System.Collections.Generic.List[object]
            $Properties = ${InputObject} | Select-Object -First 1 | Get-Member -MemberType NoteProperty,Property,ScriptProperty
            foreach ($Property in $Properties) {
                if ($Property.Definition -like ("*``[``] {0}*" -f $Property.Name) -or $Property.Definition -like ("*List``[*``] {0}*" -f $Property.Name)) {
                    $SelectProperties.Add(@{ Name = $Property.Name; Expression = [scriptblock]::Create(('$_.{0} -join "{1}"' -f $Property.Name,${ArrayDelimiter})) })
                    $ContainsArray = $true
                }
                else {
                    $SelectProperties.Add($Property.Name)
                }
            }
            if ($ContainsArray) { return ${InputObject} | Select-Object -Property $SelectProperties.ToArray() }
            else { return ${InputObject} }
        }

        ## Command Extension
        if ($null -ne ${InputObject}) {
            $PSBoundParameters['InputObject'] = Transform ${InputObject} ${ArrayDelimiter}
        }

        ## Remove extra parameters
        if ($PSBoundParameters.ContainsKey('ArrayDelimiter')) { [void] $PSBoundParameters.Remove('ArrayDelimiter') }

        ## Resume Command
        try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }

            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\ConvertTo-Csv', [System.Management.Automation.CommandTypes]::Cmdlet)
            $scriptCmd = {& $wrappedCmd @PSBoundParameters }

            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        } catch {
            throw
        }
    }

    process
    {
        ## Command Extension
        if ($null -ne ${InputObject}) {
            $_ = Transform ${InputObject} ${ArrayDelimiter}
        }

        ## Resume Command
        try {
            $steppablePipeline.Process($_)
        } catch {
            throw
        }
    }

    end
    {
        try {
            $steppablePipeline.End()
        } catch {
            throw
        }
    }
    <#

    .ForwardHelpTargetName Microsoft.PowerShell.Utility\ConvertTo-Csv
    .ForwardHelpCategory Cmdlet

    #>
}
