function Search-KPDatabase {
    [cmdletbinding()]
    param(
        [Parameter()]
            $KPSession = $Script:KPSession,
        [Parameter(Mandatory)]
            [String]$SearchString,
        [Parameter()]
        [ValidateSet("Titles","UserNames","Passwords","Urls","Notes","Other","StringNames","Tags","Uuids","GroupNames")]
            [Array]$SearchFields = @("Titles"),
        [Parameter()]
            $Group,
        [Parameter()]
            [switch]$regex
        
    )
    $KPSession.open()
    $Results = [KeePassLib.PwGroup]::new().Entries

    $Searcher = [KeePassLib.SearchParameters]::None
    $Searcher.SearchString = $SearchString
    Foreach($Field in $SearchFields){
        $SearchFieldFlag = "Searchin$Field"
        $Searcher.$SearchFieldFlag = $true
    }
    $KPSession.KPDatabase.RootGroup.SearchEntries($Searcher,$Results)
    $Entries = [System.Collections.ArrayList]::new()
    foreach ($Result in $Results){
        $entries.Add(($KPSession.KPDatabase.RootGroup.FindEntry($Result.uuid,$true))) | Out-Null
    }
    $KPSession.close()
    If ($Group){
        $Entries = $Entries | Where {$_.ParentGroup.Name -eq $Group}
    }
    Return $Entries
}
