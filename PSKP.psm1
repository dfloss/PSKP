param(
    [Parameter(Position=0)]
    [ValidateSet("Dev","Production")]
    $Mode = "Production"
)
#Get public and private function definition files while excluding tests
    $Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue | Where Name -NotMatch "\.Tests\.ps1$")
    $Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue | Where Name -NotMatch "\.Tests\.ps1$")

#Determine Keepass Install Path
If (-not $InstallLocation){
    $InstallLocation = (gci 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall', 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' `
    | Where Name -match "Keepass" |`
    Get-ItemProperty -Name 'InstallLocation').InstallLocation
}
If ($InstallLocation -eq $null){
    $InstallLocation = "$PSSCriptRoot\lib"
}

#Load Dependencies from install path
[Reflection.Assembly]::LoadFile("$InstallLocation\Keepass.exe")
[Reflection.Assembly]::LoadFile("$InstallLocation\KeePass.XmlSerializers.dll")

#Dot source the files
Foreach($import in @($Public + $Private)){
    Try{
        . $import.fullname
    }
    Catch{
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

#Module Variables
$Script:ModuleHome = $PSScriptRoot
$Script:Config = . "$PSScriptRoot\config.ps1"
if (Test-Path "$($Script:Config.ConnectionsFolder)\$($Script:Config.DefaultSafe).ps1"){
    $Script:KPSession = Get-KPSafeconnection -Name $Script:Config.DefaultSafe
}
Else{
    Write-Warning "No Default KeePass database connection has been created"
    if (Read-Host -Prompt "Would you like to create a default KeePass Database Connection?(Y/n)" -eq 'y'){
        New-KPSafeConnection -SafeName $Script:Config.DefaultSafe -Interactive
        $Script:KPSession = Get-KPSafeconnection -Name $Script:Config.DefaultSafe
    }
}


#register Argument Completers
$titleCompletion = {
    Get-KPEntries | ForEach-Object {
        [PSCustomOBject]@{
            Title = $_.Title
            Username = $_.UserName
        }
    } | Sort-Object Title | ForEach-Object {
        $ListText = If([String]::IsNullOrEmpty($_.Title)){"___BLANK___"}else{$_.Title}
        [System.Management.Automation.CompletionResult]::new("'$($_.Title)'",$ListText, 'ParameterValue',("$($_.Title)$($_.Username)"))
    }
}
Register-ArgumentCompleter -CommandName 'Get-KPCredential' -ParameterName 'Title' -ScriptBlock $titleCompletion
Register-ArgumentCompleter -CommandName 'Get-KPPassword' -ParameterName 'Title' -ScriptBlock $titleCompletion

if ($mode -match "Dev"){
    Export-ModuleMember -Function (@($Public + $Private)).Basename
}
else {
    #Export all public modules
    Export-ModuleMember -Function $Public.Basename
}