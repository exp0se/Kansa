<#
.SYNOPSIS
Get-LocalAdmins.ps1 returns a list of local administrator accounts.
.NOTES
Next line is required by Kansa.ps1. It instructs Kansa how to handle
the output from this script.
OUTPUT CSV
#>

# I hate Microsoft
# Convert function from https://xaegr.wordpress.com/2007/01/24/decoder/
# If you try to use old cmd commands such as net, schtask etc.
# and remote OS is other than English you will ran into problem
# with gibberish encoding output with no easy fix
# This is the ONLY way i was able to find to fix this
# Example:
# ipconfig | ConvertTo-Encoding cp866 windows-1251
# Function expect a string, pass Out-String before if needed.
function ConvertTo-Encoding ([string]$From, [string]$To){  
        Begin{  
            $encFrom = [System.Text.Encoding]::GetEncoding($from)  
            $encTo = [System.Text.Encoding]::GetEncoding($to)  
        }  
        Process{  
            $bytes = $encTo.GetBytes($_)  
            $bytes = [System.Text.Encoding]::Convert($encFrom, $encTo, $bytes)  
            $encTo.GetString($bytes)  
        }  
    }  


$current_lang = Get-Culture
if ($current_lang.TwoLetterISOLanguageName -eq "en") {
	& net localgroup administrators | Select-Object -Skip 6 | ? {
		$_ -and $_ -notmatch "The command completed successfully" 
	} | % {
		$o = "" | Select-Object Account
		$o.Account = $_
		$o
	}
}
if ($current_lang.TwoLetterISOLanguageName -eq "ru") {
	& net localgroup Администраторы | ConvertTo-Encoding cp866 windows-1251 | Select-Object -Skip 6 | ? {
		$_ -and $_ -notmatch "Команда выполнена успешно" 
	} | % {
		$o = "" | Select-Object Account
		$o.Account = $_
		$o
	}
}
