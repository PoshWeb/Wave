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
    # and put 100 samples of silence in between
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
    wave note a4 envelope @(
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
    # Let's try some stepped attacks
    wave note a4 envelope @(
        foreach ($step in 50, 100, 200) {
            foreach ($n in 1..$step) {
                $n/50
            }
            @(0) * $step
        }
        
    ) play
.EXAMPLE
    wave note a4 envelope @(0.5) play
.EXAMPLE
    # An envelope can be a script block
    # This turns our a4 into a square
    wave note a4 envelope {
        param([double[]]$samples)
        
        $sampleNumber = 0;
        foreach ($sample in $samples) {
            if ($sample -gt 0) { 0.5 }
            elseif ($sample -lt 0 ) { -0.5 }
            $sampleNumber++
        }
    } play
.EXAMPLE
    # This makes our A4 chirp
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
.EXAMPLE
    # Things get more interesting when we make a custom envelope
    # Let's make a envelope that takes A4 mono and mixes it with a sine wave
    wave note a4 envelope {
        param(
            [double[]]$samples, 
            [double]$Angle = (220 * [Math]::PI * 2)/(44100 * 1)
        )
        
        $sampleNumber = 0
        foreach ($sample in $samples) {
            $sample + [Math]::Sin($sampleNumber * $angle)
            $sampleNumber++
        }
        $sampleNumber
    } play
.EXAMPLE
    # Compare the enveloped sound to 
    wave note a4 | wave add (wave note a3) play

    # There are many ways to describe this difference.
    # We might call it "cleaner".

    # Why?  You're listening to rounding errors.

    # A `[float]` has less precision than a `[double]`

    # When we encode the wave, we lose some decimal places of a (probably) irrational number.

    # When we're adding samples together, we're encoding and re-encoding our audio.

    # By using a custom envelope, we can harmonize without losing any data.    
.EXAMPLE
    # Let's make an even fancier envelope, 
    # one that mixes in a few lower frequencies
    wave note a4 envelope {
        param([double[]]$samples, [double[]]$Angle = @(
            ((220 * [Math]::PI * 2)/(44100 * 1)),
            ((110 * [Math]::PI * 2)/(44100 * 1))
            ((55 * [Math]::PI * 2)/(44100 * 1))
        ))
        $sampleNumber = 0;
        foreach ($sample in $samples) {
            $newSample = $sample
            foreach ($a in $angle) {
                $newSample+=[Math]::Sin($sampleNumber * $a)
            }
            $newSample 
            $sampleNumber++
        }
    } play    
.EXAMPLE
    # Let's make an even fancier envelope, 
    # one that mixes in even lower frequencies
    wave note a4 envelope {
        param([double[]]$samples, [double[]]$Angle = @(            
            ((440/2 * [Math]::PI * 2)/(44100 * 1)),
            ((440/4 * [Math]::PI * 2)/(44100 * 1))
            ((440/8 * [Math]::PI * 2)/(44100 * 1))
            ((440/16 * [Math]::PI * 2)/(44100 * 1))
            ((440/32 * [Math]::PI * 2)/(44100 * 1))
        ))
        $sampleNumber = 0;
        foreach ($sample in $samples) {
            $newSample = $sample
            foreach ($a in $angle) {
                $newSample+=[Math]::Sin($sampleNumber * $a)
            }
            $newSample 
            $sampleNumber++
        }
    } play
.EXAMPLE
    # Let's make an even fancier envelope, 
    # one that mixes in a few lower and higher frequencies    
    wave note a4 envelope {
        param([double[]]$samples, [double[]]$Angle = @(
            ((440 * [Math]::PI * 2)/(44100 * 1))
            ((440/2 * [Math]::PI * 2)/(44100 * 1)),
            ((440/4 * [Math]::PI * 2)/(44100 * 1))
            ((440/8 * [Math]::PI * 2)/(44100 * 1))
            ((440/16 * [Math]::PI * 2)/(44100 * 1))
            ((440/32 * [Math]::PI * 2)/(44100 * 1))
        ))
        $sampleNumber = 0;
        foreach ($sample in $samples) {
            $newSample = $sample
            foreach ($a in $angle) {
                $newSample+=[Math]::Sin($sampleNumber * $a)
            }
            $newSample 
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
