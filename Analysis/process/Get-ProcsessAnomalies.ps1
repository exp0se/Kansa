<#
.SYNOPSIS
Get-ProccessAnomalies.ps1
Look for anomalies in process data
.NOTES
DATADIR ProcsWMI
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$False,Position=0)]
        [String]$File_log
    )


$data = $null
$sys32_anomalies = @()

if ($File_log) {
    $data = Import-CSV $File_log
    }
else {
    foreach ($file in (ls *ProcsWMI.csv)) {
        $data += Import-CSV $file
    }
}

$win_procs = @("smss.exe", "csrss.exe", "wininit.exe",
    "services.exe", "lsass.exe", "svchost.exe", "dwm.exe", "winlogon.exe",
    "spoolsv.exe", "WmiPrvSE.exe", "dllhost.exe", "taskhost.exe", "LogonUI.exe",
    "rdpclip.exe", "taskhostex.exe", "SearchProtocolHost.exe", "SearchFilterHost.exe",
    "wsmprovhost.exe", "cmd.exe", "conhost.exe", "WUDFHost.exe", "lsm.exe", "rundll32.exe")

foreach ($proc in $win_procs) {
   $sys32_anomalies += $data | ? {$_.Name -eq $proc -and $_.ExecutablePath -notlike "C:\Windows\system32*" }
}
# Sometimes we can't get ExecutablePath and it will be blank so we skip it 
$sys32_anomalies = $sys32_anomalies | ? {$_.ExecutablePath -ne ""}

$temp_anomalies = $data | ? {$_.ExecutablePath -like "*AppData*" -or $_.CommandLine -like "*AppData*"}

$explorer_anomalies = $data | ? {$_.Name -eq "explorer.exe" -and $_.ExecutablePath -ne "C:\Windows\explorer.exe" }

$iexplorer_anomalies = $data | ? {$_.Name -eq "iexplore.exe" -and $_.ExecutablePath -notlike "C:\Program Files*\Internet Explorer*" }

$rundll_anomalies = $data | ? {$_.Name -eq "rundll32.exe" -and $_.CommandLine -like "javascript*" }

$user_anomalies = $data | ? {$_.Username -like "NT AUTHORITY*" -and $_.Name -eq "cmd.exe" -or $_.Name -eq "powershell.exe"}

if ($sys32_anomalies) {
    Write-Host "--------ANOMALY DETECTED--------
Common windows processes is not run from System32 folder.
    " -Foreground Red
    $sys32_anomalies
}
if ($temp_anomalies) {
    Write-Host "--------ANOMALY DETECTED--------
Found processes running from user folder
    " -Foreground Red   
    $temp_anomalies 
}
if ($explorer_anomalies) {
    Write-Host "--------ANOMALY DETECTED--------
Explorer run from unusual location
    " -Foreground Red   
    $explorer_anomalies 
}
if ($iexplorer_anomalies) {
    Write-Host "--------ANOMALY DETECTED--------
Internet Explorer run from unusual location
    " -Foreground Red   
    $iexplorer_anomalies 
}
if ($rundll_anomalies) {
    Write-Host "--------ANOMALY DETECTED--------
Javascript invoked via rundll
    " -Foreground Red   
    $rundll_anomalies 
}
if ($user_anomalies) {
    Write-Host "--------ANOMALY DETECTED--------
Shell running under SYSTEM user!!!
    " -Foreground Red   
    $user_anomalies 
}