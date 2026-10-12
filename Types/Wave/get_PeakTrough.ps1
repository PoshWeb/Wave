<#
.SYNOPSIS
    Gets Wave Peaks and Troughs    
.DESCRIPTION
    Gets the points in a wave that are peaks or troughs.
#>
[double[]]$samples = $this.Samples
for ($sampleNumber = 1 ; $sampleNumber -lt ($samples.Length - 1); $sampleNumber++) {

    $isPeak = 
        $samples[$sampleNumber] -gt $samples[$sampleNumber - 1] -and 
        $samples[$sampleNumber] -gt $samples[$sampleNumber + 1]

    if ($isPeak) {
        [Numerics.Vector2]::new($sampleNumber, $samples[$sampleNumber])
        
        continue
    }
    
    $isThrough =
        $samples[$sampleNumber] -lt $samples[$sampleNumber - 1] -and 
        $samples[$sampleNumber] -lt $samples[$sampleNumber + 1]        

    if ($isThrough) {
        [Numerics.Vector2]::new($sampleNumber, $samples[$sampleNumber])
        continue
    }         
}