function Get-KPSafeconnection {
    [cmdletbinding()]
    Param(
        [Parameter()]
        $Name = $Script:Config.DefaultSafe,
        [Parameter(dontshow)]
        $ConnectionsFolder = $($Script:Config.ConnectionsFolder)
    )
    $FilePath = "$ConnectionsFolder\$Name.ps1"
    If (-not(Test-Path -Path $FilePath)){
        Throw "No Safe connection exists at $filepath, use New-KPSafeConnection to create a connection file"
    }
    $Config = . $FilePath

    if ($config.InteractivePassword){
        $config | Add-Member -MemberType ScriptProperty -Name 'Credential' -Value {Get-Credential -Message "Enter the password for the KeyPass Database at:  $($This.FilePath)" -UserName " "}
    }
    Else{
        $config | Add-Member -MemberType ScriptProperty -Name 'Credential' -Value {Import-Clixml -Path $config.CredentialFile}
    }
    $KPSessionParams = @{
        FilePath = $Config.FilePath
        KeyFile = $Config.KeyFile
        Credential = $Config.Credential
        WindowsAuthentication = $Config.WindowsAuthentication
    }
    Write-Verbose ($KPSessionParams | Out-String)
    Return New-KPSession @KPSessionParams
}
