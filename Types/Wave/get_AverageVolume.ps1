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

# If we had any samples
if (-not $samples) { return 0 }    
[double[]]$Squared = @(foreach ($sample in $samples) {
    $sample * $sample
})

return [Math]::Sqrt([Linq.Enumerable]::Average($Squared))
