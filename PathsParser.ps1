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

function Get-PECompileTime {
    param ([string]$Path)

    try {
        $fs = [System.IO.File]::OpenRead($Path)
        $br = New-Object System.IO.BinaryReader($fs)
        $fs.Seek(0x3C, 'Begin') | Out-Null
        $peOffset = $br.ReadInt32()
        $fs.Seek($peOffset + 8, 'Begin') | Out-Null
        $timestamp = $br.ReadInt32()
        $br.Close()
        $fs.Close()

        return (Get-Date "1970-01-01").AddSeconds($timestamp).ToLocalTime()
    } catch {
        return $null
    }
}

do {
    $filePath = Read-Host "Input "

    if (-not (Test-Path $filePath -PathType Leaf)) {
        Write-Host "File not Found! Try Again" -ForegroundColor Red
        $filePath = $null
    }
} while (-not $filePath)

Write-Host "`nReading: $filePath" -ForegroundColor Cyan

$paths = Get-Content -Path $filePath

$regex = '(?:[A-Za-z]:\\(?:[^\\/:*?"<>|\r\n]+\\)*[^\\/:*?"<>|\r\n]*\.\w{2,5})'
$uniquePaths = @()

foreach ($line in $paths) {
    $matches = [regex]::Matches($line, $regex)
    foreach ($match in $matches) {
        $path = $match.Value.Trim()
        if (-not $uniquePaths.Contains($path)) {
            $uniquePaths += $path
        }
    }
}


$uniquePaths = $uniquePaths | Sort-Object

Write-Host ""
Write-Host ("{0,-15} {1}" -f "Status", "Path") -ForegroundColor Blue
Write-Host ("-" * 80)

$now = Get-Date
$cutoff = $now.AddDays(-365)

foreach ($path in $uniquePaths) {
    $print = $false
    $status = ""
    $pathUpper = $path.ToUpper()

    if (-not (Test-Path $path -PathType Leaf)) {
        $status = "DELETED"
        $print = $true
    } else {
        $sig = Get-AuthenticodeSignature -FilePath $path
        if ($sig.Status -ne 'Valid') {
            $compileTime = Get-PECompileTime -Path $path
            if ($compileTime -ne $null -and $compileTime -gt $cutoff) {
                if ($sig.Status -eq 'NotSigned') {
                    $status = "UNSIGNED"
                } else {
                    $status = $sig.Status
                }

                $print = $true
            }
        }
    }

    if ($print) {
        $color = if ($status -eq "DELETED") { "DarkRed" } elseif ($status -eq "UNSIGNED") { "Red" } else { "DarkRed" }
        Write-Host ("{0,-15} {1}" -f $status, $pathUpper) -ForegroundColor $color
    }
}

Write-Host "`nFinished!" -ForegroundColor Green
