<#
.SYNOPSIS
    Gets Wave Format
.DESCRIPTION
    Gets the Wave Format as a dictionary
.NOTES
    This simplifies the construction of a new wave in the same format.
.EXAMPLE
    $wav = wave -AudioFormat 3 
    $waveFormat = $wav.WaveFormat
    $wave2 = wave @waveFormat    
#>
$waveFormat = [Ordered]@{} 

# The expected range is 0,1 (first two bytes)
$range = 0,1
# If we have no cached format
if (-not $this.'#fmt') {
    # read chunks.
    $null = $this.Chunk
    # Return if we still have no cached format
    if (-not $this.'#fmt') { return }
}

$waveFormat['AudioFormat'] = [BitConverter]::ToUInt16($this.'#fmt', 0)
$waveFormat['ChannelCount'] = [BitConverter]::ToUInt16($this.'#fmt', 2)
$waveFormat['SampleRate'] = [BitConverter]::ToUInt32($this.'#fmt', 4)
$waveFormat['BytesPerSecond'] = [BitConverter]::ToUInt32($this.'#fmt', 8)
$waveFormat['BytesPerBlock'] = [BitConverter]::ToUInt16($this.'#fmt', 12)
$waveFormat['BitsPerSecond'] = [BitConverter]::ToUInt16($this.'#fmt', 14)

return $waveFormat