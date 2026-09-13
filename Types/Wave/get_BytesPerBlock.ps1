<#
.SYNOPSIS
    Gets Wave Bytes Per Block
.DESCRIPTION
    Gets the Wave Bytes Per Block.
    
    This should be `$this.BitsPerSample/8` * `$this.ChannelCount`
.NOTES
    This is the second to last pair of bytes in the Format `fmt ` chunk (`12,13`)
#>

# The expected range
$range = 12,13
# If we have no cached format
if (-not $this.'#fmt') {
    # read chunks.
    $null = $this.Chunk
    # Return if we still have no cached format
    if (-not $this.'#fmt') { return }
}

# Otherwise, convert the range into a [uint16]
[bitConverter]::ToUint16($this.'#fmt'[$range] -as [byte[]])