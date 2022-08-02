function iGet-UserDefaultPrinter {
<#
.SYNOPSIS
    Get User Default Printer for User

.DESCRIPTION
    iGet-UserDefaultPrinter is function which show the default printer for user

.EXAMPLE
     iGet-UserDefaultPrinter -Username "Ilias.Aidar" -ComputerName "PC-100"

.OUTPUTS
    PSCustomObject

.NOTES
    Author:  Ilias Aidar
    Website: https://www.ismarty.pro
    Telegram: @iSmartyPro
#>
   param (

      [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
      [string]$ComputerName = $env:COMPUTERNAME,
      [string]$Username
   )
   Process {
      try{
         if($UserName) {
         $sid = (Get-ADUser $Username -Property * | select objectsid).objectsid.value
         $defaultPrinter = Invoke-Command -ScriptBlock {
            New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS
            $sid = $args[0]
            (Get-ItemProperty "HKU:\$sid\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows\").Device
         } -argumentList $sid -computername $ComputerName

            $result = [pscustomobject]@{
               ComputerName = $ComputerName
               UserName  = $UserName
               DefaultPrinter  = ($defaultPrinter)[1]
            }
         } else {
            $result = [pscustomobject]@{
               Status = 'Bad'
               Message = 'Username is missing'
            }
         }
         $result
      } catch {
         Write-Warning $_
      }
   }
}


function iGet-UserPrinters {
<#
.SYNOPSIS
    Get User Printers of remote computer

.DESCRIPTION
    iGet-UserPrinters is function which show the list of available printer for user

.EXAMPLE
     iGet-UserPrinter -Username "Ilias.Aidar" -ComputerName "PC-100"

.OUTPUTS
    PSCustomObject

.NOTES
    Author:  Ilias Aidar
    Website: https://www.ismarty.pro
    Telegram: @iSmartyPro
#>
   param (

      [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
      [string]$ComputerName = $env:COMPUTERNAME,
      [string]$Username
   )
   Process {
      try{
         if($UserName) {
         $sid = (Get-ADUser $Username -Property * | select objectsid).objectsid.value
         $printerList = Invoke-Command -ScriptBlock {
            New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS | Out-null
            $sid = $args[0]
            $printers = Get-ItemProperty "HKU:\$sid\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Devices"
            $printers.PSObject.Properties.Remove("PSPath")
            $printers.PSObject.Properties.Remove("PSParentPath")
            $printers.PSObject.Properties.Remove("PSChildName")
            $printers.PSObject.Properties.Remove("PSDrive")
            $printers.PSObject.Properties.Remove("PSProvider")
            $p_obj = $printers | Get-Member | ? {$_.MemberType -eq 'NoteProperty'}
            $p_res = @()
            foreach($p in $p_obj){
               if($p.Name -notlike "*redirected*"){
                  $p_res += (($p.definition).replace("string ", "").replace("=",","))
               }
            }
            $p_res
         } -argumentList $sid -computername $ComputerName
            $result = $printerList
         } else {
            $result = [pscustomobject]@{
               Status = 'Bad'
               Message = 'Username is missing'
            }
         }
         $result
      } catch {
         Write-Warning $_
      }
   }
}

function iSet-UserDefaultPrinter {
<#
.SYNOPSIS
    Set User Default Printers on remote computer

.DESCRIPTION
    iSet-UserDefaultPrinter is function which set default printer for user on remote computer
    Printer Value - should be get by iGet-UserPrinters

.EXAMPLE
     iSet-UserDefaultPrinter -Username "Ilias.Aidar" -ComputerName "PC-100" -Printer "\\FS-GENCO\CO Kyocera Finance
MFU2,winspool,Ne04:"

.OUTPUTS
    PSCustomObject

.NOTES
    Author:  Ilias Aidar
    Website: https://www.ismarty.pro
    Telegram: @iSmartyPro
#>
   param (

      [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
      [string]$ComputerName = $env:COMPUTERNAME,
      [string]$Username,
      [string]$Printer
   )
   Process {
      try{
         if($UserName -and $Printer) {
         $sid = (Get-ADUser $Username -Property * | select objectsid).objectsid.value
         Invoke-Command -ScriptBlock {
            New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS | Out-null
            $sid = $args[0]
            $Printer = $args[1]
            $printers = Set-ItemProperty -Path "HKU:\$sid\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows" -Name "Device" -Value $Printer
         } -argumentList $sid, $Printer -computername $ComputerName
         } else {
            $result = [pscustomobject]@{
               Status = 'Bad'
               Message = 'Missing required paramaners: Username or Printer'
            }
         }
         $result
      } catch {
         Write-Warning $_
      }
   }
}




function iInstall-Printer {
<#
.SYNOPSIS
    Install printer on remote computer

.DESCRIPTION
    iInstall-Printer is function which install printer on remote computer

.EXAMPLE
     iInstall-Printer -ComputerName "PC-100" -DriverPath "\\storage\share\drivers\printerprovider" -DriverName "HP LaserJet Pro M428f-M429f PCL-6 (V4)" -PrinterName "HP M428dw" -PrinterIP "192.168.69.25" -printerPortName "IP_192.168.69.25 (HP Printer Port)"

.OUTPUTS
    PSCustomObject

.NOTES
    Author:  Ilias Aidar
    Website: https://www.ismarty.pro
    Telegram: @iSmartyPro
#>
   param (

      [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
      [string]$ComputerName = $env:COMPUTERNAME,
      [string]$DriverPath,
      [string]$DriverName,
      [string]$PrinterName,
      [string]$PrinterIP,
      [string]$PrinterPortname
   )
   Process {
      try{
         if($ComputerName -and $DriverPath -and $DriverName -and $PrinterName -and $PrinterIP -and $PrinterPortName) {
         Invoke-Command -ScriptBlock {
            Write-Host "Installing drivers from path: $($args[0])\*.inf" -Foreground yellow
            pnputil /add-driver "$($args[0])\*.inf" /install

            Write-Host "Adding printer driver $($args[1])" -Foreground yellow
            Add-PrinterDriver -Name $args[1]

            Write-Host "Adding printer port name $($args[2]) for IP: $($args[3])" -Foreground yellow
            Add-PrinterPort -Name $args[2] -PrinterHostAddress $args[3]

            Write-Host "Adding printer $($) to system" -Foreground yellow
            Add-Printer -DriverName $args[1] -Name $args[4] -PortName $args[2]
         } -argumentList $DriverPath, $DriverName, $PrinterPortName, $PrinterIP, $PrinterName  -computername $ComputerName
         Write-Host "Done!!!" -Foreground green

         } else {
            $result = [pscustomobject]@{
               Status = 'Bad'
               Message = 'Missing required paramaners'
            }
         }
         $result
      } catch {
         Write-Warning $_
      }
   }
}