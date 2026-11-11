<#
.SYNOPSIS
    Sets the Wave's Title
.DESCRIPTION
    Sets the Wave's title metadata.
.NOTES
    Wave Metadata is stored in an optional `LIST` chunk,
    with the four letter word key: `INAM`
#>
param([string]$Title)

$metadata = $this.metadata
$metadata.Title = $Title
$this.Metadata = $metadata
