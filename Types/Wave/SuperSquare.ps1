<#
.SYNOPSIS
    SuperSquare tone Generator
.DESCRIPTION
    Generates a super square tone of a `-Frequency`, for `-Duration`, at `-Volume`

    A supersquare is made of multiple square waves, deviating by small frequencies.

    The number of squares is the `-Count`.
    
    By default it will be 4.

    The distance between each square is the `-Length`, and is measured in semitones.

    It defaults to 1/([Math]::PI / 2)
.NOTES
    A square wave is calculated by taking the sine of a given angle 
    and turning it into squares:

    ~~~PowerShell
    $sample = [Math]::Sin($t * $angle)
    $sample = 
        if ($sample -gt 0) { 1 }
        elseif ($sample -lt 0) { -1 }
        else { 0 }
    ~~~
.LINK
    https://en.wikipedia.org/wiki/Square_wave_(waveform)
#>
[OutputType('Wave')]
param(
# The frequency.
# Defaults to A4 (440hz)
[Alias('Hz')]
$Frequency = 440,

# The number of squares in the supersquare
[int]
$Count = 8,

# The distance between the frequency and the last square, in semitones.
# By default, -1/([Math]::PI * 2)
[double]
$Distance = -1/([Math]::pi * 2),

# The amount of time to generate.
[Timespan]$Duration = $(
    if ($this.BPM -is [TimeSpan]) {$this.BPM} 
    else { [TimeSpan]::FromSeconds(60/128) }
),

# The volume.
# If the current wave has set a `volume`, 
# will use that volume.
# Otherwise, will default to 1/([Math]::PI * 2)
[double]$Volume = $(
    if ($this.Volume) { $this.Volume } else { 1/([Math]::PI * 2) }    
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

$Params = [Ordered]@{} + $PSBoundParameters

$frequency = 
    foreach ($freq in $Frequency) {
        if ($freq.pstypenames -contains 'MidiNote') {
            $freq.Frequency
        } else {
            $freq -as [double]
        }
    }

$stepLength = $distance/$Count
$frequency =
    foreach ($freq in $Frequency) {        
        foreach ($square in 1..[Math]::Abs($Count)) {
            $freq * [Math]::Pow(2, ((
                $stepLength * (
                    $square - 1
                ) * -1.0)/12
            ))        
        }
    }

$params.Remove('Count')
$params.Remove('Distance')
$params['Frequency'] = $Frequency

$currentWave = $this
if (-not $currentWave) { $currentWave = wave }
return & $currentWave.Square.Script @params
