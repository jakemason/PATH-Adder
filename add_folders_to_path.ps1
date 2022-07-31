param(
  [switch]$commit = $false
)
$folders = Get-ChildItem -Path . -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName
$oldPath = [Environment]::GetEnvironmentVariable('PATH', 'User');
$escapedPath = [RegEx]::Escape($oldPath)
  Write-Host "==================================================================================================================================="
  Write-Host "Your PATH is currently set to: ";
  Write-Host "==================================================================================================================================="
$oldPath
  Write-Host "==================================================================================================================================="
  Write-Host "The following folders were found in the working directory and will be added to your PATH: ";
  Write-Host "==================================================================================================================================="
Foreach($folder in $folders){
  if($oldPath -Match [RegEx]::Escape($folder.FullName)){
    Write-Host "$($folder.FullName) | Already exists in your PATH and will NOT be added to PATH."
  } 
  else {
    Write-Host "$($folder.FullName)"
  }
}

if(!$commit){ 
  Write-Host "==================================================================================================================================="
  Write-Warning "This was a test run. In order to commit these results to your path, call the script again with the '-commit' flag."
  Write-Host "==================================================================================================================================="
} 
else {
  $updatedPath = $oldPath
  Foreach($folder in $folders){
    if(!($oldPath -Match [RegEx]::Escape($folder.FullName))){
      $updatedPath += ";$($folder.FullName)"
    } 
  }

  [Environment]::SetEnvironmentVariable("PATH", $updatedPath, [EnvironmentVariableTarget]::User)
  $newPath = [Environment]::GetEnvironmentVariable('PATH', 'User');
  Write-Host "==================================================================================================================================="
  Write-Host "Your PATH has been updated to: ";
  Write-Host "==================================================================================================================================="
  $newPath
  Write-Host "==================================================================================================================================="
  Write-Warning "Your previous path was written to 'old_path.txt' as a precaution. Delete this file if it is not needed for a restoration."
  Write-Host "==================================================================================================================================="
  $oldPath | Out-File .\old_path.txt
}
