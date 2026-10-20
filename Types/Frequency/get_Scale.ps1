<#
.SYNOPSIS
    Gets a table of the scales starting on the current note.
.DESCRIPTION
	Constructs a hashtable of the major and minor scales stemming from the current note.
#>
param()

if ($this.'#Scale') { return $this.'#Scale'}

# Arraylists maintain underlying psuedotypes, 
# so we can construct our scales from `$this`
$majorScale = [Collections.ArrayList]::new()
$null = $majorScale.Add($this)

$currentNote = $this

#Start with constructing the major scale
foreach ($step in ("WWHWWWH".ToCharArray())) { #Standard major scale step pattern
	$stepCount = if ($step -eq "W") { 2 } else { 1 }
	$currentNote = $currentNote.Sharpen($stepCount)
	$null = $majorScale.Add($currentNote)
}

$scaleTable = [Ordered]@{
	Major = $majorScale.Clone()
	'MajorDescending' = $majorScale.Clone()
	Minor = $majorScale.Clone()
	'MinorDescending' = $majorScale.Clone()
	HarmonicMinor = $majorScale.Clone()
	HarmonicMinorDescending = $majorScale.Clone()
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

$scaleTable["MajorDescending"]= $scaleTable["Major"].Clone()
$scaleTable["MajorDescending"].Reverse()

$scaleTable["MinorDescending"]= $scaleTable["Minor"].Clone()
$scaleTable["MinorDescending"].Reverse()

$scaleTable["HarmonicMinorDescending"]= $scaleTable["HarmonicMinor"].Clone()
$scaleTable["HarmonicMinorDescending"].Reverse()

$this | Add-Member NoteProperty '#Scale' $scaleTable -Force
return $scaleTable
