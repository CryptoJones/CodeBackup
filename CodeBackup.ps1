$dteToday = Get-Date
$strCurrentFileDate = $dteToday.ToString("yyyy-MM-dd")
$strCurrentMonth = $strCurrentFileDate.Substring(5, 2)
$strCurrentFileName = $strCurrentFileDate + ".7z"
$strFullPath = "S:\" + $strCurrentFileName

Import-Module C:\bin\7Zip4PowerShell.dll

(New-Object -ComObject WScript.Network).MapNetworkDrive('S:','\\server01\PATH\PATH2\PATH3',$true,'domain\user','IL0veG0@tS3X')
If (Test-Path $strFullPath){
	Remove-Item $strFullPath
}

$intPreviousMonth = $strCurrentMonth - 2 
$intCurrentYear = $strCurrentFileDate.Substring(0, 4)

If ($intPreviousMonth -lt 1){
    switch ($intPreviousMonth){
        0 {
            $intCurrentYear = $intCurrentYear - 1
            $intPreviousMonth = 12
        }
        -1 {
            $intCurrentYear = $intCurrentYear - 1
            $intPreviousMonth = 11
        }
    }
} else {
    $strCurrentYear = $intCurrentYear.ToString()
}

$strPreviousMonth = ""

If ($intPreviousMonth -lt 10) {
    $strPreviousMonth = "0" + $intPreviousMonth
} Else {
    $strPreviousMonth = $intPreviousMonth
}

$strFilePatternToDelete = $strCurrentYear + "-" + $strPreviousMonth + "*.7z"
$strRemoveItemParam = "S:\" + $strFilePatternToDelete

Compress-7Zip -ArchiveFileName $strFullPath "C:\PATH\PATH2\PATH3"

Remove-Item $strRemoveItemParam

$strMessage = "Deleting " + $strRemoveItemParam
echo $strMessage

Start-Sleep -s 30

$Drive = Get-WmiObject -Class Win32_mappedLogicalDisk -filter "ProviderName='\\\\server01\\PATH\\PATH2\\PATH3'"

net use $Drive.Name /delete /y