<#
.SYNOPSIS
    Gets Wave Peaks
.DESCRIPTION
    Gets the points in the wave that are peaks.
.OUTPUTS
    Outputs a `[Numerics.Vector2]` where the X is the sample number and the Y is the sample. 
#>
param()
[double[]]$samples = $this.Samples
for ($sampleNumber = 1 ; $sampleNumber -lt ($samples.Length - 1); $sampleNumber++) {
    # If the sample
    if (
        # is greater than the preceeding sample and
        $samples[$sampleNumber] -gt $samples[$sampleNumber - 1] -and 
        # the next sample,
        $samples[$sampleNumber] -gt $samples[$sampleNumber + 1]
    ) {
        # it is a peak.

        # Output that peak as a vector of our start time and sample
        [Numerics.Vector2]::new(
            $sampleNumber,
            $samples[$sampleNumber]
        )
    }
}