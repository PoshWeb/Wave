<#
.SYNOPSIS
    Gets the Wave's Album 
.DESCRIPTION
    Gets the Wave Album metadata.
.NOTES
    Wave Metadata is stored in an optional `LIST` chunk.

    Album (or Product) metadata is stored
    with the four letter word key: `IPRD`
#>

return $this.metadata.Album
