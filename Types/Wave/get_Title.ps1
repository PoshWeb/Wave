<#
.SYNOPSIS
    Gets the Wave's title 
.DESCRIPTION
    Gets the title of the wave.
.NOTES
    Wave Metadata is stored in an optional `LIST` chunk.

    Title (or Name) metadata is stored
    with the four letter word key: `INAM`    
#>

return $this.metadata.Title
