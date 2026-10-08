<#
.SYNOPSIS
    Converts Letter Notes to Midi notes
.DESCRIPTION
    Converts one or more letter notes into a series of corresponding midi notes.
.EXAMPLE
    wave LetterToMidi "c3", "c#3", 
        "d3", "d#3", 
        "e3", "f3", 
        "f#3", "g3", 
        "g#3", "a3", 
        "a#3","b3"
#>
param([string[]]$LetterNote)

$currentWave = $this
if (-not $currentWave) { $currentWave = wave}
$noteFrequency = $currentWave.NoteFrequency
$frequencies = foreach ($letter in $LetterNote) {
    if ($noteFrequency[$letter]) {
        $noteFrequency[$letter]
    }
    elseif ($noteFrequency[$letter -replace '#', '♯']) {
        $noteFrequency[$letter -replace '#', '♯']
    } 
    elseif ($noteFrequency[$letter -replace 'b(?<n>\d)', '♭${n}']) {
        $noteFrequency[$letter -replace 'b(?<n>\d)', '♭${n}']
    } 
    elseif (
        $letter -cmatch '^\p{Lu}$' -and 
        $noteFrequency["${letter}4"]
    ) {
        $noteFrequency["${letter}4"]
    } elseif (
        $letter -cmatch '^\p{Ll}$' -and 
        $noteFrequency["${letter}3"]
    ) {
        $noteFrequency["${letter}3"]
    } 
}

foreach ($frequency in $frequencies) {
    69 + 12 * [Math]::Log2($Frequency / 440)   
}


