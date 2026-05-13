$path = "c:\freelancer\lib\features\host\presentation\listing_management_screen.dart"
$content = Get-Content $path
$keepBefore = $content[0..288]
$keepAfter = $content[303..($content.Count - 1)]
$newContent = $keepBefore + $keepAfter
$newContent | Set-Content $path
