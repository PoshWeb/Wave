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
    $aplay = 
        $ExecutionContext.SessionState.InvokeCommand.GetCommand('aplay','Application')
    if ($aplay) {
        $filePath = $currentWave.Save().FullName
        $null = Start-ThreadJob -ScriptBlock {
            param([string]$FilePath)
            aplay $FilePath
        } -Name $file.Name -ArgumentList $file.FullName -ThrottleLimit 1kb        
    } else {
        Write-Warning "aplay not found, cannot play sound on Linux"        
    }
} elseif ($IsMacOS) {
    $afplay = 
        $ExecutionContext.SessionState.InvokeCommand.GetCommand('afplay','Application')
    if ($afplay) {
        $file = $currentWave.Save()
        $null = Start-ThreadJob -ScriptBlock {
            param([string]$FilePath)
            afplay $FilePath
        } -Name $file.Name -ArgumentList $file.FullName -ThrottleLimit 1kb
    } else {
        Write-Warning "afplay not found, cannot play sound on MacOS"
    }    
} else {
    if (-not ('Media.SoundPlayer' -as [type])) {
        Add-Type -AssemblyName System.Windows.Extensions
    }    
    $soundPlayer = [Media.SoundPlayer]::new($currentWave)
    $soundPlayer.Play()
    $currentWave.Position = 0
}