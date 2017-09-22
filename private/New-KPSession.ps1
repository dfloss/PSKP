function New-KPSession {
    [cmdletbinding(DefaultParameterSetName="noPass")]
    Param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({Test-Path $_})]
        [Alias('KeepassDatabase')]
            $FilePath,
        [Parameter(ParameterSetName="Credential",ValueFromPipelineByPropertyName)]
            $Credential,
        [Parameter(ParameterSetName="Password",ValueFromPipelineByPropertyName)]
            $Password,
        [Parameter(ValueFromPipelineByPropertyName)]
            $KeyFile,
        [Parameter(ValueFromPipelineByPropertyName)]
            [Switch]$WindowsAuthentication
    )
    
    $kpDatabase = New-Object KeePassLib.PwDatabase
    $compositeKey = New-Object KeePassLib.Keys.CompositeKey
    $ioConnectionInfo = New-Object KeePassLib.Serialization.IOConnectionInfo
    $statusLogger = New-Object KeePassLib.Interfaces.NullStatusLogger

    #Set DatabasePath
    $ioConnectionInfo.Path = $FilePath

  #Add Authentication Keys if they're specified
    #Windows User  
    if ($WindowsUserValidation){
        $compositeKey.AddUserKey((New-Object KeePassLib.Keys.KcpUserAccount))
    }
    #Master Password
    Switch($PSCmdlet.ParameterSetName){
        {$_ -eq "Credential" -and $Credential -ne $null}{
            $kpPassword = $Credential.GetNetworkCredential().Password
            $compositeKey.AddUserKey((New-Object KeePassLib.Keys.KcpPassword($kpPassword)))
        }
        {$_ -eq "Password" -and $Password -ne $null}{
            $compositeKey.AddUserKey((New-Object KeePassLib.Keys.KcpPassword($Password)))
        }
    }
    #Keyfile
    if ($KeyFile){
        $compositeKey.AddUserKey((New-Object KeePassLib.Keys.KcpKeyFile($KeyFile)))
    }
    #assemble the return object
    $kpSession = [PSCustomObject]@{
        CompositeKey = $compositeKey
        IOConnectionInfo = $ioConnectionInfo
        StatusLogger = $statusLogger
        KPDatabase = $kpDatabase
    }
    #add open and close methods
    $Open = {
        $This.KPDatabase.Open($This.IOConnectionInfo,$This.CompositeKey,$This.StatusLogger)
    }
    $kpSession | Add-Member -MemberType ScriptMethod -Name "Open" -Value $Open
    $kpSession | Add-Member -MemberType ScriptMethod -Name "Close" -Value {$This.KPDatabase.Close()}
    Return $kpSession
}
