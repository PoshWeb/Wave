<#
.SYNOPSIS
    Gets a table of the scales starting on the current note.
.DESCRIPTION
	Constructs a hashtable of the major and minor scales stemming from the current note.
#>
$majorScale = New-Object System.Collections.ArrayList

$majorScale.Add($this) > $null

$currentNote = $this

#Start with constructing the major scale
foreach ($step in ("WWHWWWH".ToCharArray())) { #Standard major scale step pattern
	$stepCount = if ($step -eq "W") { 2 } else { 1 }
	$currentNote = $currentNote.Sharpen($stepCount)
	$majorScale.Add($currentNote) > $null
}

$scaleTable = [Ordered]@{
	Major = $majorScale.Clone()
	Minor = $majorScale.Clone()
	HarmonicMinor = $majorScale.Clone()
	MelodicMinor = $majorScale.Clone()
}

# The minor scales are just the major scale with certain scale degrees flattened
$flat3rd = $majorScale[2].Flatten(1)
$scaleTable["Minor"][2] = $flat3rd
$scaleTable["HarmonicMinor"][2] = $flat3rd
$scaleTable["MelodicMinor"][2] = $flat3rd

$flat6th = $majorScale[5].Flatten(1)
$scaleTable["Minor"][5] = $flat6th
$scaleTable["HarmonicMinor"][5] = $flat6th

$scaleTable["Minor"][6] = $majorScale[6].Flatten(1)

$scaleTable["Major-Descending"]= $scaleTable["Major"].Clone()
$scaleTable["Major-Descending"].Reverse()

$scaleTable["Minor-Descending"]= $scaleTable["Minor"].Clone()
$scaleTable["Minor-Descending"].Reverse()

$scaleTable["HarmonicMinor-Descending"]= $scaleTable["HarmonicMinor"].Clone()
$scaleTable["HarmonicMinor-Descending"].Reverse()

$scaleTable
