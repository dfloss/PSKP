function Get-KPEntries {
    [cmdletbinding(DefaultParameterSetName='Session')]
    param(
        [Parameter(ParameterSetName='Session')]
            $KPSession = $Script:KPSession,
        [Parameter()]
            [Switch]$IncludePasswords,
        [Parameter()]
            [Switch]$Raw
    )
    If ($PSCmdlet.ParameterSetName -eq "Password" -or $PSCmdlet.ParameterSetName -eq "Credential"){
        $ParamHash = @{}
        $PSBoundParameters.GetEnumerator() | %{
           $ParamHash.add($_.Key,$_.Value)
        }
        $KPSession = [PSCustomObject]$ParamHash | New-KPSession
    }
    If (-not $KPSession.KPDatabase.IsOpen){
        $KPSession.Open()
    }
    $Results = $KPSession.KPDatabase.RootGroup.GetObjects($True,$True)
    $KPSession.Close()
    If ($Raw){
        Return $Results
    }
    
    Foreach($Entry in $Results){
        $ReturnObject = [PSCustomObject]@{
            UUID = $Entry.uuid
            Title = $Entry.Strings.ReadSafe('Title')
            Username = $Entry.Strings.ReadSafe('UserName')
            URL = $Entry.Strings.ReadSafe('URL')
            Notes = $Entry.Strings.ReadSafe('Notes')
            Tags = $Entry.Tags
        }
        If ($IncludePasswords){
            $ReturnObject | Add-Member -Name 'Password' -Value ($entry.Strings.ReadSafe('Password')) -MemberType NoteProperty
        }
        Write-Output $ReturnObject
    }
}
