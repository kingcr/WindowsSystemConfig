$FeaturesToRemove = @("MediaPlayback",
                      "WorkFolders-Client",
                      "Internet-Explorer-Optional-amd64"
                     )

foreach ($Feature in ($FeaturesToRemove)) {
  Write-Host "--- $Feature"
  dism /online /Disable-Feature /FeatureName:$Feature /Quiet /NoRestart
}
