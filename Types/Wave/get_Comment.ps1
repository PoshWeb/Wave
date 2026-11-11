<#
.SYNOPSIS
    Gets the Wave's Comment 
.DESCRIPTION
    Gets the Wave Comment metadata.
.NOTES
    Wave Metadata is stored in an optional `LIST` chunk.

    Comment metadata is stored
    with the four letter word key: `ICMT`
#>

return $this.metadata.Comment
