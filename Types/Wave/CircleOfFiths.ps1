<#
.SYNOPSIS
    Cirlce of Fifths Wave Generator
.DESCRIPTION
    Generates waves using the Circle of Fifths
.LINK
    https://en.wikipedia.org/wiki/Circle_of_fifths
.NOTES
#>
param(
# The starting point along the circle of fifths
$Start = 0,

# The note count (by default, 13)
[int]
$NoteCount =  13,

# Play in octave 3 by default
[int]
$Octave = 3,

# The note timing
[Alias('bpm')]
[timespan]
$Duration = ([TimeSpan]::FromSeconds(60/128))
)

$noteSequence = 'C','G','D','A','E','B','F#', 'C#','A','E','B'

$currentWave = $this
if (-not $currentWave) {
    $currentWave = wave
}

if ($start -is [int]) {
    $startIndex = $start
}

if ($start -is [string]) {
    for ($startIndex = 0; $startIndex -lt $noteSequence.Length; $startIndex++) {
        if ($start -eq $noteSequence[$startIndex]) {
            break        
        }
    }
}
$noteFrequency = $currentWave.NoteFrequency
[Collections.IDictionary[]]$tune = 
    for ($index = $startIndex; $index -lt ($startIndex + $NoteCount); $index++) {
        
        $noteIndex =  $index % $noteSequence.Length
        
        $letterNote = $noteSequence[$noteIndex] -replace 
            '(?<=\p{L})', $Octave -replace 
            '(?<d>\d)\#', '#${d}'
        
        [Ordered]@{
            Name = 'LetterNote'
            Letter = $letterNote
            Octave = $Octave
            Frequency = $noteFrequency[$letterNote -replace '#', '♯']
            Duration = $Duration
        }
    }
    
$currentWave.Melody += $tune
return $currentWave.Sound()
