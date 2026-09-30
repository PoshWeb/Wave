<#
.SYNOPSIS
    Plays a Wave
.DESCRIPTION
    Plays a Wave file.
.NOTES
    On MacOS and Linux, uses `speaker-test` to play.

    On Windows, uses `[Media.SoundPlayer]`
.LINK
    https://learn.microsoft.com/en-us/dotnet/api/system.media.soundplayer?wt.mc_id=MVP_321542
.LINK
    https://linux.die.net/man/1/aplay
#>
param()

$currentWave = $this
# If we know what tune to play, but haven't played it yet,
if ($currentWave.Melody -and -not $currentWave.Duration) {
    $currentWave = $this.Sound() # render the wave.
}

if ($IsLinux) {
    $filePath = $currentWave.Save().FullName
    $null = Start-Process -FilePath aplay -ArgumentList $filePath
} elseif ($IsMacOS) {
    $filePath = $currentWave.Save().FullName
    $null = Start-Process -FilePath afplay -ArgumentList $filePath
} else {
    if (-not ('Media.SoundPlayer' -as [type])) {
        Add-Type -AssemblyName System.Windows.Extensions
    }    
    $soundPlayer = [Media.SoundPlayer]::new($currentWave)
    $soundPlayer.Play()
    $currentWave.Position = 0
}