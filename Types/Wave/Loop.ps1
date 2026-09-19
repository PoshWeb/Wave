<#
.SYNOPSIS
    Loop a Wave
.DESCRIPTION
    Loops a Wave `-LoopCount` number of times.
.NOTES
    A loop is just a repeat of the wave data, or a copy of the array.
#>
[OutputType('audio/wav')]
param(
# The Loop Count.  If no loop count is specified, will loop twice.
[uint16]
$LoopCount
)

if (-not $LoopCount) { $LoopCount = 2 }

[byte[]]$data = $this.Data
# We can do this very easily in PowerShell,
# as multiplying a list by an integer duplicates the list.
# So we just `*` our existing data.
$waveFormat = $this.WaveFormat
return wave @waveFormat -PCM ($Data * $LoopCount)