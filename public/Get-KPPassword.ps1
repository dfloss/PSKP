function Get-KpPassword {
    [OutputType([String])]
    [cmdletbinding(DefaultParameterSetName="Session")]
    param(
        [Parameter(Mandatory)]
            $Title,
        [Parameter()]
            $Group,
        [Parameter(ParameterSetName='Session')]
            $KPSession = $Script:KPSession,
        [Parameter(ParameterSetName="Credential")]
        [Parameter(ParameterSetName="Password")]
        [ValidateScript({Test-Path $_})]
        [Alias('KeepassDatabase')]
            $FilePath,
        [Parameter(ParameterSetName="Credential")]
            $Credential,
        [Parameter(ParameterSetName="Password")]
            $Password,
        [Parameter(ParameterSetName="Credential")]
        [Parameter(ParameterSetName="Password")]
            $KeyFile,
        [Parameter(ParameterSetName="Credential")]
        [Parameter(ParameterSetName="Password")]
            [Switch]$WindowsAuthentication
    )
    If ($PSCmdlet.ParameterSetName -eq "Password" -or $PSCmdlet.ParameterSetName -eq "Credential"){
        $KPSession = [PSCustomObject]$PSBoundParameters | New-KPSession
    }

    $Entries = Search-KPDatabase -KPSession $KPSession -SearchString $Title -SearchFields 'Titles'
    If ($Group){
        $Entries = $Entries | Where {$_.ParentGroup.Name -eq $Group}
    }
    Return $Entries | ForEach-Object {$_.Strings.ReadSafe("Password")}   
}
