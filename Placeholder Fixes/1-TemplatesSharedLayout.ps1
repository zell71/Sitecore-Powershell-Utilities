# 1- Script to Update the ID format in all the templates for shared Layout-

# specify your path here. It is most likely be page templates and page content
$startPath = "/sitecore/templates"
$loopCounter = 0
Get-ChildItem -Path $startPath -Version * -Recurse | ForEach-Object {
    $item = $_;

    Get-Rendering -Item $_ | ForEach-Object {
        $rendering = $_;
        $matches = [regex]::Matches($_.Placeholder, '(_[0-9a-fA-F]{8}[-][0-9a-fA-F]{4}[-][0-9a-fA-F]{4}[-][0-9a-fA-F]{4}[-][0-9a-fA-F]{12})')

        if ($matches.Success) {
            Write-Host "Match found in item - [$($item.Paths.FullPath)]"
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
            Set-Rendering -Item $item -Instance $rendering
        }
        else {
            # Write-Host "Record Not Matched for item number $loopCounter"
        }
        $loopCounter++
    }
}