<#
.SYNOPSIS
    Gets Wave Volume
.DESCRIPTION
    Gets a cached Volume value from a wave.

    This is used to provide a default value for Wave methods that use `-Volume`.

    If no Volume has been provided, will measure the volume of the samples.
#>
if ($this.'#Volume') {
    return $this.'#Volume'
}
$samples = $this.Samples
# Get our samples as a `[double[]]`
[double[]]$samples = $this.Samples

# If we had any samples
if ($samples) {
    # then the max volume of the entire sequence is the max minus the min.
    return [Linq.Enumerable]::Max($samples) - [Linq.Enumerable]::Min($samples)    
} else {
    return 0
}