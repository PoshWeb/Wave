<#
.SYNOPSIS
    Sets a custom scale 
.DESCRIPTION
    Sets a custom scale for a frequency.

    Setting an empty hashtable will reset the scales.
#>
param(
# One or more custom scales
[Collections.IDictionary]$Scale
)

if ((-not $scale.Count) -and $this.'#Scale'.Clear) {
    $this.'#Scale' = $null
}

$thisScale = $this.Scale
foreach ($key in $scale.Keys) {
    $thisScale[$key] = $scale[$key]
}
