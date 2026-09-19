<#
.SYNOPSIS
    Gets the Wave Time Base
.DESCRIPTION
    Gets the Wave Time Base.  
    
    This is the smallest amount of time that the wave records.
.NOTES
    Since the sample rate is the number of samples per second, 
    
    This is the reciprocal of that value, expressed as a `[TimeSpan]`
#>
param()

$sampleRate = $this.SampleRate

if (-not $sampleRate) { return [TimeSpan]::FromSeconds(0) }

if ($sampleRate) {
    [TimeSpan]::FromSeconds(
        (1 / $this.SampleRate)
    )
}