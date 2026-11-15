<#
.SYNOPSIS
    Silence Generator
.DESCRIPTION
    Generates a Silence for a `-Duration`
#>
[OutputType([double[]])]
param(
# The duration to generate.
[Timespan]$Duration = $(
    if ($this.BPM -is [TimeSpan]) {$this.BPM} 
    else { [TimeSpan]::FromSeconds(60/128) }
),

# The start time.
$Time,

# The sample rate.
# Will default to the `.SampleRate` of `$this` wave.
# If there is no `$this` wave, will default to 44100
[uint32]$SampleRate = $(
    if ($this.SampleRate) { $this.SampleRate } else { 44100 }
),

# The channel count.
# Will default to the `.ChannelCount` of `$this` wave.
# If there is no `$this` wave, will default to 1 (mono).
[uint16]$channelCount = $(
    if ($this.ChannelCount) { $this.ChannelCount } else { 1 }
)
)

$NewWave = $this
if (-not $newWave) { $NewWave = wave }

if (-not $Time) {
    $time = $NewWave.Duration
}

# Silence is nothing
$silence = @(0)

# We will add silence to the new wave.
return $newWave.Add(
    [double[]]@(
        @(0) * # silence is nothing
        [Math]::Round(
            # and we want the `$Duration` seconds of sample
            $Duration.TotalSeconds * $SampleRate * $channelCount
        )
    ), 
    $time # and add it at the specified time.
)

