<#
function Read-Property{
    param($PropertyName, $Prompt, $DefaultValue, [Switch]$Secure)
    $ReadHostParams = @{}
    $Result = Read-Host -Prompt $Prompt
}
#>
[cmdletbinding()]
Param(
    [Parameter()]
        $Force
)
$Parameters = @{
    Path = "$PsScriptRoot\config.template.ps1"
    Destination = "$PSSCriptRoot\config.ps1"
    Force = $Force
}
Copy-Item -