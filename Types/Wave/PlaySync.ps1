<#
.SYNOPSIS
    Plays a Wave Synchronously
.DESCRIPTION
    Plays a Wave file and waits for the play to complete.
.NOTES
    On MacOS and Linux, uses `speaker-test` to play.

    On Windows, uses `[Media.SoundPlayer]`
.LINK
    https://learn.microsoft.com/en-us/dotnet/api/system.media.soundplayer?wt.mc_id=MVP_321542
.LINK
    https://linux.die.net/man/1/speaker-test
#>
param()

$currentWave = $this
# If we know what tune to play, but haven't played it yet,
if ($currentWave.Melody -and -not $currentWave.Duration) {
    $currentWave = $this.Sound() # render the wave.
}

if ($IsLinux) {
    $filePath = $currentWave.Save().FullName
    $null = aplay $filePath
} elseif ($IsMacOS) {
    $filePath = $currentWave.Save().FullName
    $null = afplay $filePath
} else {
    if (-not ('Media.SoundPlayer' -as [type])) {
        Add-Type -AssemblyName System.Windows.Extensions
    }    
    $soundPlayer = [Media.SoundPlayer]::new($currentWave)
    $currentWave.Position = 0
    $soundPlayer.PlaySync()    
}