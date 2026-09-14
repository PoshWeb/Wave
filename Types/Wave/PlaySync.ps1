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

if ($IsMacOS -or $IsLinux) {
    speaker-test -w $this.Save().FullName
} else {
    if (-not ('Media.SoundPlayer' -as [type])) {
        Add-Type -AssemblyName System.Windows.Extensions
    }    
    $soundPlayer = [Media.SoundPlayer]::new($this)
    $soundPlayer.PlaySync()
    $this.Position = 0
}