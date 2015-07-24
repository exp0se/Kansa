<#
.SYNOPSIS
Get-ARP.ps1 acquires arp table
.NOTES
Next line tells Kansa.ps1 how to format this script's output.
OUTPUT csv
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

if (Get-Command Get-NetNeighbor -ErrorAction SilentlyContinue) {
    Get-NetNeighbor
} else {
	$current_lang = Get-Culture
	if ($current_lang.TwoLetterISOLanguageName -eq "en") {
		$IpPattern = "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"
		foreach ($line in (& $env:windir\system32\arp.exe -a)) {
			$line = $line.Trim()
			if ($line.Length -gt 0) {
					if ($line -match 'Interface:\s(?<Interface>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s.*') {
						$Interface = $matches['Interface']
					} elseif ($line -match '(?<IpAddr>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+(?<Mac>[0-9A-Fa-f]{2}\-[0-9A-Fa-f]{2}\-[0-9A-Fa-f]{2}\-[0-9A-Fa-f]{2}\-[0-9A-Fa-f]{2}\-[0-9A-Fa-f]{2})*\s+(?<Type>dynamic|static)') {
						$IpAddr = $matches['IpAddr']
						if ($matches['Mac']) {
							$Mac = $matches['Mac']
						} else {
							$Mac = ""
						}
						$Type   = $matches['Type']
						$o = "" | Select-Object Interface, IpAddr, Mac, Type
						$o.Interface, $o.IpAddr, $o.Mac, $o.Type = $Interface, $IpAddr, $Mac, $Type
						$o
					}
				}

			}
		}
	if ($current_lang.TwoLetterISOLanguageName -eq "ru") {
		$IpPattern = "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"
		foreach ($line in (& $env:windir\system32\arp.exe -a|ConvertTo-Encoding cp866 windows-1251)) {
			$line = $line.Trim()
			if ($line.Length -gt 0) {
					if ($line -match 'Интерфейс:\s(?<Interface>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s.*') {
						$Interface = $matches['Interface']
					} elseif ($line -match '(?<IpAddr>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+(?<Mac>[0-9A-Fa-f]{2}\-[0-9A-Fa-f]{2}\-[0-9A-Fa-f]{2}\-[0-9A-Fa-f]{2}\-[0-9A-Fa-f]{2}\-[0-9A-Fa-f]{2})*\s+(?<Type>динамический|статический)') {
						$IpAddr = $matches['IpAddr']
						if ($matches['Mac']) {
							$Mac = $matches['Mac']
						} else {
							$Mac = ""
						}
						$Type   = $matches['Type']
						$o = "" | Select-Object Interface, IpAddr, Mac, Type
						$o.Interface, $o.IpAddr, $o.Mac, $o.Type = $Interface, $IpAddr, $Mac, $Type
						$o
					}
				}
			}				
		}
	}