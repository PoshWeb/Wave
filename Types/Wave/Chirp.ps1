<#
.SYNOPSIS
    Chirp Wave
.DESCRIPTION
    Chirp Wave generator.
    
    Generates a Wave that "chirps" between two frequencies.  
    
    This gets softer as it approaches the half, then louder as it approaches the end.
#>
param(
# The frequency
[Alias('Hz')]
[float]$Frequency = 0,

[Alias('Hz2')]
[float]$ToFrequency = 0,

# The amount of time to generate.
[Timespan]$Duration = $(
    if ($this.BPM -is [TimeSpan]) {$this.BPM} 
    else { [TimeSpan]::FromSeconds(60/128) }
),

# The volume
[float]$Volume = 0.5
)


if ($Frequency -eq 0) {
    $Frequency = 440
}

if ($ToFrequency -eq 0) {
    $ToFrequency = $Frequency / 2
}

# Cache our property values, so we are not wasting cycles.
$sampleRate = $this.SampleRate
$channelCount = $this.ChannelCount
$BytesPerSecond = $this.BytesPerSecond
$BitsPerSample = $this.BitsPerSample

# Cache our references, for the minor speed boost it may give us.
$math = [Math]
$BitConverter = [BitConverter]

# Calculate the number of samples
$numberOfSamples = $math::Round($Duration.TotalSeconds * $BytesPerSecond) 

# Our step size is the bits per sample / 8
$step = $BitsPerSample/8


# The divisor will remain the same, so compute it now.
$divisor = ($sampleRate * $channelCount * $step)

$half = $numberOfSamples / 2

# Generate one sample at a time.
for ($i = 0; $i -lt $numberOfSamples; $i+=$step) {
    
    $t = $i/$numberOfSamples
    # Calculate the envelope
    $envelope = 1.0 - $t

    $currentFrequency = if ($i -lt $half) {
        $Frequency
    } else {
        $ToFrequency
    }
        
    $envelope = if ($i -lt $half) {
        1.0 - ($i / $half)
    } else {
        1.0 - ($i - $half) / ($numberOfSamples - $half)
    }

    # We can imagine each cycle as a series of circles
    # how many circles?  Whatever our frequency may be.
    $cycle = 2 * $math::PI * $currentFrequency
    
    # Calculate the angle at this point in time (in radians)
    $angle = ($cycle * $i) / $divisor    

    # The sample at this moment is the sine of that angle
    $sample = $math::Sinh($math::Sin($angle))

    # We will scale this by the volume, and then by the envelope.
    $sample = $sample * $Volume * $envelope

    # Clamp our sample
    $sample = $math::Clamp($sample, -1.0, 1.0)

    #region Encode Sample

    # We _could_ encapsulate the encoding off into it's own procedure.

    # However, callstacks have overhead.

    # Inline code will be quicker.
    # (hence duplicating it across multiple files)

    # If there are 8 bits per sample
    if ($BitsPerSample -eq 8) {
        # round each sample into bytes, with 128 as the zero point.
        [byte]$math::Round(
            128 + $sample * 127
        )
    }

    # If there are 16 bits per sample
    elseif ($BitsPerSample -eq 16) {
        # we just need to scale an `[int16]`
        # Hardcode `[int16]::MaxValue` for speed
        $BitConverter::GetBytes([int16]($sample * 32767))
    }

    # If there are 32 bits per sample
    elseif ($BitsPerSample -eq 32) {
        # we can just scale to an `[int32]`.
        # Hardcode `[int32]::MaxValue` for speed
        $BitConverter::GetBytes([int32]($sample * 2147483647))
    }
    #endregion Encode Sample
}



return
