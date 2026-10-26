<#
.SYNOPSIS
    Sets Wave Samples
.DESCRIPTION
    Sets the samples in the Wave.

    This changes the wave.
#>
param(
# The new samples
[double[]]
$Samples
)

$BitsPerSample = 
    if ($this.BitsPerSample) { $this.BitsPerSample } 
    else { 32 }

$audioFormat = 
    if ($this.AudioFormat) { $this.AudioFormat } 
    else { 3 }

[byte[]]$NewData = @(
    if ($audioFormat -eq 1) {
        switch ($BitsPerSample) {
            8 {[Wave.WaveLinq]::EncodeByte($samples)}
            16 {[Wave.WaveLinq]::EncodeInt16($samples)}
            32 {[Wave.WaveLinq]::EncodeInt32($samples)}
        }
    }
    elseif ($audioFormat -eq 3) {
        [Wave.WaveLinq]::EncodeFloat($samples)
    }       
)

# Set our new data
$This.Data = $newData
# This will invalidate our samples, 
# so cache the sample data we just passed.
$this | 
    Add-Member NoteProperty '#Samples' $samples -Force

return $this

