$AppsToRemove = @("Microsoft.Getstarted",
                  "Microsoft.MicrosoftOfficeHub",
                  "Microsoft.MicrosoftSolitaireCollection",
                  "Microsoft.OneConnect",
                  "Microsoft.GetHelp",
                  "Microsoft.Office.OneNote",
                  "Microsoft.Print3D",
                  "Microsoft.MicrosoftStickyNotes",
                  "Microsoft.MSPaint",
                  "Microsoft.WindowsSoundRecorder",
                  "Microsoft.WindowsCamera", 
                  "Microsoft.WindowsAlarms",
                  "Microsoft.WindowsMaps"
                 )

# Some others:
# Microsoft.BingWeather
# Microsoft.Windows.Photos
# Microsoft.ZuneVideo
# Microsoft.windowscommunicationsapps
# Microsoft.People
# Microsoft.WindowsFeedbackHub
# Microsoft.Microsoft3DViewer

Write-Host "- Removing UWP Apps For Current User"

foreach ($App in ($AppsToRemove)) {
  Write-Host "--- $App"
  Get-AppxPackage -Name "$App" | Remove-AppxPackage | Out-Null
}

Write-Host "- Removing UWP Apps For All Users"

foreach ($App in ($AppsToRemove)) {
  Write-Host "--- $App"
  Get-AppxPackage -Name "$App" -AllUsers | Remove-AppxPackage | Out-Null
}

Write-Host "- Removing Online Provisioned Apps"

foreach ($App in ($AppsToRemove)) {
  Write-Host "--- $App"
  Get-ProvisionedAppxPackage -Online | where DisplayName -EQ "$App" | Remove-ProvisionedAppxPackage -Online | Out-Null
}

Write-Host "- Removing App Directories"

foreach ($App in ($AppsToRemove)) {
  Write-Host "--- $App"
  $AppPath = "$Env:LOCALAPPDATA\Packages\$App*"
  Remove-Item "$AppPath" -Recurse -Force -ErrorAction SilentlyContinue
}
