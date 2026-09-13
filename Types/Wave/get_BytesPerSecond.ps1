<#
.SYNOPSIS
    Gets Wave Bytes Per Block
.DESCRIPTION
    Gets the Wave Bytes Per Second.
    
    This should be `$this.SampleRate` * `$this.BytesPerBlock`
.NOTES
    This is bytes 8 to 11 in the Format `fmt ` chunk (`8..11`)
#>

# The expected range
$range = 8..11
# If we have no cached format
if (-not $this.'#fmt') {
    # read chunks.
    $null = $this.Chunk
    # Return if we still have no cached format
    if (-not $this.'#fmt') { return }
}

# Otherwise, convert the range into a [uint32]
[bitConverter]::ToUint32($this.'#fmt'[$range] -as [byte[]])