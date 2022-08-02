# Description
This is powershell functions which allowing you to manage printers.

# Functions

## Install printer
iInstall-Printer

## Get List of remote printers for user
Sample of usage:
```
iGet-UserPrinters -ComputerName PC-123 -Username Ilias.Aidar
```

## Get Default Printer of remote user
Sample of usage:
```
iGet-UserDefaultPrinter -ComputerName PC-123 -Username Ilias.Aidar
```

## Set Default Printer of remote user
Sample of usage:
```
iSet-UserDefaultPrinter -ComputerName PC-123 -Username Ilias.Aidar -Printer "printername"
```
Note: printer name can be retrieved from iGet-UserPrinters command


# HowTo Start
For start useing you should load functions to your powershell session:
```
. .\iPrinters.ps1
```
after you can sue above commands