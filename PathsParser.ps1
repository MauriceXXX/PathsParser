Clear-Host
Write-Host "  ____ ____  ___ __  __ _____ _     ___ _____ _____ 
 / ___|  _ \|_ _|  \/  | ____| |   |_ _|  ___| ____|
| |   | |_) || || |\/| |  _| | |    | || |_  |  _|  
| |___|  _ < | || |  | | |___| |___ | ||  _| | |___ 
 \____|_| \_|___|_|  |_|_____|_____|___|_|   |_____| `n" -ForegroundColor Red
Write-Host "   ---------------- Paths Parser ----------------`n" -ForegroundColor Cyan

do {
    $filePath = Read-Host "Input "

    if (-not (Test-Path $filePath -PathType Leaf)) {
        Write-Host "File not Found! Try Again" -ForegroundColor Red
        $filePath = $null
    }
} while (-not $filePath)

Write-Host "`nReading: $filePath" -ForegroundColor Cyan
Write-Host "`n   ---------------------------------------------`n" -ForegroundColor Cyan

$paths = Get-Content -Path $filePath

$regex = ':\s+(.*)$'

$uniquePaths = @()

foreach ($line in $paths) {
    if ($line -match $regex) {
        $path = $matches[1].Trim()

        if ($path -match '\.\w{2,5}$' -and -not $uniquePaths.Contains($path)) {
            $uniquePaths += $path
        }
    }
}

$uniquePaths = $uniquePaths | Sort-Object

foreach ($path in $uniquePaths) {
    if (Test-Path $path -PathType Leaf) {
        $sig = Get-AuthenticodeSignature -FilePath $path
        if ($sig.Status -ne 'Valid') {
            Write-Host ("{0,-12} {1}" -f $sig.Status, $path.ToUpper()) -ForegroundColor Yellow
        }
    } else {
        Write-Host ("{0,-12} {1}" -f "DELETED:", $path.ToUpper()) -ForegroundColor Red
    }
}

Write-Host "`nFinished!" -ForegroundColor Green
