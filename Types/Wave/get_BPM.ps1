<#
.SYNOPSIS
    Gets Wave BPM
.DESCRIPTION
    Gets a cached BPM value from a wave.

    If no BPM has been provided, returns nothing.
#>
if ($this.'#BPM') {
    return $this.'#BPM'
}