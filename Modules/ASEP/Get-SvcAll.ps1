<#
.SYNOPSIS
Get-SvcAll.ps1 returns information about all Windows services.
.NOTES
The following line is required by Kansa.ps1, which uses it to determine
how to handle the output from this script.
OUTPUT csv
#>
Get-WmiObject win32_service | Select-Object Name, DisplayName, Description, PathName, ProcessId, State, StartName