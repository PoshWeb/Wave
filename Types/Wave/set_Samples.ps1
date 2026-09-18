param(
[float[]]
$Samples
)

$BitsPerSample = 
    if ($this.BitsPerSample) { $this.BitsPerSample } 
    else { 8 }

$audioFormat = 
    if ($this.AudioFormat) { $this.AudioFormat } 
    else { 1 }

$GetBytes = [BitConverter]::GetBytes

$This.Data = @(
    foreach ($sample in $samples) {
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

        # If we are dealing with whole number audio formats,
        # We've got to clamp it down to an amplitude between -1 and 1.

        # Unfortunately, `Clamp` is not part of older .NET framework versions
        # So we will clamp the old-fashioned way, with an `if`
        if ($sample -gt 1) { $sample = 1 }
        elseif ($sample -lt -1) { $sample = -1 }

        # If there are 8 bits per sample
        if ($BitsPerSample -eq 8) {        
            # round each sample into bytes, with 128 as the zero point.
            [byte][Math]::Round(
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
)

return

