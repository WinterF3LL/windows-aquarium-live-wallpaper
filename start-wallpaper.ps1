param([string]$GodotPath)

$ErrorActionPreference = "Stop"
$pidFile = Join-Path $PSScriptRoot '.wallpaper-pid'
if (Test-Path -LiteralPath $pidFile) {
    $runningId = [int](Get-Content -LiteralPath $pidFile -ErrorAction SilentlyContinue)
    $running = Get-Process -Id $runningId -ErrorAction SilentlyContinue
    if ($running) {
        Write-Host 'Akvaryum zaten calisiyor.'
        exit 0
    }
    Remove-Item -LiteralPath $pidFile -ErrorAction SilentlyContinue
}
if (-not $GodotPath) {
    $command = Get-Command godot, godot4 -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($command) {
        $GodotPath = $command.Source
    } else {
        $metadata = Join-Path $PSScriptRoot '.godot/editor/project_metadata.cfg'
        if (Test-Path -LiteralPath $metadata) {
            $match = [regex]::Match((Get-Content -LiteralPath $metadata -Raw), 'executable_path="([^"]+)"')
            if ($match.Success) { $GodotPath = $match.Groups[1].Value }
        }
    }
}
if (-not $GodotPath -or -not (Test-Path -LiteralPath $GodotPath)) {
    throw 'Godot bulunamadi. -GodotPath ile Godot exe dosyasinin yolunu belirtin.'
}

Write-Host 'Akvaryum yukleniyor; ilk goruntu geldikten sonra masaustune gececek.'
Write-Host 'Durdurmak icin bu konsolda Ctrl+C kullanin.'
$stopFile = Join-Path $PSScriptRoot '.wallpaper-stop'
$coveredFile = Join-Path $PSScriptRoot '.wallpaper-covered'
Remove-Item -LiteralPath $stopFile -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $coveredFile -ErrorAction SilentlyContinue
$game = Start-Process -FilePath $GodotPath -ArgumentList @('--path', ('"{0}"' -f $PSScriptRoot), '--', '--wallpaper') -WindowStyle Hidden -PassThru
Set-Content -LiteralPath $pidFile -Value $game.Id
$monitorSource = Join-Path $PSScriptRoot 'native\windows_wallpaper\VisibilityMonitor.cs'
$monitorExe = Join-Path $PSScriptRoot 'native\windows_wallpaper\VisibilityMonitor.exe'
$compiler = "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if (-not (Test-Path -LiteralPath $monitorExe) -or (Get-Item $monitorSource).LastWriteTime -gt (Get-Item $monitorExe).LastWriteTime) {
    & $compiler /nologo /target:winexe /optimize+ /out:$monitorExe $monitorSource
    if ($LASTEXITCODE -ne 0) { throw 'Gorunurluk izleyicisi derlenemedi.' }
}
$monitor = Start-Process -FilePath $monitorExe -ArgumentList @($game.Id, ('"{0}"' -f $coveredFile), ('"{0}"' -f $stopFile)) -WindowStyle Hidden -PassThru
try {
    while (-not $game.WaitForExit(200)) { }
} finally {
    if (-not $game.HasExited) {
        Set-Content -LiteralPath $stopFile -Value 'stop'
        if (-not $game.WaitForExit(3000)) {
            $game.Kill()
            $game.WaitForExit()
        }
    }
    Remove-Item -LiteralPath $stopFile -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $coveredFile -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $pidFile -ErrorAction SilentlyContinue
}
