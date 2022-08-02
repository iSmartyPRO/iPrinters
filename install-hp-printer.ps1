



$config = @{
  driverPath = "G:\CO\!_Общая\hp-driver"
  driverName = "HP LaserJet Pro M428f-M429f PCL-6 (V4)"
  printerName = "HP M428dw"
  printerIP = "192.168.69.25"
  printerPortName = "IP_192.168.69.25 (HP Printer Port)"
}

<# Install Printer Part #>
Write-Host "Installing HP drivers from path: $($config.driverPath)\*.inf" -Foreground yellow
pnputil /add-driver "$($config.driverPath)\*.inf" /install

Write-Host "Adding printer driver $($config.driverName)" -Foreground yellow
Add-PrinterDriver -Name $config.driverName

Write-Host "Adding printer port name $($config.printerPortName) for IP: $($config.printerIP)" -Foreground yellow
Add-PrinterPort -Name $config.printerPortName -PrinterHostAddress $config.printerIP

Write-Host "Adding printer $($config.printerName) to system" -Foreground yellow
Add-Printer -DriverName $config.driverName -Name $config.printerName -PortName $config.printerPortName

Write-Host "Done!!!" -Foreground green

<#
Uninstall Printer Part

// List all HP Providername drivers
Get-WindowsDriver -online | ? ProviderName -like "HP*"

// Remove all HP prividername drivers, require admin privilleges
Get-WindowsDriver -online | ? ProviderName -like "HP*" | Select-Object Driver | ForEach-Object { pnputil /delete-driver $_.Driver /force }


before run load config vars

Remove-Printer -Name $config.printerName
Remove-PrinterPort -Name $config.printerPortName
Remove-PrinterDriver -Name $config.driverName
Get-WindowsDriver -online | ? ProviderName -like "HP*" | Select-Object Driver | ForEach-Object { pnputil /delete-driver $_.Driver /force }
 #>