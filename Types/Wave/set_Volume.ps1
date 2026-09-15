<#
.SYNOPSIS
    Sets BPM
.DESCRIPTION
    Sets a common BPM used by the wave.
#>
param(
[float]
$Volume = 0.5
)

$this | 
    Add-Member NoteProperty '#Volume' $Volume -Force
return
