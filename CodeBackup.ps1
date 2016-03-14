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

# Datbase backups #

$strLocalPath =  $strFullPath -replace ".7z", ".db.7z"

$strFilePatternToDelete = $strCurrentYear + "-" + $strPreviousMonth + "*.7z"
$strRemoveItemParam = "S:\" + $strFilePatternToDelete
$strRemoveItemParam  = $strRemoveItemParam -replace ".7z", ".db.7z"
 
Compress-7Zip -ArchiveFileName $strLocalPath "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup"
 
Remove-Item $strRemoveItemParam
 
$strMessage = "Deleting " + $strRemoveItemParam
echo $strMessage

# Svn Backups #
 
$strFilePatternToDelete = $strCurrentYear + "-" + $strPreviousMonth + "*.7z"
$strRemoveItemParam = "S:\" + $strFilePatternToDelete
$strRemoveItemParam  = $strRemoveItemParam -replace "db.7z", ".svn.7z"

$strLocalPath =  $strFullPath -replace ".7z", ".svn.7z"
 
Compress-7Zip -ArchiveFileName $strLocalPath "C:\Source"
 
Remove-Item $strRemoveItemParam
 
$strMessage = "Deleting " + $strRemoveItemParam
echo $strMessage

# Web backups #

$strLocalPath =  $strFullPath -replace ".7z", ".www.7z"

$strFilePatternToDelete = $strCurrentYear + "-" + $strPreviousMonth + "*.7z"
$strRemoveItemParam = "S:\" + $strFilePatternToDelete
$strRemoveItemParam  = $strRemoveItemParam -replace ".svn.7z", ".www.7z"
 
Compress-7Zip -ArchiveFileName $strLocalPath "C:\inetpub"
 
Remove-Item $strRemoveItemParam
 
$Drive = Get-WmiObject -Class Win32_mappedLogicalDisk -filter "ProviderName='\\\\server01\\PATH\\PATH2\\PATH3'"

net use $Drive.Name /delete /y