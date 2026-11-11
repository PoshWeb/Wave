<#
.SYNOPSIS
    Gets the Wave's Software 
.DESCRIPTION
    Gets the Software of the wave.
.NOTES
    Wave Metadata is stored in an optional `LIST` chunk.

    Software (or Name) metadata is stored
    with the four letter word key: `ISFT`
#>

return $this.metadata.Software
