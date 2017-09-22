[PSCustomObject]@{
    FilePath = 'C:\Path\To\PasswordSafe.kdbx'
    KeyFile = $Null #If no Key file is in use, otherwise C:\Path\To\KeyFile.key
    CredentialFile = 'C:\Path\To\Credential.xml' #Path to a cliXML credential Object for use with Master password, use null is no master passsword is used
    InteractivePassword = $false #Use this switch if you would like to be prompted for the master password, will override the CredentialFile setting, leave $false if no master password is used or Credential File is used
    WindowsAuthentication = $false #Use this switch if you've enabled Windows user authentication for your
}