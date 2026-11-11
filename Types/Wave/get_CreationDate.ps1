<#
.SYNOPSIS
    Gets the Wave's CreationDate 
.DESCRIPTION
    Gets the Wave CreationDate metadata.
.NOTES
    Wave Metadata is stored in an optional `LIST` chunk.

    CreationDate metadata is stored
    with the four letter word key: `ICRD`
#>

return $this.metadata.CreationDate
