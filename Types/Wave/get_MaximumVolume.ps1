<#
.SYNOPSIS
    Gets Maximum Volume
.DESCRIPTION
    Gets the Maximum Volume from a wave.
.NOTES
    This is the delta between the maximum and minimum sample
#>
param()
# Get our samples as a `[double[]]`
[double[]]$samples = $this.Samples

# If we did not have any samples,
# the maximum volume is obviously zero.
if (-not $samples) { return 0 }

# Otherwise, find the delta between max and min
return [Linq.Enumerable]::Max($samples) - [Linq.Enumerable]::Min($samples)    
