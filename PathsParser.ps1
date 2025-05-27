Clear-Host
Write-Host " 
    ██████╗██████╗ ██╗███╗   ███╗███████╗██╗     ██╗███████╗███████╗
   ██╔════╝██╔══██╗██║████╗ ████║██╔════╝██║     ██║██╔════╝██╔════╝
   ██║     ██████╔╝██║██╔████╔██║█████╗  ██║     ██║█████╗  █████╗  
   ██║     ██╔══██╗██║██║╚██╔╝██║██╔══╝  ██║     ██║██╔══╝  ██╔══╝  
   ╚██████╗██║  ██║██║██║ ╚═╝ ██║███████╗███████╗██║██║     ███████╗
    ╚═════╝╚═╝  ╚═╝╚═╝╚═╝     ╚═╝╚══════╝╚══════╝╚═╝╚═╝     ╚══════╝" -ForegroundColor Red
Write-Host "         -------------------- " -NoNewline -ForegroundColor Blue
Write-Host "PATHS PARSER" -NoNewline -ForegroundColor Red
Write-Host " --------------------" -ForegroundColor Blue
Write-Host "`n"

do {
    $filePath = Read-Host "Input "

    if (-not (Test-Path $filePath -PathType Leaf)) {
        Write-Host "File not Found! Try Again" -ForegroundColor Red
        $filePath = $null
    }
} while (-not $filePath)

Write-Host "`nReading: $filePath" -ForegroundColor Cyan

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

Write-Host ""
Write-Host ("{0,-15} {1}" -f "Status", "Path") -ForegroundColor Blue
Write-Host ("-" * 80)

foreach ($path in $uniquePaths) {
    if (Test-Path $path -PathType Leaf) {
        $sig = Get-AuthenticodeSignature -FilePath $path
        if ($sig.Status -ne 'Valid') {
            if ($sig.Status -eq 'NotSigned') {
                Write-Host ("{0,-15} {1}" -f "UNSIGNED", $path.ToUpper()) -ForegroundColor Red
            }
            else {
                Write-Host ("{0,-15} {1}" -f $sig.Status, $path.ToUpper()) -ForegroundColor DarkRed
            }
        }
    } else {
        Write-Host ("{0,-15} {1}" -f "DELETED", $path.ToUpper()) -ForegroundColor DarkRed
    }
}

Write-Host "`nFinished!" -ForegroundColor Green
