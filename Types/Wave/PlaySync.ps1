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
    $aplay = 
        $ExecutionContext.SessionState.InvokeCommand.GetCommand('aplay','Application')
    if ($aplay) {
        $filePath = $currentWave.Save().FullName
        $null = aplay $filePath
    } else {
        Write-Warning "aplay not found, cannot play sound on Linux"        
    }
} elseif ($IsMacOS) {
    $afplay = 
        $ExecutionContext.SessionState.InvokeCommand.GetCommand('afplay','Application')
    if ($afplay) {
        $filePath = $currentWave.Save().FullName
        $null = afplay $filePath
    } else {
        Write-Warning "afplay not found, cannot play sound on MacOS"
    }    
} else {
    if (-not ('Media.SoundPlayer' -as [type])) {
        Add-Type -AssemblyName System.Windows.Extensions
    }    
    $soundPlayer = [Media.SoundPlayer]::new($currentWave)
    $currentWave.Position = 0
    $soundPlayer.PlaySync()    
}