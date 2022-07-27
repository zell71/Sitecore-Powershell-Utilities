# this script fixes placeholders in both Shared and Final Layout for the bublished item version.
# NOTE: this will not work on the item in the Start Path, you will need to run the FixPublishedVersion-Single_Item.ps1 script

$startPath = "/sitecore/content/bupacomau/home"
$ritems = @()
Get-ChildItem -Path $startPath -Recurse | ForEach-Object {
    $item = $_;
    $renderings =  Get-Rendering -Item $item
    # check if the item has renderings, i.e. not a datasource item
    if($renderings) {
        $webVersion = Get-Item -Path web: -ID $item.ID -ErrorAction SilentlyContinue
        if ($webVersion) {
          $minVersion = $webVersion.Version.Number - $count
          $ritems += Get-Item -Path master: -ID $_.ID -Version * | Where-Object { $_.Version.Number -eq $minVersion }
        }
    }    
}

$ritems | ForEach-Object {
    $vItem = $_;
    $version = $_.Version.Number;
    $sharedLayoutRenderings =  Get-Rendering -Item $_
    $sharedLayoutRenderings | ForEach-Object {
        $rendering = $_;
        $matches = [regex]::Matches($_.Placeholder, '(_[0-9a-fA-F]{8}[-][0-9a-fA-F]{4}[-][0-9a-fA-F]{4}[-][0-9a-fA-F]{4}[-][0-9a-fA-F]{12})')

        if ($matches.Success) {
            Write-Host "Match found in Shared Layout for item - [$($vItem.Paths.FullPath)][$version]"
            Write-Host "Old Placeholder - [$($rendering.Placeholder)]"

            $newPlaceholder = $rendering.Placeholder

            $matches | ForEach-Object {
                $renderingId = $_.Value
                $newPlaceholder = $newPlaceholder.Replace($renderingId, "{$($renderingId.ToUpper())}-0")
            }

            $newPlaceholder = $newPlaceholder.Replace('{_', "-{")
            Write-Host "New Placeholder - [$($newPlaceholder)]"

            # comment following 2 lines if you don't want to do replacement, but want to have log of upcoming placeholder changes
            $rendering.Placeholder = $newPlaceholder
            Set-Rendering -Item $vItem -Instance $rendering
        }
    }
    
    $finalLayoutRenderings =  Get-Rendering -Item $_ -FinalLayout
    $finalLayoutRenderings | ForEach-Object {
        $rendering = $_;
        $matches = [regex]::Matches($_.Placeholder, '(_[0-9a-fA-F]{8}[-][0-9a-fA-F]{4}[-][0-9a-fA-F]{4}[-][0-9a-fA-F]{4}[-][0-9a-fA-F]{12})')

        if ($matches.Success) {
            Write-Host "Match found in Final Layout for item - [$($vItem.Paths.FullPath)][$version]"
            Write-Host "Old Placeholder - [$($rendering.Placeholder)]"

            $newPlaceholder = $rendering.Placeholder

            $matches | ForEach-Object {
                $renderingId = $_.Value
                $newPlaceholder = $newPlaceholder.Replace($renderingId, "{$($renderingId.ToUpper())}-0")
            }

            $newPlaceholder = $newPlaceholder.Replace('{_', "-{")
            Write-Host "New Placeholder - [$($newPlaceholder)]"

            # comment following 2 lines if you don't want to do replacement, but want to have log of upcoming placeholder changes
            $rendering.Placeholder = $newPlaceholder
            Set-Rendering -Item $vItem -Instance $rendering -FinalLayout
        }
    }
}