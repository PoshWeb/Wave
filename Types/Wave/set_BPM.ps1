<#
.SYNOPSIS
    Sets the beats per minute
.DESCRIPTION
    Sets a common BPM used to generate notes in a wave.
#>
param(
$BPM
)

if ($bpm -is [TimeSpan]) {
    # If the BPM is already a timespan, just cache it
    $this | 
        Add-Member NoteProperty '#BPM' $bpm -Force
    return
} else {
    # Otherwise, strip anything that is not a digit or a period
    $bpm = $bpm -replace '[\D-[\.]]' -as [float] # and cast it to float.

    # If that worked, 
    if ($bpm) {
        # convert it into a timespan.    
        $this | 
            Add-Member NoteProperty '#BPM' (
                [TimeSpan]::FromSeconds(
                    60/$bpm
                )
            ) -Force
    }
}



