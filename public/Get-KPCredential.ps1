function Get-KPCredential {
    [OutputType([PSCredential])]
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
        $ParamHash = @{}
        $PSBoundParameters.GetEnumerator() | %{
           $ParamHash.add($_.Key,$_.Value)
        }
        $KPSession = [PSCustomObject]$ParamHash | New-KPSession
    }

    $Entries = Search-KPDatabase -KPSession $KPSession -SearchString $Title -SearchFields 'Titles' -Group $Group
    
    $Entries | ForEach-Object {
        $UserName = $_.Strings.ReadSafe('UserName')
        $Password = $_.Strings.ReadSafe('Password')
        $SecPassword = $Password | ConvertTo-SecureString -AsPlainText -Force
        [PSCredential]::new($UserName,$SecPassword)
    }
}
