<#
.SYNOPSIS
    Gets Wave Troughs
.DESCRIPTION
    Gets the points in the wave that are troughs.
.OUTPUTS
    Outputs a `[Numerics.Vector2]` where the X is the sample number and the Y is the sample. 
#>
param()
[double[]]$samples = $this.Samples
for ($sampleNumber = 1 ; $sampleNumber -lt ($samples.Length - 1); $sampleNumber++) {
    # If the sample
    if (        
        # is less than the previous sample
        $samples[$sampleNumber] -lt $samples[$sampleNumber - 1] -and 
        # and the next sample
        $samples[$sampleNumber] -lt $samples[$sampleNumber + 1]
    ) {
        # it is a trough.

        # Output a vector to the trough.
        # X is the sample number (time).
        # Y is the sample.
        [Numerics.Vector2]::new($sampleNumber, $samples[$sampleNumber])        
    }
}