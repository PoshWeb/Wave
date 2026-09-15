<#
.SYNOPSIS
    Silence Generator
.DESCRIPTION
    Generates a Silence for a `-Time`
#>
param(
# The duration to generate.
[Timespan]$Duration = $(
    if ($this.BPM -is [TimeSpan]) {$this.BPM} 
    else { [TimeSpan]::FromSeconds(60/128) }
)
)

# Cache our property values, so we are not wasting cycles.
$BytesPerSecond = $this.BytesPerSecond
$BitsPerSample = $this.BitsPerSample

# Cache our references, for the minor speed boost it may give us.
$math = [Math]
$BitConverter = [BitConverter]

# Calculate the number of samples
$numberOfSamples = $math::Round($Duration.TotalSeconds * $BytesPerSecond) 

# Our step size is the bits per sample / 8
$step = $BitsPerSample/8


$silenceBytes = @(
    # Silence is zero
    $sample = 0

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
        $BitConverter::GetBytes([int16]0)
    }

    # If there are 32 bits per sample
    elseif ($BitsPerSample -eq 32) {
        # we can just scale to an `[int32]`
        $BitConverter::GetBytes([int32]0)
    }    
)

$silenceBytes * ($numberOfSamples/$step)