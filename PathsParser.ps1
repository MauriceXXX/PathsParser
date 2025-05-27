Clear-Host
Write-Host " 
    ██████╗██████╗ ██╗███╗   ███╗███████╗██╗     ██╗███████╗███████╗
   ██╔════╝██╔══██╗██║████╗ ████║██╔════╝██║     ██║██╔════╝██╔════╝
   ██║     ██████╔╝██║██╔████╔██║█████╗  ██║     ██║█████╗  █████╗  
   ██║     ██╔══██╗██║██║╚██╔╝██║██╔══╝  ██║     ██║██╔══╝  ██╔══╝  
   ╚██████╗██║  ██║██║██║ ╚═╝ ██║███████╗███████╗██║██║     ███████╗
    ╚═════╝╚═╝  ╚═╝╚═╝╚═╝     ╚═╝╚══════╝╚══════╝╚═╝╚═╝     ╚══════╝" -ForegroundColor Red
Write-Host "          -------------------- " -NoNewline -ForegroundColor Blue
Write-Host "PATHS PARSER" -NoNewline -ForegroundColor Red
Write-Host " --------------------" -ForegroundColor Blue
Write-Host "`n"

# Eingabe des Dateipfads
do {
    $filePath = Read-Host "Input "

    if (-not (Test-Path $filePath -PathType Leaf)) {
        Write-Host "File not Found! Try Again" -ForegroundColor Red
        $filePath = $null
    }
} while (-not $filePath)

Write-Host "`nReading: $filePath" -ForegroundColor Cyan
Write-Host "`n   ---------------------------------------------`n" -ForegroundColor Cyan

# Pfade einlesen
$paths = Get-Content -Path $filePath

$regex = ':\s+(.*)$'
$uniquePaths = @()

# Pfade extrahieren
foreach ($line in $paths) {
    if ($line -match $regex) {
        $path = $matches[1].Trim()
        if ($path -match '\.\w{2,5}$' -and -not $uniquePaths.Contains($path)) {
            $uniquePaths += $path
        }
    }
}

$uniquePaths = $uniquePaths | Sort-Object

# Beispiel für die Ausgabe
Write-Host ""
Write-Host ("{0,-15} {1}" -f "Status", "Path") -ForegroundColor Gray
Write-Host ("-" * 80)

foreach ($entry in $results) {
    $status = $entry.Status
    $path = $entry.Path

    # Nur "NotSigned" oder "DELETED" anzeigen
    if ($status -ne "Valid") {
        Write-Host ("{0,-15} {1}" -f $status, $path)
    }
}


Write-Host "`nFinished!" -ForegroundColor Green
