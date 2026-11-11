<#
.SYNOPSIS
    Sets the Wave's Title
.DESCRIPTION
    Sets the Wave's title metadata.
.NOTES
    Metadata is stored in an optional `LIST` chunk,
    within an `INAM` item.    
#>
param([string]$Title)

$metadata = $this.metadata
$metadata.Title = $Title
$this.Metadata = $metadata
