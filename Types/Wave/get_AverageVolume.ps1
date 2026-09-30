<#
.SYNOPSIS
    Gets Average Volume
.DESCRIPTION
    Gets the Average Volume from a wave, using the Root Mean Square
.LINK
    https://en.wikipedia.org/wiki/Root_mean_square
#>
param()

# Get our samples as a `[double[]]`
[double[]]$samples = $this.Samples

# If we had no samples, 
# the average volume is obviously zero
if (-not $samples) { return 0 }
# If we had any samples, square them
[double[]]$Squared = @(foreach ($sample in $samples) {
    $sample * $sample
})

# then average the squares and get the square root.
return [Math]::Sqrt([Linq.Enumerable]::Average($Squared))
