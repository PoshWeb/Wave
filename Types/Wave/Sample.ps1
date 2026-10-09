<#
.SYNOPSIS
    Samples Waves
.DESCRIPTION
    Samples a wave, grabbing audio between two points in time.
.EXAMPLE
    # Sample the back half of a note
    $a4 = wave note a4 
    $a4.Sample(
        $a4.Duration / 2
    ).Play()
.EXAMPLE
    # Sample the front half of a note
    $a4 = wave note a4 
    $a4.Sample(
        0, $a4.Duration / 2
    ).Play()
.EXAMPLE
    # Sample the last quarter of the wave
    $a4 = wave note a4 
    $a4.Sample(
        $a4.Duration * 0.75
    ).Play()
.EXAMPLE
    # Sample the third quarter of the wave
    $a4 = wave note a4 
    $a4.Sample(
        $a4.Duration * 0.5, $a4.Duration * 0.75
    ).Play()
#>
[OutputType('audio/wav')]
param(
# The start time.
$Start = 0,
# The end time. 
$End = 0
)

if ($start -is [TimeSpan]) {
    $start = $start.TotalSeconds
} elseif ($start -as [double]) {
    $start = $start -as [double]
}

if ($end -is [TimeSpan]) {
    $end = $end.TotalSeconds
} elseif ($end -as [double]) {
    $end = $end -as [double]
}

if (-not $start) { $start = 0 }
if (-not $end)   { $end   = $this.Duration.TotalSeconds }



# If we are not actually pulling a shorter timeframe, 
if ($start -eq 0 -and $end -eq $this.Duration.TotalSeconds) {
    # we aren't really sampling.  Just return ourself.
    return $this
}

$t = [TimeSpan]::FromSeconds(0)
$timeBase = $this.TimeBase

[double[]]$samples = $this.Samples

$waveFormat = $this.WaveFormat

[double[]]$NewSamples = @(
    for ($index = 0 ; $index -lt $samples.Length; $index++) {        
        $t = ($timeBase * $index).TotalSeconds
        if (($t -ge $start) -and 
            ($t -le $end)) {
            $samples[$index]
        }
    }
)

wave @waveFormat -Samples $NewSamples