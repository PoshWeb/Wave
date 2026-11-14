<#
.SYNOPSIS
    Gets Wave Data
.DESCRIPTION
    Gets the byte[] describing a wave.
#>
[CmdletBinding()]
param()

# If we have not cached our data chunk
if (-not $this.'#data') {
    # read chunks
    $null = $this.Chunk
    # If there is still nothing
    if (-not $this.'#data') {
        return # return nothing.
    }
}

if ($this.'#samples') {
    return $this.'#samples'
}

$bitsPerSample = $this.BitsPerSample
if (-not $bitsPerSample) { $bitsPerSample = 8}
$audioFormat = $this.AudioFormat
if (-not $audioFormat) { $audioFormat = 1 }
[byte[]]$PCM = $this.'#data'
[double[]]$Samples =
    if ($audioFormat -eq 3) {
        [Wave.WaveLinq]::DecodeFloat($PCM)
    } elseif ($audioFormat -eq 1) {
        if ($bitsPerSample -eq 8) {
            [Wave.WaveLinq]::DecodeByte($PCM)
        }
        elseif ($bitsPerSample -eq 16) {
            [Wave.WaveLinq]::DecodeInt16($PCM)
        }
        elseif ($bitsPerSample -eq 32) {            
            [Wave.WaveLinq]::DecodeInt32($PCM)
        }
    }

$this | Add-Member NoteProperty '#samples' $samples -Force
# Use the comma operator to return a list containin the data, 
# so that it unrolls to the data itself (rather than tries to stream the bytes)
return ,$this.'#samples'
