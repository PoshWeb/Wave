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
$bitConverter = [BitConverter]


$step = $bitsPerSample/8
$samples = for ($i =0; $i -lt $PCM.Length; $i+=$step) {
    if ($audioFormat -eq 1 -and $bitsPerSample -eq 8) {
        ($PCM[$i] / 255) - 0.5
    }
    elseif ($audioFormat -eq 1 -and $bitsPerSample -eq 16) {
        $bitConverter::ToUint16($PCM, $i) / 32767
    }
    elseif ($audioFormat -eq 1 -and $bitsPerSample -eq 32) {
        $bitConverter::ToUint32($PCM, $i) / 2147483647
    }
    elseif ($audioFormat -eq 3 -and $bitsPerSample -eq 32) {
        $bitConverter::ToSingle($PCM, $i) -as [double]
    }
}

$this | Add-Member NoteProperty '#samples' $samples -Force

# Use the comma operator to return a list containin the data, 
# so that it unrolls to the data itself (rather than tries to stream the bytes)
return ,$this.'#samples'
