$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "New-KpSession" {
    It "Should Create a new Keepass DatabaseObject" {
        $true | Should Be $false
    }
}
