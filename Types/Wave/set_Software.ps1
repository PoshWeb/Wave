<#
.SYNOPSIS
    Sets the Wave's Software
.DESCRIPTION
    Sets the Wave's Software metadata.
.NOTES
    Wave Metadata is stored in an optional `LIST` chunk.

    Software metadata is stored
    with the four letter word key: `ISFT`

    The software is usually the software that last changed the wave.

    When files are saved, this field should be set to:
    
    `Wave $Version https://github.com/PoshWeb/Wave`
#>
param([int]$Software)

$metadata = $this.metadata
$metadata.Software = "$Software"
$this.Metadata = $metadata
