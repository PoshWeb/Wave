<#
.SYNOPSIS
    Adds Samples
.DESCRIPTION
    Adds Samples to a wave.

    If the wave has no samples, this will simply set the samples.

    If a wave has samples, this will add the samples to the wave, 
    mixing the audio together.
#>
param(
# The other wave
$OtherWave, 
# The start time for the addition
$Time = 0
)

[double[]]$Samples = 
    if ($otherWave.pstypenames -contains 'wave') {
        $otherWave.Samples
    } elseif ($OtherWave -as [double[]]) {
        $OtherWave -as [double[]]
    }

[double[]]$current = $this.Samples

if (-not $current) {
    $this.Samples = $samples
    return $this
}

if ($Time) {
    if ($time -is [TimeSpan]) {
        $time = $time.TotalSeconds
    }
    else {
        $time = $time -as [double]
    } 
    $start = $time
} 

if (-not $start) {
    $Start = 0
}

$SampleRate = $this.SampleRate
$ChannelCount = $this.ChannelCount

$Offset = [Math]::Round($start * $SampleRate * $ChannelCount)

[double[]]$NewSamples = @(    
    if ($start -ge 
        $this.Duration.TotalSeconds
    ) {
        $deltaSamples = (
            ($this.Duration.TotalSeconds - $start) * 
                $SampleRate * $ChannelCount
        )
        if ($current.Length) {
            $current
        }
        @(0) * (
            [Math]::Round($deltaSamples)
        )        
    }
    for ($index = 0; $index -lt $samples.Count; $index++) {
        if ($current.Length -gt ($index + $Offset)) {
            $current[$index + $Offset] + ($samples[$index])
        } else {
            $samples[$index]
        }
    }
)

$this.Samples = $NewSamples
return $this