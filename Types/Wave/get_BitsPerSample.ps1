<#
.SYNOPSIS
    Gets Wave Bits Per Sample
.DESCRIPTION
    Gets the Wave Bits Per Sample.  This should either 8 or 16
.NOTES
    This is the last pair of bytes in the Format `fmt ` chunk.    
#>

# The expected range
$range = 14,15
# If we have no cached format
if (-not $this.'#fmt') {
    # read chunks.
    $null = $this.Chunk
    # Return if we still have no cached format
    if (-not $this.'#fmt') { return }
}

# Otherwise, convert the range into a [uint16]
[bitConverter]::ToUint16($this.'#fmt'[$range] -as [byte[]])