<#
.SYNOPSIS
    Converts .NET objects into a series of character-separated value (CSV) strings.
.DESCRIPTION
    The `ConvertTo-CSV` cmdlet returns a series of character-separated value (CSV) strings that represent the objects that you submit. You can then use the `ConvertFrom-Csv` cmdlet to recreate objects from the CSV strings. The objects converted from CSV are string values of the original objects that contain property values and no methods.
    You can use the `Export-Csv` cmdlet to convert objects to CSV strings. `Export-CSV` is similar to `ConvertTo-CSV`, except that it saves the CSV strings to a file.
    The `ConvertTo-CSV` cmdlet has parameters to specify a delimiter other than a comma or use the current culture as the delimiter.
.PARAMETER InputObject
    Specifies the objects that are converted to CSV strings. Enter a variable that contains the objects or type a command or expression that gets the objects. You can also pipe objects to `ConvertTo-CSV`.
.PARAMETER Delimiter
    Specifies the delimiter to separate the property values in CSV strings. The default is a comma (`,`). Enter a character, such as a colon (`:`). To specify a semicolon (`;`) enclose it in single quotation marks.
    If you specify a character other than the actual string delimiter in the file, `ConvertFrom-Csv` can't create the objects from the CSV strings and returns the CSV strings.
.PARAMETER UseCulture
    Uses the list separator for the current culture as the item delimiter. To find the list separator for a culture, use the following command: `(Get-Culture).TextInfo.ListSeparator`.
.PARAMETER IncludeTypeInformation
    When this parameter is used the first line of the output contains #TYPE followed by the fully qualified name of the object type. For example, #TYPE System.Diagnostics.Process.
    This parameter was introduced in PowerShell 6.0.
.PARAMETER NoTypeInformation
    Removes the #TYPE information header from the output. This parameter became the default in PowerShell 6.0 and is included for backwards compatibility.
.PARAMETER ArrayDelimiter
    Specifies the delimiter that separates the items in arrays.
.EXAMPLE
    PS >Get-Process -Name pwsh | ConvertTo-Csv -NoTypeInformation
    "Name","SI","Handles","VM","WS","PM","NPM","Path","Parent","Company","CPU","FileVersion", ...
    "pwsh","8","950","2204001161216","100925440","59686912","67104", ...

    The `Get-Process` cmdlet gets the Process object and uses the Name parameter to specify the PowerShell process. The process object is sent down the pipeline to the `ConvertTo-CSV` cmdlet. The `ConvertTo-CSV` cmdlet converts the object to CSV strings. The NoTypeInformation parameter removes the #TYPE information header from the CSV output and is not required in PowerShell 6.
.EXAMPLE
    PS >$Date = Get-Date
    PS >ConvertTo-Csv -InputObject $Date -Delimiter ';' -NoTypeInformation
    "DisplayHint";"DateTime";"Date";"Day";"DayOfWeek";"DayOfYear";"Hour";"Kind";"Millisecond";"Minute";"Month";"Second";"Ticks";"TimeOfDay";"Year"
    "DateTime";"Friday, January 4, 2019 14:40:51";"1/4/2019 00:00:00";"4";"Friday";"4";"14";"Local";"711";"40";"1";"51";"636822096517114991";"14:40:51.7114991";"2019"</dev:code>

    The `Get-Date` cmdlet gets the DateTime object and saves it in the `$Date` variable. The `ConvertTo-Csv` cmdlet converts the DateTime object to strings. The InputObject parameter uses the DateTime object stored in the `$Date` variable. The Delimiter parameter specifies a semicolon to separate the string values. The NoTypeInformation parameter removes the #TYPE information header from the CSV output and is not required in PowerShell 6.
.EXAMPLE
    PS >(Get-Culture).TextInfo.ListSeparator
    PS >Get-WinEvent -LogName 'PowerShellCore/Operational' | ConvertTo-Csv -UseCulture -NoTypeInformation
    ,
    "Message","Id","Version","Qualifiers","Level","Task","Opcode","Keywords","RecordId", ...
    "Error Message = System error""4100","1",,"3","106","19","0","31716","PowerShellCore", ...

    The `Get-Culture` cmdlet uses the nested properties TextInfo and ListSeparator and displays the current culture's default list separator. The `Get-WinEvent` cmdlet gets the event log objects and uses the LogName parameter to specify the log file name. The event log objects are sent down the pipeline to the `ConvertTo-Csv` cmdlet. The `ConvertTo-Csv` cmdlet converts the event log objects to a series of CSV strings. The UseCulture parameter uses the current culture's default list separator as the delimiter. The NoTypeInformation parameter removes the #TYPE information header from the CSV output and is not required in PowerShell 6.
.EXAMPLE
    PS >Get-Date | ConvertTo-Csv -QuoteFields "DateTime","Date"
    DisplayHint,"DateTime","Date",Day,DayOfWeek,DayOfYear,Hour,Kind,Millisecond,Minute,Month,Second,Ticks,TimeOfDay,Year
    DateTime,"Thursday, August 22, 2019 11:27:34 AM","8/22/2019 12:00:00 AM",22,Thursday,234,11,Local,569,27,8,34,637020700545699784,11:27:34.5699784,2019

    Convert to CSV with quotes around two columns
.EXAMPLE
    PS >Get-Date | ConvertTo-Csv -UseQuotes AsNeeded
    DisplayHint,DateTime,Date,Day,DayOfWeek,DayOfYear,Hour,Kind,Millisecond,Minute,Month,Second,Ticks,TimeOfDay,Year
    DateTime,"Thursday, August 22, 2019 11:31:00 AM",8/22/2019 12:00:00 AM,22,Thursday,234,11,Local,713,31,8,0,637020702607132640,11:31:00.7132640,2019

    Convert to CSV with quotes only when needed
.EXAMPLE
    PS >$person1 = @{
        Name = 'John Smith'
        Number = 1
    }
    PS >$person2 = @{
        Name = 'Jane Smith'
        Number = 2
    }
    PS >$allPeople = $person1, $person2
    PS >$allPeople | ConvertTo-Csv
    "Name","Number"
    "John Smith","1"
    "Jane Smith","2"

    Convert hashtables to CSV
.EXAMPLE
    PS >$allPeople | Add-Member -Name ExtraProp -Value 42
    PS >$allPeople | ConvertTo-Csv
    "Name","Number","ExtraProp"
    "John Smith","1","42"
    "Jane Smith","2","42"

    Each hashtable has a property named `ExtraProp` added by `Add-Member` and then converted to CSV. You can see `ExtraProp` is now a header in the output.
    If an added property has the same name as a key from the hashtable, the key takes precedence and only the key is converted to CSV.
.INPUTS
    System.Security.SecureString
    
    You can pipe a SecureString object to this cmdlet.
.OUTPUTS
    System.String
    
    This cmdlet returns the created plain text string.
.NOTES
    To create a secure string from characters that are typed at the command prompt, use the AsSecureString parameter of the Read-Host cmdlet.
    When you use the Key or SecureKey parameters to specify a key, the key length must be correct. For example, a key of 128 bits can be specified as a byte array of 16 decimal numerals. Similarly, 192-bit and 256-bit keys correspond to byte arrays of 24 and 32 decimal numerals, respectively.
    Some characters, such as emoticons, correspond to several code points in the string that contains them. Avoid using these characters because they may cause problems and misunderstandings when used in a password.
.LINK
    https://go.microsoft.com/fwlink/?LinkID=135203
.LINK
    ConvertFrom-Csv
.LINK
    Export-Csv
.LINK
    Import-Csv
.LINK
    https://github.com/jasoth/Utility.PS
#>
function ConvertTo-Csv {
    [CmdletBinding(DefaultParameterSetName = 'DelimiterPath', HelpUri = 'https://go.microsoft.com/fwlink/?LinkID=135203', RemotingCapability = 'None')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [psobject]
        ${InputObject},

        [Parameter(ParameterSetName = 'Delimiter', Position = 1)]
        [ValidateNotNull()]
        [char]
        ${Delimiter},

        [Parameter(ParameterSetName = 'UseCulture')]
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

    begin {
        function Transform (${InputObject}, ${ArrayDelimiter}) {
            [bool] $ContainsArray = $false
            [System.Collections.Generic.List[object]] $SelectProperties = New-Object System.Collections.Generic.List[object]
            $Properties = ${InputObject} | Select-Object -First 1 | Get-Member -MemberType NoteProperty, Property, ScriptProperty
            foreach ($Property in $Properties) {
                if ($Property.Definition -like ("*``[``] {0}*" -f $Property.Name) -or $Property.Definition -like ("*List``[*``] {0}*" -f $Property.Name)) {
                    $SelectProperties.Add(@{ Name = $Property.Name; Expression = [scriptblock]::Create(('$_.{0} -join "{1}"' -f $Property.Name, ${ArrayDelimiter})) })
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
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
                $PSBoundParameters['OutBuffer'] = 1
            }

            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\ConvertTo-Csv', [System.Management.Automation.CommandTypes]::Cmdlet)
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
        if ($null -ne ${InputObject}) {
            $_ = Transform ${InputObject} ${ArrayDelimiter}
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
        try {
            $steppablePipeline.End()
        }
        catch {
            throw
        }
    }
    <#

    .ForwardHelpTargetName Microsoft.PowerShell.Utility\ConvertTo-Csv
    .ForwardHelpCategory Cmdlet

    #>
}
