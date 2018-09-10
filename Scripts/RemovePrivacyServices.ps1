$ServicesToRemove = @("DiagTrack",
                      "dmwappushservice"
                     ) 

# Other possible candidate(s):
# lfsvc - geolocation service

foreach ( $Service in ($ServicesToRemove)){
  Write-Host "--- $Service"
  Stop-Service $Service
  Set-Service  $Service -StartupType Disabled
}
