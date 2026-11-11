<#
.SYNOPSIS
    Gets the Wave's Genre 
.DESCRIPTION
    Gets the Wave Genre metadata.
.NOTES
    Wave Metadata is stored in an optional `LIST` chunk.

    Genre metadata is stored
    with the four letter word key: `IGNR`
#>

return $this.metadata.Genre
