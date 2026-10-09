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

$sampleNumber = 0
$progress = [Ordered]@{
    Id = Get-Random
    Status = " "
    Activity = "Encoding "
}

[byte[]]$CurrentData = $this.Data
[double[]]$CurrentSamples = $this.Samples
[int]$BlockSize = $BitsPerSample / 8

$This.Data = @(
    foreach ($sample in $samples) {
        #region Encode Sample

        if ($sampleNumber -and -not ($sampleNumber % 32kb)) {
            $progress.Status = "$sampleNumber / $($Samples.Length)"
            $progress.PercentComplete = ($sampleNumber * 100 / $samples.Length)
            Write-Progress @progress
        }

        # If we already have samples
        if ($sampleNumber -lt $CurrentSamples.Length -and (
            # and this sample did not change
            ($CurrentSamples[$sampleNumber] -eq $sample)
        )) {
            # we can skip encoding and just output the original bytes.
            $CurrentData[
                ($sampleNumber * $BlockSize)..(
                    (($sampleNumber + 1) * $BlockSize) - 1
                )
            ]
            # advance our sample number
            $sampleNumber++
            continue # and continue.
        }
    
        
        $sampleNumber++
        

        # If we are using 32-bit floating point audio
        if ($BitsPerSample -eq 32 -and $audioFormat -eq 3) {
            # we are basically done.
            <#
            
            No clamping required.
            
            Well, not technically speaking.
            
            [float] has a max value of `3.402823E+38`.
            
            Attempting to play volume at this level will likely be limited physically,
            and would likely damage speakers and eardrums far before this volume could be achieved.
            
            #> 
            
            # So we will just cast to float, 
            [BitConverter]::GetBytes([float]$sample) # get the bytes,
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
            # round each sample into bytes, with 127 as the zero point.
            [byte][Math]::Floor(
                127 + $sample * 127
            )
        }

        # If there are 16 bits per sample
        elseif ($BitsPerSample -eq 16) {
            # we just need to scale an `[int16]`
            # Hardcode `[int16]::MaxValue` for speed
            [BitConverter]::GetBytes([int16]($sample * 32767))
        }

        # If there are 32 bits per sample
        elseif ($BitsPerSample -eq 32) {
            # we can just scale to an `[int32]`.
            # Hardcode `[int32]::MaxValue` for speed
            [BitConverter]::GetBytes([int32]($sample * 2147483647))
        }
        #endregion Encode Sample
    }

    if ($progress.PercentComplete) {
        $progress.Remove('PercentComplete')
        $progress.Completed = $true
        Write-Progress @progress
    }    
)

return $this

