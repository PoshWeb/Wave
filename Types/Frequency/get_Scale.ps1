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

#Start with constructing the major scale
foreach ($step in ("WWHWWWH".ToCharArray())) { #Standard major scale step pattern
	$stepCount = if ($step -eq "W") { 2 } else { 1 }
	$null = $majorScale.Add($majorScale[-1].Sharpen($stepCount))
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
	# Remaining scales are NOT derived from major scale
	PentatonicMinor = $null
	PentatonicMinorDescending = $null
	PentatonicBlues = $null
	PentatonicBluesDescending = $null
	WholeTone = [Collections.ArrayList]::new()
	WholeToneDescending = $null
	Octatonic = [Collections.ArrayList]::new()
	OctatonicDescending = $null
	Augmented = [Collections.ArrayList]::new()
	AugmentedDescending = $null
}

#region Diatonic Scales
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
#endregion Diatonic Scales

#region Pentatonic Scales
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
#endregion Pentatonic Scales

#region Symmetric Scales
$null = $scaleTable["WholeTone"].Add($this)
$null = $scaleTable["Octatonic"].Add($this)
$null = $scaleTable["Augmented"].Add($this)

# Whole Tone scale is all whole steps up
1..6 | ForEach-Object {
	$null = $scaleTable["WholeTone"].Add($scaleTable["WholeTone"][-1].Sharpen(2))
}
$scaleTable["WholeToneDescending"] = $scaleTable["WholeTone"].Clone()
$scaleTable["WholeToneDescending"].Reverse()

# Octatonic scale alternates b/w whole steps and half steps
1..8 | ForEach-Object {
	$stepCount = if ($_ % 2 -eq 0) { 1 } else { 2 }
	$null = $scaleTable["Octatonic"].Add($scaleTable["Octatonic"][-1].Sharpen($stepCount))
}
$scaleTable["OctatonicDescending"] = $scaleTable["Octatonic"].Clone()
$scaleTable["OctatonicDescending"].Reverse()

# Augmented scale alternates b/w minor 3rds and half steps
1..6 | ForEach-Object {
	$stepCount = if ($_ % 2 -eq 0) { 1 } else { 3 }
	$null = $scaleTable["Augmented"].Add($scaleTable["Augmented"][-1].Sharpen($stepCount))
}
$scaleTable["AugmentedDescending"] = $scaleTable["Augmented"].Clone()
$scaleTable["AugmentedDescending"].Reverse()
#endregion Symmetric Scales

# Because our descending scales are just the reverse of the originals right now,
# they start at the top note of each scale.
# Need to drop all descending scales down an octave to start on current note
foreach ($scale in $scaleTable.Keys) {
	if ($scale -match "Descending$") {
		foreach ($i in (1..$scaleTable[$scale].Count)) {
			$scaleTable[$scale][($i - 1)] = $scaleTable[$scale][($i - 1)].Flatten(12)
		}
	}
}

$this | Add-Member NoteProperty '#Scale' $scaleTable -Force
return $scaleTable
