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

# Silence is nothing
$silence = @(0)

# An array of silence is nothing times the number of samples
return ,[double[]]$($silence * [Math]::Round(    
    $Duration.TotalSeconds * $SampleRate * $channelCount
) )
