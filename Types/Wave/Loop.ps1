<#
.SYNOPSIS
    Loop a Wave
.DESCRIPTION
    Loops a Wave `-LoopCount` number of times.
.NOTES
    A loop is just a repeat of the wave data, or a copy of the array.    
#>
param(
# The Loop Count
[uint16]
$LoopCount = 1,

[byte[]]
$Data
)

if (-not $LoopCount) {
    return
}

if (-not $data) {
    $data = $this.Data
}

# We can do this very easily in PowerShell,
# as multiplying a list by an integer duplicates the list.
# So we just `*=` our existing data.
$Data * $LoopCount