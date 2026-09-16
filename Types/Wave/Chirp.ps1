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
[float]$Volume = 0.5,

# The sample rate.
# Will default to the `.SampleRate` of `$this` wave.
# If there is no `$this` wave, will default to 44100
[uint32]$SampleRate = $(
    if ($this.SampleRate) { $this.SampleRate } 
    else { 44100 }
),


# The bits per sample.
# Will default to the `.BitsPerSample` of `$this` wave.
# If there is no `$this` wave, will default to 4.
[uint16]$BitsPerSample = $(
    if ($this.BitsPerSample) { $this.BitsPerSample } 
    else { 4 }
),

# The channel count.
# Will default to the `.ChannelCount` of `$this` wave.
# If there is no `$this` wave, will default to 1 (mono).
[uint16]$channelCount = $(
    if ($this.ChannelCount) { $this.ChannelCount } 
    else { 1 }
),

# The audio format.
# Will default to the `.AudioFormat` of `$this` wave.
# If there is no `$this` wave, will default to 3 (IEEE floating point).
[uint16]$AudioFormat = $(
    if ($this.AudioFormat) { $this.AudioFormat } 
    else { 3 }
)
)


if ($Frequency -eq 0) {
    $Frequency = 440
}

if ($ToFrequency -eq 0) {
    $ToFrequency = $Frequency / 2
}

$BytesPerSecond = $SampleRate * $channelCount * $BitsPerSample/8

# Cache our references, for the minor speed boost it may give us.
$math = [Math]
$getBytes = [BitConverter]::GetBytes

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

    #region Encode Sample

    # We _could_ encapsulate the encoding off into it's own procedure.

    # However, callstacks have overhead.

    # Inline code will be quicker.
    # (hence duplicating it across multiple files)

    # If we are using 32-bit floating point audio
    if ($BitsPerSample -eq 32 -and $audioFormat -eq 3) {
        # we are basically done.
        # No clamping required. # Just cast to float, 
        $GetBytes.Invoke([float]$sample) # get the bytes,
        continue # and continue 
    }
    
    # If we are dealing with [byte], [int16], or [int32] audio formats,
    # We've got to clamp it down to an amplitude between -1 and 1.    

    # Unfortunately, `Clamp` is not part of older .NET framework versions
    # So we will clamp with `min` and `max`.
    $sample = $math::min(1, $math::Max($sample, -1))

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
        $GetBytes.Invoke([int16]($sample * 32767))
    }

    # If there are 32 bits per sample
    elseif ($BitsPerSample -eq 32) {
        # we can just scale to an `[int32]`.
        # Hardcode `[int32]::MaxValue` for speed
        $GetBytes.Invoke([int32]($sample * 2147483647))
    }
    #endregion Encode Sample
}



return
