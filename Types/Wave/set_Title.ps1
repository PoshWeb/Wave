<#
.SYNOPSIS
    Sets the Wave's Title
.DESCRIPTION
    Sets the Wave's title metadata.
#>
param([string]$Title)

$metadata = $this.metadata
$metadata.Title = $Title
$this.Metadata = $metadata
