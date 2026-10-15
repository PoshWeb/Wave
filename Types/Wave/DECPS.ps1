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
    "`e[2;2;1;2;3~" # Volume of 3, Fraction of 2, notes 1, 2, 3 (C5, C#5, D5)
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
    $tune = "`e[2;2;1;3;5,~`e[2;8;6;10;8;11,~`e[2;4;10;11;13;10,~`e[2;8;8;11,~`e[2;4;10;11;13;10;11;13;15;17,~`e[2;8;18;17;18,~"
    $wav = wav DECPS $tune
    $wav.Play()
.EXAMPLE
    $shortMarch = @(
        "`e[2;20;7;7;7,~"
        "`e[2;15;3,~"
        "`e[2;5;10,~"        
        "`e[2;20;7,~"
        "`e[2;15;3,~"
        "`e[2;5;10,~"
        "`e[2;40;7,~"
    ) -join [Environment]::Newline
    wave DECPS $shortMarch play
.EXAMPLE
    $closeWave = @(
        "`e[2;10;15;17;13;2;8,~"
    )
    wave DECPS "`e[2;12;15;17;13;2;8,~" play
.EXAMPLE
    $happyBirthday = @(
        "`e[2;10;8,~"
        "`e[2;5;8,~"
        "`e[2;15;10;8;13,~"
        "`e[2;30;12,~"
        "`e[2;10;8,~"
        "`e[2;5;8,~"
        "`e[2;15;10;8;15,~"
        "`e[2;30;13,~"
        "`e[2;10;8,~"
        "`e[2;5;8,~"
        "`e[2;15;20;17;13;12,~"
        "`e[2;30;10,~"
        "`e[2;10;18,~"
        "`e[2;5;18,~"
        "`e[2;15;17;13;15,~"
        "`e[2;30;13,~"
    )
    wave DECPS $happyBirthday play
.EXAMPLE
    $escape = [char]27
    $march = @(
        "$escape[2;20;7;7;7,~",
        "$escape[2;15;3,~",
        "$escape[2;5;10,~",        
        "$escape[2;20;7,~",
        "$escape[2;15;3,~",
        "$escape[2;5;10,~",
        "$escape[2;40;7,~",
        "$escape[2;20;14;14;14,~",
        "$escape[2;15;15,~",
        "$escape[2;5;10,~",
        "$escape[2;20;6,~",
        "$escape[2;15;3,~",
        "$escape[2;5;10,~",
        "$escape[2;40;7,~",
        "$escape[2;20;19;7;19,~",
        "$escape[2;10;18;17,~",
        "$escape[2;5;16;15,~",
        "$escape[2;10;16;0;8,~",
        "$escape[2;20;13,~",
        "$escape[2;10;12;11,~",
        "$escape[2;5;10;9,~",
        "$escape[2;10;10;0;3,~",
        "$escape[2;20;6,~",
        "$escape[2;15;3,~",
        "$escape[2;5;10,~",
        "$escape[2;20;7,~",
        "$escape[2;15;3,~",
        "$escape[2;5;10,~",
        "$escape[2;40;7,~"
    ) -join [Environment]::Newline    
    $wav = wave decps $march
    $wav.play()
.EXAMPLE
    $escape = [char]27
    $InTheHallOfTheMountainKing = "
        $escape[2;8;1;3;4;6;8;4,~
        $escape[2;16;8,~
        $escape[2;8;7;3,~
        $escape[2;16;7,~
        $escape[2;8;6;2,~
        $escape[2;16;6,~
        $escape[2;8;1;3;4;6;8;4;8;13;11;8;4;8,~
        $escape[2;32;11,~
        $escape[2;8;8;10;12;13;15;12,~
        $escape[2;16;15,~
        $escape[2;8;16;12,~
        $escape[2;16;16,~
        $escape[2;8;15;12,~
        $escape[2;16;15,~
        $escape[2;8;8;10;12;13;15;12,~
        $escape[2;16;15,~
        $escape[2;8;16;12,~
        $escape[2;16;16,~
        $escape[2;32;15,~
        $escape[2;8;13;15;16;18;20;16,~
        $escape[2;16;20,~
        $escape[2;8;19;15,~
        $escape[2;16;19,~
        $escape[2;8;18;14,~
        $escape[2;16;18,~
        $escape[2;8;13;15;16;18;20;16;20;25;23;20;16;20,~
        $escape[2;32;23,~
    "

    🌊 decps $InTheHallOfTheMountainKing
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

# `$this` is the current wave
$currentWave = $this
# unless there is no `$this, in which case it is an empty wave.
if (-not $currentWave) { $currentWave = wave }

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
$noteFrequency = $currentWave.NoteFrequency

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
            $friendly = $friendly -replace '#', '♯'
            # and make it into a dictionary
            [Ordered]@{
                Name = $friendly; Frequency = $noteFrequency[$friendly]
                Duration = $noteDuration; Volume = $volume; ShiftOctave = $ShiftOctave
                BaseTemp = $Duration
            }
        }
    }
)


# Generate a `Tune` event.
# This contains the note sequence 
# before any instruments are applied and any tones are generated
$null = $events.GenerateEvent(
    'Tune', $currentWave, $NoteSequence, (
        [Ordered]@{} + $PSBoundParameters
    )
)

# Last but not least, complete our progress bars,
$progress.Remove('PercentComplete')
$progress.Completed = $true
Write-Progress @progress

$currentWave.Melody += $NoteSequence
return $currentWave.Sound()
