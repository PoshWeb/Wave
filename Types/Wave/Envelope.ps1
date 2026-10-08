<#
.SYNOPSIS
    Envelope Generator
.DESCRIPTION
    An envelope is how a sound changes over time.

    An envelope multiplies the sound over time, 
    which changes a sine wave plays.

    Accepts a function 
.NOTES    
    Most notes are "attenuated", 
    which is a fancy way of saying they are softened over time.

    The default of this function, and of most envelopes, is a "hush".

    This gradually decreases the volume over time.
.LINK
    https://en.wikipedia.org/wiki/Envelope_(music)
.EXAMPLE
    # Play A4 with it's natural envelope
    wave note a4 play 
.EXAMPLE
    # Play A4 inside of a "hush" envelope 
    wave note a4 envelope play
.EXAMPLE
    # Play A4 switching phase every 40 samples
    wave note a4 envelope @(
        @(1) * 20
        @(-1) * 20
    ) play
.EXAMPLE
    # Play A4 switching phase every 200 samples
    wave note a4 envelope @(
        @(1) * 100
        @(-1) * 100
    ) play
.EXAMPLE
    # Play A4 switching phase every 100 and 300 amples
    wave note a4 envelope @(
        @(1) * 100
        @(0) * 100
        @(-1) * 100
    ) play
.EXAMPLE
    # An attack is an increase in magnitude over a short time
    wave note a4 envelope @(
        foreach ($n in 1..50) {
            $n/50
        }
    ) play
.EXAMPLE
    # A decay is a decrease in magnitude over a short time
    wave note a4 envelope @(
        foreach ($n in 1..50) {
            1 - $n/50
        }
    ) play
.EXAMPLE
    # Attack and decay
    wave note a4 envelope @(
        foreach ($n in 1..50) {
            $n/50
        }
        
        foreach ($n in 1..50) {
            1 - $n/50
        }
    ) play
.EXAMPLE
    # An attack, decay, sustain, release (ADSR)
    wave note a envelope @(
        # attack
        foreach ($n in 1..50) {
            $n/50
        }
        # decay
        foreach ($n in 25..1) {
            25 - ($n/25)/2
        }
        # sustain
        foreach ($n in 1..50) {
            0.5
        }
        
        # Release
        foreach ($n in 25..1) {
            0.5 - (1 - $n/25)
        }
    ) play
.EXAMPLE
    # An attack is an increase in magnitude over a short time
    wave note a4 envelope @(
        foreach ($step in 50, 100, 200) {
            foreach ($n in 1..$step) {
                $n/50
            }
            @(0) * $step
        }
        
    ) play
.EXAMPLE
    wave note a4 envelope @(
        foreach ($n in 1..100) {
            $n/100
        }
    ) play
.EXAMPLE
    wave note a4 envelope @(            
        foreach ($n in 100..1) {
            $n/100
        }
        foreach ($n in 1..100) {
            $n/100
        }
    ) play
.EXAMPLE
    wave note a4 envelope {
        param([double[]]$samples)
        $half = $samples.Length / 2
        $sampleNumber = 0;
        foreach ($sample in $samples) {
            if ($sampleNumber -lt $half) {
                $sample * (1 - $sampleNumber/$half)
            } else {
                $sample * (2 - $sampleNumber/$half)
            }
            $sampleNumber++
        }
    } play
#>
param($function,
[double[]]$Samples = $($This.Samples)
)

$waveFormat = $this.WaveFormat
if (-not $waveFormat) { $waveFormat = @{} }

$sampleNumber = 0
if (
    (-not $function) -or 
    ($function -in 'hush', 'normal')
) {
    # A Normal hush envelope
    $hush = 1/$samples.Count    
    return wave @waveFormat -Samples $(
        foreach ($sample in $samples) {
            $sample * (1 - ($sampleNumber * $hush))
            $sampleNumber++
        }
    )    
} 
elseif (
    $function -as [double[]]
) {
    # A custom envelope of ratios
    $customEnvelope = $function -as [double[]]
    return wave @waveFormat -Samples $(        
        foreach ($sample in $samples) {
            $sample * ($customEnvelope[$sampleNumber % $customEnvelope.Length])
            $sampleNumber++
        }
    )
}
elseif ($function -is [ScriptBlock]) {
    return wave @waveFormat -Samples $(
        & $function $Samples
    )
}
