function New-KPSafeConnection {
    [cmdletbinding(DefaultParameterSetName="Interactive")]
    Param(
        [Parameter(ParameterSetName="CommandLine",Mandatory)]
        [Parameter(ParameterSetName="Interactive",Mandatory=$false)]
        $SafeName,
        [Parameter(ParameterSetName="CommandLine",Mandatory)]
        #[ValidateScript({(Test-Path $_) -or $_ -eq $null})]
        $FilePath,
        [Parameter(ParameterSetName="CommandLine")]
        #[ValidateScript({(Test-Path $_) -or $_ -eq $null})]
        $KeyFile,
        [Parameter(ParameterSetName="CommandLine")]
        #[ValidateScript({(Test-Path $_) -or $_ -eq $null})]
        $CredentialFile,
        [Parameter(ParameterSetName="CommandLine")]
        [bool]$InteractivePassword = $false,
        [Parameter(ParameterSetName="CommandLine")]
        [bool]$WindowsAuthentication = $false,
        [Parameter(ParameterSetName="CommandLine")]
        [switch]$Force,
        [Parameter(ParameterSetName="Interactive")]
        [Switch]$Interactive,
        [Parameter(dontshow)]
        $ConnectionsFolder = $($Script:Config.ConnectionsFolder)
    )
    if ($Interactive){
        Function Prompt-Property{
        [cmdletbinding()]
        Param($Message,$DefaultValue,[switch]$isBool)

        $Response = Read-Host -Prompt $Message
        If ($Response -eq ""){
            Return $DefaultValue
        }
        else{
            If ($isBool){
                switch ($Response){
                    "y"{
                        Return $true
                    }
                    "n"{
                        Return $false
                    }
                    default{
                        write-Host "Please Enter y or n"
                        Prompt-Property  @PSBoundParameters
                    }
                }
            }
            else{
                Return $Response
            }
        }
    }
        Function Find-File{
        param($Filter,[switch]$mandatory)

        $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $OpenFileDialog.filter = $Filter
        $OpenFileDialog.ShowDialog() | Out-Null
        $FileName = $OpenFileDialog.filename
        if($FileName -eq "Cancel"){
            if ($mandatory){
                Throw "File Path Required for Connection"
            }
            else {
                return $null
            }
        }
        else{
            return $FileName
        }
    }

        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
        Write-Host -Object "Selec KeePass Database kdbx file" -ForegroundColor Green
        $FilePath = Find-File -Filter "Kdbx Files (*.kdbx)| *.kdbx" -Mandatory

        $SafeName = Prompt-Property -Message "Enter the name for this Keepass password safe connection (Default)" -DefaultValue "Default"
        if ($SafeName -eq ""){Throw "Must have non-empty name for KeePass Safe Connection"}
        if ((Read-Host -Prompt "Does this Database require a key file(y/N)") -eq "y"){
            $KeyFile = Find-File -Filter "Key Files (*.key)| *.key"
        }
        
        $InteractivePassword = Prompt-Property -Message "Would you like to be prompted for the master password when loading the database?`n Choose n if there is no password or if you wish to save the password to an encrypted xml file" -isBool -defaultValue $false
        
        if (-not $InteractivePassword){
            $CredMessage = "Would you like to use a save credential file (cliXML) for the master password? choose n only if there is no master password"
            if ((Read-Host -Prompt $CredMessage) -eq "y"){
                $CredentialFile = Find-File -Filter "KeyPass Key file (*.key)| *.key"
            }
        }
        $WindowsAuthentication = Prompt-Property -Message "Does the Keepass Database use Windows Authentication (y/N)" -DefaultValue $false -isBool
    }
    $SafeNameString = "'$SafeName'"
    $FilePathString = If($FilePath -eq $null){'$null'}else{"'$FilePath'"}
    $KeyFileString = If($KeyFile -eq $null){'$null'}else{"'$KeyFile'"}
    $CredentialFileString = If($CredentialFile -eq $null){'$null'}else{"'$CredentialFile'"}
    $WindowsAuthenticationString = "`$$($WindowsAuthentication.ToString())"
    $InteractivePasswordString = "`$$($InteractivePassword.ToString())"

    $connectionFile = @"
return [PSCustomObject]@{
    FilePath = $FilePathString #//Path to KDBX file
    KeyFile = $KeyFileString
    CredentialFile = $CredentialFileString
    InteractivePassword = $InterActivePasswordString
    WindowsAuthentication = $WindowsAuthenticationString
}
"@
    $ConnectionFilePath = "$ConnectionsFolder\$SafeName.ps1"
    if (-not(Test-Path $ConnectionFilePath) -or $Force){
        Set-Content -Path $connectionFilePath -Value $connectionFile -Force
        $ConnectionFilePath
    }
    else{
        if ((Read-Host -Prompt "$connectionFilePath already exists would you like to overwrite it?(y/N)") -eq 'y'){
            Set-Content -Path $connectionFilePath -Value $connectionFile
        }
    }
}