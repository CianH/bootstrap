function push-project( $project )
{
    $path = "~/Documents/GitHub/plum/$project"
    if( -not( Test-Path $path ) )
    {        
        $path = (ls ~/Documents/GitHub -Filter "$project*" | select -First 1).FullName
    }    
    pushd $path
}

New-Alias -Name pp -Value push-project