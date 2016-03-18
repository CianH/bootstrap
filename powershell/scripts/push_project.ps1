function push-project( $project )
{
    $path = "$env:USERPROFILE\Documents\GitHub\$project"
    if( -not( Test-Path $path ) )
    {        
        $path = (ls $env:USERPROFILE\Documents\GitHub -Filter "$project*" | select -First 1).FullName
        if ( -not $path )
        {
            $path = (ls $env:USERPROFILE\Documents\GitHub\*\* -Filter "$project*" | select -First 1).FullName
        }
    }    
    pushd $path
}

Set-Alias pp push-project