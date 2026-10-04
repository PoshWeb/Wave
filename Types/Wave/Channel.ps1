<#
.SYNOPSIS
    Wave Channels
.DESCRIPTION
    Isolates a single channel in an audio wave.
    
    Outputs a new wave with only that channel.
.NOTES
    The new wave will still be multi-channel audio,
    it will simply have silence on all other channels.
#>
param(
# The number of the channel, or `left` or `right`.
# Defaults to channel 0 left.
$Channel = 0
)

if ($this.ChannelCount -eq 1) {
    Write-Warning "Audio is mono"
    return $this
}

# If the channel was `left` or `right`, make it the correct index
if ($Channel -eq 'left') { $channel = 0 }
elseif ($channel -eq 'right') { $channel = 1 }

# If the channel is not an integer at this point
if ($channel -isnot [int]) {
    # error out.
    Write-Error "Channel must be an integer, 'left', or 'right', not $channel"
    return
}

# Collect our samples
[double[]]$Samples = $this.Samples
# and determine our number of channels
$channelCount = $this.ChannelCount

# Walk over each sample
[double[]]$ChannelSamples = @(
    for ($index = 0; $index -lt $samples.Length;$index++) {
        # determine the channel number
        $channelNumber = $index % $channelCount
        # if it is the target channel,
        if ($channelNumber -eq $channel) {
            $samples[$index] # return it as is,
        } else { # otherwise,
            0 # inject silence.
        }
    }
)

# Duplicate our current wave format
$waveFormat = $this.WaveFormat
# and return a new wave with only the desired channel.
return wave @waveFormat -Samples $ChannelSamples
