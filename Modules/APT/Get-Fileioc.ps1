<#
.SYNOPSIS
Get-Fileioc.ps1 search for known file indicators. Accepts path to scan.
By default will scan C:\Windows

.NOTES
This script depend on zipped indicators file that must be named filename-iocs.txt
The format of indicators is following:
regexp;score;source
for example 
\\usbclass\.sys;80;regin

If you want to remove the binary from remote systems after it has run,
add the -rmbin switch to Kansa.ps1's command line.

If you run Kansa.ps1 without the -rmbin switch, binaries pushed to 
remote hosts will be left beind and will be available on subsequent
runs, obviating the need to run with -Pushbin in the future.

The following lines are required by Kansa.ps1. They are directives that
tell Kansa how to treat the output of this script and where to find the
binary that this script depends on.
.EXAMPLE
.\kansa.ps1 -Target Compname -Credential $Credential -ModulePath ".\Modules\APT\Get-Fileioc.ps1 C:\Users"
OUTPUT txt
BINDEP .\Modules\bin\indicators.zip
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$False,Position=0)]
        [String]$Path="C:\Windows"
)

Function Expand-Zip ($zipfile, $destination) {
	[int32]$copyOption = 16 # Yes to all
    $shell = New-Object -ComObject shell.application
    $zip = $shell.Namespace($zipfile)
    foreach($item in $zip.items()) {
        $shell.Namespace($destination).copyhere($item, $copyOption)
    }
} 

$iocspath = ($env:SystemRoot + "\indicators.zip")

if (Test-Path ($iocspath)) {
    $suppress = New-Item -Name iocs -ItemType Directory -Path $env:Temp -Force
    $iocsdir = ($env:Temp + "\iocs\")
    Expand-Zip $iocspath $iocsdir
    if (Test-Path($iocsdir + "filename-iocs.txt")) {
        $indicators = $iocsdir + "filename-iocs.txt"
        $data = Get-Content $indicators | ? {$_.Trim(" `t")}
        $files = & cmd /c dir $Path /s /b 
        foreach ($d in $data) {
            if ( $d.StartsWith("#")) {
                continue
            }
            $ioc = $d.Split(";")[0]
            $score = $d.Split(";")[1]
            $source = $d.Split(";")[2]

            $match = $files | Select-String -Pattern $ioc -ErrorAction SilentlyContinue | Select -ExpandProperty Line
            if ($match) {
                "Match on $ioc with score $score on $match possible $source presence"
            }
        }
    }
}