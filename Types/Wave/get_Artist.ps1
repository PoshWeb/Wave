<#
.SYNOPSIS
    Gets the Wave's Artist 
.DESCRIPTION
    Gets the Wave Artist metadata.
.NOTES
    Wave Metadata is stored in an optional `LIST` chunk.

    Artist metadata is stored
    with the four letter word key: `IART`
#>

return $this.metadata.Artist
