# Run script as Administrator
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
  Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
  Exit
}

# Turn off progress notifications (affects Write-Progress cmdlet used by other functions)
$ProgressPreference = 'SilentlyContinue'

# Set up environment
$PSBaseName = (dir "$PSCommandPath").Directory
$DirConfig = "$PSBaseName" + "\Config"
$DirScripts = "$PSBaseName" + "\Scripts"

# Registry change function
function ActionRegistryChange([string] $Action, [string] $ParentKey, [string] $Key, [string] $ValueType, [string] $Value) {
  # HKEY_CLASSES_ROOT is not mapped initially
  if ( $ParentKey.ToUpper().StartsWith("HKCR:") ){
    if (!(Test-Path "HKCR:")) {
	  New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
    }
  }
  # Ensure that the parent for any key actually exists; create if not
  if ( $Action.ToUpper().Trim() -eq "SET" ) {
    if (!(Test-Path "$ParentKey")) {
      New-Item -Path "$ParentKey" -Force
    }
  }
  # Mappings for empty-string and space (because values in config files are trimmed)
  if ( $Value -eq "`"`"" ) {
    $Value = ""
  } elseif ( $Value -eq "`" `"" ) {
    $Value = " "
  }
  # Action the registry change
  switch ($Action.ToUpper().Trim()) {
    "SET"    {  switch ($ValueType) {
                 "DWORD"  {  Set-ItemProperty -Path "$ParentKey" -Name "$Key" -Type DWord -Value $Value
                          }
                 "STRING" {  Set-ItemProperty -Path "$ParentKey" -Name "$Key" -Type String -Value $Value
                          }
                 default  { Write-Host Unrecognised registry value type `"$ValueType`"
                          }
                }
             }
    "REMOVE" {  if ( $Key.Trim() ) {
                  if ( (Test-Path "$ParentKey") ){
                    if ( (Get-ItemProperty -Path "$ParentKey" -Name "$Key" -ErrorAction SilentlyContinue) ) { 
                      Remove-ItemProperty -Path "$ParentKey" -Name "$Key"
                    }
                  }
                } else {
                  if ((Test-Path "$ParentKey")) { 
                    Remove-Item -Path "$ParentKey" -Recurse -Force
                  }
                }
             }
    default  { Write-Host Unrecognised registry action `"$Action`"
             }
  }
}

# Main routine (Note: using $NULL=... syntax to supress output instead of | Out-File)
$ConfigFileList = (Get-ChildItem "$DirConfig" -Filter *.txt | Sort)
$NULL = foreach ($ConfigFile in ($ConfigFileList)) {
  $ConfigFileContent = Get-Content "$DirConfig\$ConfigFile"
  $NULL = foreach ($ConfigFileLineItem in ($ConfigFileContent)) {
    # Ignore comment lines
    if ( !($ConfigFileLineItem.Trim().StartsWith("#")) ) {
      $ConfigFileline = $ConfigFileLineItem.Split("|")
      $Action = $ConfigFileLine[0].Trim()
      if ($Action) {
        $Name = $ConfigFileLine[1].Trim()
        if ($ConfigFileLine[2]) {  
          $Arg1 = $ConfigFileLine[2].Trim()
        } else {
          $Arg1 = " "
        }
        switch ($ConfigFileLine[0].Trim().ToUpper()){
          "MSG"   {  Write-Host $ConfigFileline[1].Trim()   
                  }
          "REG"   {  ActionRegistryChange "SET" $Name $Arg1 $ConfigFileline[3].Trim().ToUpper() $ConfigFileline[4].Trim()
                  }
          "REG-"  {  if ($Arg1) {
                       ActionRegistryChange "REMOVE" $Name $Arg1 " " " "
                     } else {
                       ActionRegistryChange "REMOVE" $Name " " " " " "
                     }
                  }    
          "CALL"  { if ( (Test-Path "$DirScripts\$Name") ) {
                      & "$DirScripts\$Name"
                    } else {
                      Write-Host Script `"$DirScripts\$Name`" called from file `"$DirConfig\$ConfigFile`" not found.
                    }
                  }
          default {  Write-Host Unrecognised action `"$Action`" in file `"$DirConfig\$ConfigFile`"  
                  }
        }      
      }
    }
  }
} 

Write-Host "!!! Your PC will restart now !!!"
Write-Host "Press any key to restart..."
$Key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host "Restarting..."
Restart-Computer
