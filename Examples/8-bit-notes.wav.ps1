<#
.SYNOPSIS
    Generates 8 bit notes
.DESCRIPTION
    Generates 88 notes in 8-bit mono, 
    and outputs how long it took.
#>
Push-Location $PSScriptRoot
$wav = wave
$waves = @()
$waveFiles = @()
$waveGenerationTime = Measure-Command {
    foreach ($note in $wav.NoteFrequency.Keys) {
    $wavePath = "./8bit/$(
        $note -replace '#','Sharp'
    ).wav"
#if (-not (Test-Path $wavePath)) {
        $wave = wave tone $wav.NoteFrequency[$note]
        $waveFiles += $wave.Save($wavePath)
        $waves += $wave
#}    
    }
}

$totalDuration = $waves | 
    ForEach-Object -Begin {
        $sum = 0
    } -Process {
        $sum += $_.duration.TotalSeconds
    } -End {
        [TimeSpan]::FromSeconds($Sum)
    }
    
$speed = $totalDuration/$waveGenerationTime 
"Generated $($waves.Length) waves with a total duration of $totalDuration in $waveGenerationTime : Speed $speed"
Pop-Location