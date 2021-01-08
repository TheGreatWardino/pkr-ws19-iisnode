#undo the WinRM configurations we made previously since we do not need this open anymore
Invoke-Expression (Invoke-WebRequest -uri 'https://raw.githubusercontent.com/DarwinJS/Undo-WinRMConfig/master/Undo-WinRMConfig.ps1' -UseBasicParsing)
