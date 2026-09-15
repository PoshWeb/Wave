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
# The note sequence
[string]
$Sequence,

# The instrument or instruments used to play
[string]
$Instrument = 'Tone',

# The amount of time to generate per note.
[Timespan]$Duration = $(
    if ($this.BPM -is [TimeSpan]) {$this.BPM} 
    else { [TimeSpan]::FromSeconds(60/128) }   
),

[float]$Volume = $(
    if ($this.Volume) { $this.Volume}
    else { 0.5 }
)
)

<#

We will approach this in three phases:

* Phase 1: Convert note syntax to notes
* Phase 2: Convert Notes to Waveforms
* Phase 3: Profit

#>

$notePattern = "(?>$(
    @(  
        '(?<midi>m(?:idi)?\s{0,}[\d\.]+)'  
        '(?<note>[a-g]\#?[1-8]?)'        
        '(?<frequency>[\d\.]+)'
        '(?<rest>~)'
    ) -join '|'
))"

# Matching DECPS is easy:
# look for escape + open bracket, yada yada yada, `,~`
$noteMatches = @([Regex]::Matches($Sequence, $notePattern))

# Get our note frequency table
$noteFrequency = $this.NoteFrequency

# Prepare a progress bar
$progress = @{
    id = Get-Random
    status = 'Converting'
}

# And prepare to generate events.
# (We may as well log what happens, as it gives us history and readable note sequences)
$events = [Runspace]::DefaultRunspace.Events

$NoteSequence = @(
    # Walk over our array of DECPS notes
    for ($index = 0; $index -lt $noteMatches.Length; $index++) {        
        $match = $noteMatches[$index]
        if ($match.Groups['midi'].Success) {
            $midiNote = $match -replace '\p{L}' -as [double]
            $frequency = $this.MidiNoteToFrequency($midiNote)
            [Ordered]@{
                Name = "$match"; Frequency = $frequency
                Duration = $Duration; Volume = $volume
            }
        }
        elseif ($match.Groups['note'].Success) {
            $friendly = "$match"
            if ($friendly -notmatch '\d$') {
                $friendly += 4
            }
            [Ordered]@{
                Name = $friendly; Frequency = $noteFrequency[$friendly]
                Duration = $Duration; Volume = $volume
            }   
        }
        elseif ($match.Groups['frequency'].Success) {
            [Ordered]@{
                Name = "${match}hz"; Frequency = "$match" -as [float]
                Duration = $Duration; Volume = $volume
            }
        }
        elseif ($match.Groups['rest'].Success) {
            [Ordered]@{
                Name = "Rest"; Frequency = 0
                Duration = $Duration; Volume = $volume
            }
        }
    
        # writing progress as we go
        # (though it will probably be too quick to see)
        $progress.PercentComplete = $index * 100 / $noteMatches.Length
        $progress.Activity = "$index / $($noteMatches.Length)"
        Write-Progress @progress
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


# Next up: Instruments!
# We can think of any Script Method on this object as an instrument
# (though not all of them will make pleasing sounds)

# Replace angle brackets 
# and split on whitespace to get a sequence of instruments
$Instruments = @($Instrument -replace '[<>]') -split '\s+'
# Start at the first instrument.
$InstrumentIndex = 0 

# Update our progress info
$progress.status = 'Generating'

# And make waves!

# We go over each note in the sequence,
for ($index = 0; $index -lt $NoteSequence.Length; $index++) {
    $note = $NoteSequence[$index]
    $friendly = $note.Name    
    # and writing progress as we go.
    $progress.PercentComplete = $index * 100 / $NoteSequence.Length
    $progress.Activity = "$($note.Name)@$($note.Duration) $index / $($NoteSequence.Length)"
    Write-Progress @progress    


    if ($note.Name -eq 'Rest') {

    }
    

    # Get the instrument used for this sample.
    if ($Instruments.Length) {
        $Instrument = $Instruments[$InstrumentIndex % $Instruments.Length]
        $InstrumentIndex++
    }
    
    if (-not $note.Frequency -or $Name -eq 'REST') { 
        $Instrument = 'Silence'        
    }

    # Then find our instrument parameter names
    $instrumentParameterNames =
        # by walking over the parameters in the script's AST
        foreach ($param in $this.$Instrument.Script.Ast.ParamBlock.Parameters) { 
            "$($param.Name)" -replace '^\$'
            foreach ($attr in $param.Attributes) {
                if ($attr.TypeName.Name -eq 'alias') {
                    $attr.PositionalArguments.Value
                }
            }
        }

    # Collect our instrument parameters
    $instrumentParameters = [Ordered]@{}
    
    # Any information in our note
    foreach ($key in $note.Keys) {
        # that is a parameter for that instrument
        if ($instrumentParameterNames -contains $key) {
            # becomes an instrument parameter.
            $instrumentParameters[$key] = $note[$key]
        }
    }
        
    # Generate an event representing a note 
    $null = $events.GenerateEvent(
        'Note', $this, @($friendly), (
            [Ordered]@{} + $note + @{
                # played with the current instrument
                Instrument = $Instrument
            }
        )
    )

    # And call our instrument script.  This should output a stream of bytes.
    & $this.$instrument.Script @instrumentParameters
}    

# Last but not least, complete our progress bars.
$progress.Remove('PercentComplete')
$progress.Completed = $true
Write-Progress @progress