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

Write-Host "nReading: $filePath!" -ForegroundColor Cyan

$regex = '(?:[a-zA-Z]:|\\\\\?\\|\\\?\?\\|\\\?\\|\\\?\\\?\\)[^\r\n<>:"|?*]*?\.[a-zA-Z]{1,4}(?=\s|$)'
$uniquePaths = @()
$paths = Get-Content -Path $filePath

foreach ($line in $paths) {
    if ($line.ToLower().Contains("manifest")) { continue }

    # Entferne config-Endungen vor dem Match
    $line = $line -replace "\.\d*\.confi?g", ""

    $matches = [regex]::Matches($line, $regex)
    foreach ($match in $matches) {
        Write-Host($match)
        $path = $match.Value.Trim()
        Write-Host $path
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
    $print = $false  # Reset print flag for each path
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
        $color = switch ($status) {
            "DELETED"  { "DarkRed" }
            "UNSIGNED" { "Red" }
            default    { "DarkRed" }
        }
        Write-Host ("{0,-15} {1}" -f $status, $pathUpper) -ForegroundColor $color
    }
}


Write-Host "nFinished!" -ForegroundColor Green
