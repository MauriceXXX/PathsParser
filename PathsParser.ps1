Clear-Host
Write-Host " 
    ██████╗██████╗ ██╗███╗   ███╗███████╗██╗     ██╗███████╗███████╗
   ██╔════╝██╔══██╗██║████╗ ████║██╔════╝██║     ██║██╔════╝██╔════╝
   ██║     ██████╔╝██║██╔████╔██║█████╗  ██║     ██║█████╗  █████╗  
   ██║     ██╔══██╗██║██║╚██╔╝██║██╔══╝  ██║     ██║██╔══╝  ██╔══╝  
   ╚██████╗██║  ██║██║██║ ╚═╝ ██║███████╗███████╗██║██║     ███████╗
    ╚═════╝╚═╝  ╚═╝╚═╝╚═╝     ╚═╝╚══════╝╚══════╝╚═╝╚═╝     ╚══════╝" -ForegroundColor Red
Write-Host "        -------------------- " -NoNewline -ForegroundColor Blue
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

# Ergebnisse vorbereiten (Dummy Status-Zuordnung)
$results = foreach ($path in $uniquePaths) {
    # Dummy logic: simulate status
    $status = if ($path -match "delete" -or $path -match "old") {
        "DELETED"
    } elseif ($path -match "unsigned" -or $path -match "temp") {
        "NotSigned"
    } else {
        "Valid"
    }

    [PSCustomObject]@{
        Status = $status
        Path   = $path
    }
}

# Ausgabe
Write-Host ""
Write-Host ("{0,-15} {1}" -f "Status", "Path") -ForegroundColor Gray
Write-Host ("-" * 80)

foreach ($entry in $results) {
    if ($entry.Status -ne "Valid") {
        Write-Host ("{0,-15} {1}" -f $entry.Status, $entry.Path)
    }
}

Write-Host "`nFinished!" -ForegroundColor Green
