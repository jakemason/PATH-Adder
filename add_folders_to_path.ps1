param(
  [switch]$commit = $false
)

# Allow easy customization of colors
function Format-Color([hashtable] $Colors = @{}, [switch] $SimpleMatch) {
	$lines = ($input | Out-String) -replace "`r", "" -split "`n"
	foreach($line in $lines) {
		$color = ''
		foreach($pattern in $Colors.Keys){
			if(!$SimpleMatch -and $line -match $pattern) { $color = $Colors[$pattern] }
			elseif ($SimpleMatch -and $line -like $pattern) { $color = $Colors[$pattern] }
		}
		if($color) {
			Write-Host -ForegroundColor $color $line
		} else {
			Write-Host $line
		}
	}
}

$folders = Get-ChildItem -Path . -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName
$oldPath = [Environment]::GetEnvironmentVariable('PATH', 'User');
$escapedPath = [RegEx]::Escape($oldPath)
Write-Host ""
Write-Host "==================================================================================================================================="
Write-Host "Your PATH is currently set to: ";
Write-Host "==================================================================================================================================="
$oldPath
Write-Host ""
Write-Host "==================================================================================================================================="
Write-Host "The following folders were found in the working directory and will be added to your PATH: ";
Write-Host "==================================================================================================================================="

$outputTable = @()
$alreadyExistsString = "Already exists and will NOT be added to PATH."
$willBeAddedString = "Will be added to PATH."
Foreach($folder in $folders){
  if($oldPath -Match [RegEx]::Escape($folder.FullName)){
    $entry = [PSCustomObject]@{
      Path = $folder.FullName
      Status = $alreadyExistsString
    }
    $outputTable += $entry
  } 
  else {
    $entry = [PSCustomObject]@{
      Path = $folder.FullName
      Status = $willBeAddedString
    }
    $outputTable += $entry
  }
}

$outputTable | Format-Table -AutoSize | Format-Color @{$willBeAddedString = 'Green'; $alreadyExistsString = 'Red'}

if(!$commit){ 
  Write-Host "===================================================================================================================================" -ForegroundColor Yellow
  Write-Warning "This was a test run. In order to commit these results to your path, call the script again with the '-commit' flag."
  Write-Host "===================================================================================================================================" -ForegroundColor Yellow
} 
else {
  $addedOutputTable = @()
  $successString = "Successfully added to PATH."
  $updatedPath = $oldPath
  Foreach($folder in $folders){
    if(!($oldPath -Match [RegEx]::Escape($folder.FullName))){
      $updatedPath += ";$($folder.FullName)"
      $entry = [PSCustomObject]@{
        Path = $folder.FullName
        Status = $successString
      }
      $addedOutputTable += $entry
    } 
  }

  Write-Host "==================================================================================================================================="
  Write-Host "The following folders were added to your PATH:";
  Write-Host "==================================================================================================================================="
  $addedOutputTable | Format-Table -AutoSize | Format-Color @{$successString = 'Green'}

  [Environment]::SetEnvironmentVariable("PATH", $updatedPath, [EnvironmentVariableTarget]::User)
  $newPath = [Environment]::GetEnvironmentVariable('PATH', 'User');
  Write-Host "===================================================================================================================================" -ForegroundColor Cyan
  Write-Host "Your PATH has been updated to: " -ForegroundColor Cyan
  Write-Host "===================================================================================================================================" -ForegroundColor Cyan
  $newPath

  Write-Host ""
  Write-Host "===================================================================================================================================" -ForegroundColor Yellow
  Write-Host "Your previous PATH was written to 'old_path.txt' as a precaution. Delete this file if it is not needed for a restoration." -ForegroundColor Yellow
  Write-Host "===================================================================================================================================" -ForegroundColor Yellow
  $oldPath | Out-File .\old_path.txt

  Write-Host ""
  Write-Host "PATH updated successfully!" -ForegroundColor Green
  Write-Host ""
}
