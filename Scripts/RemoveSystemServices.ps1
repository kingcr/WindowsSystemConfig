$ServicesToRemove = @("HomeGroupListener",
                      "HomeGroupProvider",
                      "XblAuthManager",
                      "XblGameSave",
                      "XboxNetApiSvc"
                     ) 

foreach ( $Service in ($ServicesToRemove)){
  Write-Host "--- $Service"
  Stop-Service $Service
  Set-Service  $Service -StartupType Disabled
}
