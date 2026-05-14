# CodeBackup.ps1
# Credentials and paths loaded from environment variables.
# Never hardcode passwords in scripts committed to source control.
$NetworkPath = $env:BACKUP_NETWORK_PATH
$NetUser     = $env:BACKUP_NET_USER
$NetPass     = $env:BACKUP_NET_PASS

if (-not $NetworkPath -or -not $NetUser -or -not $NetPass) {
    Write-Error "Set BACKUP_NETWORK_PATH, BACKUP_NET_USER, and BACKUP_NET_PASS before running."
    exit 1
}

$dteToday           = Get-Date
$strCurrentFileDate = $dteToday.ToString("yyyy-MM-dd")
$strCurrentMonth    = [int]$strCurrentFileDate.Substring(5, 2)
$intCurrentYear     = [int]$strCurrentFileDate.Substring(0, 4)
$strFullPath        = "S:\" + $strCurrentFileDate + ".7z"

Import-Module C:\bin\7Zip4PowerShell.dll

(New-Object -ComObject WScript.Network).MapNetworkDrive("S:", $NetworkPath, $true, $NetUser, $NetPass)

If (Test-Path $strFullPath) { Remove-Item $strFullPath }

$intPreviousMonth = $strCurrentMonth - 2
switch ($intPreviousMonth) {
    0  { $intCurrentYear--; $intPreviousMonth = 12 }
    -1 { $intCurrentYear--; $intPreviousMonth = 11 }
}

$strPreviousMonth = $intPreviousMonth.ToString("D2")
$strCurrentYear   = $intCurrentYear.ToString()

$sources = @{
    db  = "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup"
    svn = "C:\Source"
    www = "C:\inetpub"
}

foreach ($type in $sources.Keys) {
    $archive = $strFullPath -replace "\.7z", ".$type.7z"
    $oldGlob = "S:\$strCurrentYear-$strPreviousMonth*.$type.7z"
    Compress-7Zip -ArchiveFileName $archive $sources[$type]
    Remove-Item $oldGlob -ErrorAction SilentlyContinue
    Write-Output "Backed up $type -> $archive (pruned: $oldGlob)"
}

$drive = Get-WmiObject -Class Win32_MappedLogicalDisk -Filter "ProviderName='$NetworkPath'"
net use $drive.Name /delete /y
