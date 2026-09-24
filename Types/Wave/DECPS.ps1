<#
.SYNOPSIS
    DECPS Wave Generator
.DESCRIPTION
    DECPS is an ancient console audio format that encodes audio in escape sequences.

    Each contains:
    
    * An Escape Character (`[char]27`)
    * An open bracket
    * A volume (0-7)
    * A fraction (32nds of a second)
    * A series of notes in a two octave range (between C5 and C7), separated by `;`
    * A closing ~
    
    For example: 

    ~~~PowerShell
    "`e[3;2;1;2;3~" # Volume of 3, Fraction of 2, notes 1, 2, 3 (C5, C#5, D5)
    ~~~
    
    This converts DECPS notes into a wave form.
.NOTES
    DECPS is a format originally supported by the [DEC VT250](https://en.wikipedia.org/wiki/VT520).
    
    It is also supported in some moderns Terminal (Windows Terminal, Contour)

    Because DECPS dates from a time where computers could only play higher frequencies,
    this also shifts the octave when converting notes.
    
    By default, this shifts notes down by two octaves, into a more "normal" C3-C5 range.
.LINK
    https://web.mit.edu/dosathena/doc/www/ek-vt520-rm.pdf
.LINK
    https://tightloop.io/terminal-decps/   
.EXAMPLE    
    $tune = "`e[3;2;1;3;5,~`e[3;8;6;10;8;11,~`e[3;4;10;11;13;10,~`e[3;8;8;11,~`e[3;4;10;11;13;10;11;13;15;17,~`e[3;8;18;17;18,~"
    $wav = wav DECPS $tune
    $wav.Play()
.EXAMPLE
    $shortMarch = @(
        "`e[3;20;7;7;7,~"
        "`e[3;15;3,~"
        "`e[3;5;10,~"        
        "`e[3;20;7,~"
        "`e[3;15;3,~"
        "`e[3;5;10,~"
        "`e[3;40;7,~"
    ) -join [Environment]::Newline
    wave DECPS $shortMarch play
.EXAMPLE
    $closeWave = @(
        "`e[3;10;15;17;13;2;8,~"
    )
    wave DECPS "`e[3;12;15;17;13;2;8,~" play
.EXAMPLE
    $escape = [char]27
    $march = @(
        "$escape[3;20;7;7;7,~",
        "$escape[3;15;3,~",
        "$escape[3;5;10,~",        
        "$escape[3;20;7,~",
        "$escape[3;15;3,~",
        "$escape[3;5;10,~",
        "$escape[3;40;7,~",
        "$escape[3;20;14;14;14,~",
        "$escape[3;15;15,~",
        "$escape[3;5;10,~",
        "$escape[3;20;6,~",
        "$escape[3;15;3,~",
        "$escape[3;5;10,~",
        "$escape[3;40;7,~",
        "$escape[3;20;19;7;19,~",
        "$escape[3;10;18;17,~",
        "$escape[3;5;16;15,~",
        "$escape[3;10;16;0;8,~",
        "$escape[3;20;13,~",
        "$escape[3;10;12;11,~",
        "$escape[3;5;10;9,~",
        "$escape[3;10;10;0;3,~",
        "$escape[3;20;6,~",
        "$escape[3;15;3,~",
        "$escape[3;5;10,~",
        "$escape[3;20;7,~",
        "$escape[3;15;3,~",
        "$escape[3;5;10,~",
        "$escape[3;40;7,~"
    ) -join [Environment]::Newline
    
    $wav = wave $march
    $wav.play()
.EXAMPLE

#>
param(
# The DECPS note sequence
[string]
$Sequence,

# The number of octaves to shift.  By default -2.
[int]
$ShiftOctave = -1,

# The amount of time to generate per note.
[Timespan]$Duration = $(
    if ($this.BPM -is [TimeSpan]) {$this.BPM} 
    else { [TimeSpan]::FromSeconds(1) }   
)
)

<#

We will approach this in three phases:

* Phase 1: Convert DECPS escape sequences to notes
* Phase 2: Convert Notes to Waveforms
* Phase 3: Profit

#>

# Matching DECPS is easy:
# look for escape + open bracket, yada yada yada, `,~`
$decps = @([Regex]::Matches($Sequence, '\e\[.+?,~'))

# DECPS notes are integers.
# It's fast if we just find use the index as an offset.
$notelist = @(
    "~"
    "c5", "c♯5", "d5", "d♯5", "e5", "f5", "f♯5", "g5", "g♯5", "a5", "a♯5", "b5"
    "c6", "c♯6", "d6", "d♯6", "e6", "f6", "f♯6", "g6", "g♯6", "a6", "a♯6", "b6"
    "c7"
)

# Get our note frequency table
$noteFrequency = $this.NoteFrequency

# Prepare a progress bar
$progress = @{
    id = Get-Random
    status = 'Converting'
    activity = ' '
}

# And prepare to generate events.
# (We may as well log what happens, as it gives us history and readable note sequences)
$events = [Runspace]::DefaultRunspace.Events


$NoteSequence = @(
    # Walk over our array of DECPS notes
    for ($index = 0; $index -lt $decps.Length; $index++) {
        $match = $decps[$index]
        $notes = @()
    
        # writing progress as we go
        # (though it will probably be too quick to see)
        $progress.PercentComplete = $index * 100 / $decps.Length
        $progress.Activity = "$index / $($decps.Length)"
        Write-Progress @progress

        # A bit of multiple assignment lets us pick out the notes.
        $volume, $time, $notes = $match -replace '^\e\[' -replace ',~$' -split ';'

        # If we have no notes, continue
        if (-not $notes) { continue }

        # Volume is a value between 0-7.
        # Treat it as the fraction it is.
        $volume = ($volume -as [byte])/7

        # Each note is represented as a 32nd of a second
        $fraction = $time / 32
        # If we provided a duration, 
        # this will be used as the beat base instead.
        # (Duration defaults to 1 second, the DECPS timebase)
        $noteDuration = $Duration * $fraction

        # Turn our notes into friendly notes
        $friendlyNote = foreach ($note in $notes) {
            # First make each note an index
            $note = $note -as [int]
            # Then, if we have that index in our note list
            if ($note -and $notelist[$note]) {
                $notelist[$note] # that is our friendly note.
            }
        }

        # Walk over each friendly note
        foreach ($friendly in $friendlyNote) {
            $friendly = $friendly -replace '#', '♯' -creplace 'b', '♭'
            # and make it into a dictionary
            [Ordered]@{
                Name = $friendly; Frequency = $noteFrequency[$friendly]
                Duration = $noteDuration; Volume = $volume; ShiftOctave = $ShiftOctave
            }
        }
    }
)


# Generate a `Tune` event.
# This contains the note sequence 
# before any instruments are applied and any tones are generated
$null = $events.GenerateEvent(
    'Tune', $this, $NoteSequence, (
        [Ordered]@{} + $PSBoundParameters
    )
)

if ($this) {
    $this.Melody += @(
        foreach ($note in $NoteSequence) {
            $note.PSTypeName = 'Note'
            [PSCustomObject]$note
        }
    )
}

# Last but not least, complete our progress bars,
$progress.Remove('PercentComplete')
$progress.Completed = $true
Write-Progress @progress

# and return our sound with any instruments.
return $this.Sound()