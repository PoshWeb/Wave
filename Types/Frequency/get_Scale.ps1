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
	MajorDescending = $majorScale.Clone()
	Minor = $majorScale.Clone()
	MinorDescending = $majorScale.Clone()
	HarmonicMinor = $majorScale.Clone()
	HarmonicMinorDescending = $majorScale.Clone()
	MelodicMinor = $majorScale.Clone()
	PentatonicMajor = $majorScale.Clone()
	PentatonicMajorDescending = $majorScale.Clone()
	PentatonicMinor = $null #These are derived from MINOR scale which isn't built yet
	PentatonicMinorDescending = $null
	PentatonicBlues = $null
	PentatonicBluesDescending = $null
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

# Pentatonic scales mainly derive from the major/minor scale,
# but with certain scale degrees removed to make them 5 notes long (hence 'penta'tonic)
$scaleTable["PentatonicMajor"].RemoveAt(3)
$scaleTable["PentatonicMajor"].RemoveAt(5)
$scaleTable["PentatonicMajorDescending"] = $scaleTable["PentatonicMajor"].Clone()
$scaleTable["PentatonicMajorDescending"].Reverse()

$scaleTable["PentatonicMinor"] = $scaleTable["Minor"].Clone()
$scaleTable["PentatonicMinor"].RemoveAt(1)
$scaleTable["PentatonicMinor"].RemoveAt(4)
$scaleTable["PentatonicMinorDescending"] = $scaleTable["PentatonicMinor"].Clone()
$scaleTable["PentatonicMinorDescending"].Reverse()

# Blues pentatonic scale takes the minor pentatonic, adds augmented 4th
$scaleTable["PentatonicBlues"] = $scaleTable["PentatonicMinor"].Clone()
$aug4th = $scaleTable["PentatonicBlues"][2].Sharpen(1)
$scaleTable["PentatonicBlues"].Insert(3,$aug4th)
$scaleTable["PentatonicBluesDescending"] = $scaleTable["PentatonicBlues"].Clone()
$scaleTable["PentatonicBluesDescending"].Reverse()

$this | Add-Member NoteProperty '#Scale' $scaleTable -Force
return $scaleTable
