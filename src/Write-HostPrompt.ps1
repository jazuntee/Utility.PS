<#
.SYNOPSIS
    Displays a PowerShell prompt for multiple fields or multiple choices.
.DESCRIPTION
    Displays a PowerShell prompt for multiple fields or multiple choices.
.EXAMPLE
    PS C:\>Write-HostPrompt "Prompt Caption" -Fields @("Field 1", "Field 2")
    Display simple prompt for 2 fields.
.EXAMPLE
    PS C:\>$IntegerField = New-Object System.Management.Automation.Host.FieldDescription -ArgumentList "Integer Field" -Property @{ HelpMessage = "Help Message for Integer Field" }
    PS C:\>$IntegerField.SetParameterType([int])
    PS C:\>$DateTimeField = New-Object System.Management.Automation.Host.FieldDescription -ArgumentList "DateTime Field" -Property @{ HelpMessage = "Help Message for DateTime Field" }
    PS C:\>$DateTimeField.SetParameterType([datetime])
    PS C:\>Write-HostPrompt "Prompt Caption" "Prompt Message" -Fields $IntegerField, $DateTimeField
    Display prompt for 2 type specific fields.
.EXAMPLE
    PS C:\>Write-HostPrompt "Prompt Caption" -Choices @("Choice &A", "Choice &B")
    Display simple prompt with 2 choices.
.EXAMPLE
    PS C:\>Write-HostPrompt "Prompt Caption" "Prompt Message" -DefaultChoice 1 -Choices @(
        New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList "Choice &A" -Property @{ HelpMessage = "Help Message for Choice A" }
        New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList "Choice &B" -Property @{ HelpMessage = "Help Message for Choice B" }
    )
    Display prompt with 2 choices and help messages.
.INPUTS
    System.Management.Automation.Host.FieldDescription
    System.Management.Automation.Host.ChoiceDescription
.OUTPUTS
    System.Collections.Generic.Dictionary[System.String,System.Management.Automation.PSObject]
    System.Int32
#>
function Write-HostPrompt {
    [CmdletBinding()]
    param
    (
        # Caption to preceed or title the prompt.
        [Parameter(Mandatory = $true, Position = 1)]
        [string] $Caption,
        # A message that describes the prompt.
        [Parameter(Mandatory = $false, Position = 2)]
        [string] $Message,
        # The fields in the prompt.
        [Parameter(Mandatory = $true, ParameterSetName = 'Fields', Position = 3, ValueFromPipeline = $true)]
        [System.Management.Automation.Host.FieldDescription[]] $Fields,
        # The choices the shown in the prompt.
        [Parameter(Mandatory = $true, ParameterSetName = 'Choices', Position = 3, ValueFromPipeline = $true)]
        [System.Management.Automation.Host.ChoiceDescription[]] $Choices,
        # The index of the label in the choices to make default.
        [Parameter(Mandatory = $false, ParameterSetName = 'Choices', Position = 4)]
        [int] $DefaultChoice = 0
    )

    begin {
        ## Create list to capture multiple fields or multiple choices.
        [System.Collections.Generic.List[System.Management.Automation.Host.FieldDescription]] $listFields = New-Object System.Collections.Generic.List[System.Management.Automation.Host.FieldDescription]
        [System.Collections.Generic.List[System.Management.Automation.Host.ChoiceDescription]] $listChoices = New-Object System.Collections.Generic.List[System.Management.Automation.Host.ChoiceDescription]
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Fields' {
                foreach ($Field in $Fields) { $listFields.Add($Field) }
            }
            'Choices' {
                foreach ($Choice in $Choices) { $listChoices.Add($Choice) }
            }
        }
    }

    end {
        try {
            switch ($PSCmdlet.ParameterSetName) {
                'Fields' { return $Host.UI.Prompt($Caption, $Message, $listFields.ToArray()) }
                'Choices' { return $Host.UI.PromptForChoice($Caption, $Message, $listChoices.ToArray(), $DefaultChoice - 1) + 1 }
            }
        }
        catch [System.Management.Automation.PSInvalidOperationException] {
            ## Write Non-Terminating Error When In Non-Interactive Mode.
            Write-Error -ErrorRecord $_ -CategoryActivity $MyInvocation.MyCommand
        }
    }
}
