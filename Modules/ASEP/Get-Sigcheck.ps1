<#
.SYNOPSIS
Get-Sigcheck.ps1 returns output from the SysInternals' sicheck.exe utility
Will verify digital signature and also hash on VT.
Careful where you pointing it. Running it on Windows folder will take a lot of time.
By default will check C:\users folder.
.NOTES
OUTPUT csv
BINDEP .\Modules\bin\sigcheck.exe

!! THIS SCRIPT ASUMES SIGCHECK.EXE WILL BE IN $ENV:SYSTEMROOT !!
.EXAMPLE
.\kansa.ps1 -Target Compname -Credential $Credential -ModulePath ".\Modules\ASEP\Get-Sigcheck.ps1 C:\Windows\Temp"
#>
[CmdletBinding()]
Param(
	[Parameter(Mandatory=$False,Position=0)]
    [String]$Path="C:\Users"
)
if (Test-Path "$env:SystemRoot\sigcheck.exe") {
    & $env:SystemRoot\sigcheck.exe /accepteula -a -c -h -v -vt -u -q -s $Path 2> $null | 
        ConvertFrom-Csv |
            ForEach-Object { $_ }
}
else {
    Write-Error "Sigcheck.exe not found in $env:SystemRoot."
}