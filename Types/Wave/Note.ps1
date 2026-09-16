<#
.SYNOPSIS
    Note Generator
.DESCRIPTION
    Generates a sequence of notes.    
.NOTES
    
.EXAMPLE
    wave note cafe
.EXAMPLE
    wave note d e c c3 g3
.EXAMPLE
    $Korobeiniki = wav @(
        'note'
        ('
            e5 ++ b4 c5 -- d5 ++ c5 b4 --
            a4 ++ a4 c5 -- e5 ++ d5 c5 --
            b4 ++ ~ c5 -- d5 e5 c5 a4 a4 ~
            ++ ~ d5 ~ f5 -- a5 ++ g5 f5 --
            e5 ++ ~ c5 -- e5 ++ d5 c5 --
            b4 ++ b4 c5 -- d5 e5 c5 a4 a4 ~
        ' * 4)
        '<sine> <square> <triangle> <saw>'    
    )
    $Korobeiniki.Play()

.EXAMPLE
    $Korobeiniki = wav @(
        'note'
        ('
            𝅝 e5 𝅗𝅥 b4 c5 𝅝 d5 𝅗𝅥 c5 b4
            𝅝 a4 𝅗𝅥 a4 c5 𝅝 e5 𝅗𝅥 d5 c5
            𝅝 b4 𝅗𝅥 ~  c5 𝅝 d5 e5 c5 a4 a4 ~
            𝅗𝅥 ~ d5 ~ f5 𝅝 a5 𝅗𝅥 g5 f5 
            𝅝 e5 𝅗𝅥 ~ c5 𝅝 e5 𝅗𝅥 d5 c5 
            𝅝 b4 𝅗𝅥 b4 c5 𝅝 d5 e5 c5 a4 a4 ~
        ' * 4)
        '<sine> <square> <triangle> <saw>'    
    )
    $Korobeiniki.Play()
.EXAMPLE
    $tune = 'c'
    wave note "𝅝 $tune 𝅗𝅥 $($tune) 𝅘𝅥 $($tune * 2) 𝅘𝅥𝅮 $($tune * 4) 𝅘𝅥𝅯 $($tune * 8) 𝅘𝅥𝅰 $($tune * 16)"  play
.EXAMPLE
    $tune = 'cafe'
    wave note "𝅝 $tune 𝅗𝅥 $tune 𝅘𝅥 $tune 𝅘𝅥𝅮 $tune 𝅘𝅥𝅯 $tune 𝅘𝅥𝅰 $tune 𝅘𝅥𝅲 $tune 𝅘𝅥𝅲 $tune"  play
#>
param(
# The note sequence.
[string]
$Sequence,

# The instrument or instruments used to play.
# Multiple instruments may be specified.
# Using multiple instruments will switch between each instruments
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

$notemoji = "𝅝","𝅗𝅥","𝅘𝅥","𝅘𝅥𝅮","𝅘𝅥𝅯","𝅘𝅥𝅰","𝅘𝅥𝅲","𝅘𝅥𝅲"

# Note: this technically matches any emoji.
# We _could_ extend this with more emoji in the future.
$notemojiPattern = "[\p{IsHighSurrogates}\p{IsLowSurrogates}\p{IsVariationSelectors}\p{IsCombiningHalfMarks}]+"    

$notePattern = "(?>$(
    @(  
        # Midi must come before note, otherwise `d` will match a note
        '(?<midi>m(?:idi)?\s{0,}[\d\.]+)'  
        # Rest/silence/~ comes next, for almost the same reason.
        '(?<rest>~|rest|silence)'
        # friendly note format
        '(?<note>[a-g]\#?[1-8]?)'
        # A specific frequency
        '(?<frequency>[\d\.]+)'
        # Two pluses represent a shift uptempo.
        # This will increase the note divisor
        '(?<upTempo>\+\+)'
        # Two minus represent a shift downtempt
        # This will decrease the note divisor
        '(?<downTempo>--)'
        "(?<notemoji>$notemojiPattern)"
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

# Set our base time from our duration
$BaseTime = [TimeSpan]::FromSeconds($Duration.TotalSeconds)
# and start the divisor at one.
$divisor = 1

$NoteSequence = @(
    # Walk over our array of notes
    for ($index = 0; $index -lt $noteMatches.Length; $index++) {
        # If the divisor was positive
        if ($divisor -gt 1) {
            # our tempo at the moment is the base time divided by our divisor
            $Tempo = [TimeSpan]::FromSeconds($BaseTime.TotalSeconds / $divisor)
        } 
        elseif ($divisor -le -2) {
            $tempo = [TimeSpan]::FromSeconds($BaseTime.TotalSeconds * ([Math]::Abs($divisor)))
        }
        else {
            # otherwise it is the base time.
            $Tempo = [TimeSpan]::FromSeconds($BaseTime.TotalSeconds)
        }

        # Get our match
        $match = $noteMatches[$index]        

        # If our match was a midi note
        if ($match.Groups['midi'].Success) {
            # replace any letters and whitespace and cast to a double
            $midiNote = $match -replace '[\p{L}\s]' -as [double]
            # then convert it to a frequency.
            $frequency = 440.0 * [Math]::Pow(
                2, (($MidiNote - 69)/12)
            )
            # Then output the note
            [Ordered]@{
                Name = "$match"; Frequency = $frequency
                Duration = $Tempo; Volume = $volume
            }
        }
        # If our match was a friendly note
        elseif ($match.Groups['note'].Success) {
            # get it's name
            $friendly = "$match"
            # if it did not have a digit
            if ($friendly -notmatch '[a-g]\#?\d$') {
                # add one
                $friendly += 4
            }
            # Output our note
            [Ordered]@{
                Name = $friendly; Frequency = $noteFrequency[$friendly]
                Duration = $Tempo; Volume = $volume
            }   
        }
        elseif ($match.Groups['frequency'].Success) {
            # If we were provided a specific frequency
            # that is our note.
            [Ordered]@{
                Name = "${match}hz"; Frequency = "$match" -as [float]
                Duration = $Tempo; Volume = $volume
            }
        }
        elseif ($match.Groups['rest'].Success) {
            # If we were provided a rest, our note is no note.
            [Ordered]@{
                Name = "Rest"; Frequency = 0
                Duration = $Tempo; Volume = $volume
            }
        }
        elseif ($match.Groups['upTempo'].Success) {
            # If we are going uptempo, increase the divisor
            $divisor++            
            if ($divisor -eq -1) {
                $divisor = 1
            }
        }
        elseif ($match.Groups['downTempo'].Success) {
            # If we are going downtemp, decrease the divisor
            $divisor--
            if ($divisor -eq 0) {
                $divisor = -2
            }
        }
        elseif ($match.Groups['notemoji'].Success) {
            $notemojiIndex = $notemoji.IndexOf("$match")
            if ($notemojiIndex -ge 0) {
                $divisor = $notemojiIndex + 1
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
$Instruments = @($Instrument -replace '[\p{P}<>]') -split '\s+'
# Start at the first instrument.
$InstrumentIndex = 0 

# Update our progress info
$progress.status = 'Generating'

# We never need to make the same wave twice,
# so we want a runspace-wide cache of our waves.
# This makes it _much_ faster to generate most notes
$waveTable = Get-TypeData -TypeName WaveTable -ErrorAction Ignore

# If the cache is uninitialized
if (-not $waveTable.Members.WaveCache) {
    # Create it
    Update-TypeData -TypeName WaveTable -MemberName "WaveCache" -MemberType NoteProperty -Value (
        [Ordered]@{}
    ) -Force
}

# Create a Wave Table prototype
$waveTable = [PSCustomObject]@{PSTypeName='WaveTable'}
# and get the static cache.
$waveCache = $waveTable.WaveCache

# Now Let's make some make waves!

# We go over each note in the sequence,
for ($index = 0; $index -lt $NoteSequence.Length; $index++) {
    $note = $NoteSequence[$index]
    $friendly = $note.Name    
    # and writing progress as we go.
    $progress.PercentComplete = $index * 100 / $NoteSequence.Length
    $progress.Activity = "$($note.Name)@$($note.Duration) $index / $($NoteSequence.Length)"
    Write-Progress @progress    

    # Get the instrument used for this sample.
    if ($Instruments.Length) {
        $Instrument = $Instruments[$InstrumentIndex % $Instruments.Length]
        $InstrumentIndex++
    }
    
    # If the note name is rest or the frequency is zero
    if (-not $note.Frequency -or $Name -eq 'REST') { 
        # the instrument is `Silence`.
        $Instrument = 'Silence'        
    }

    if (-not $this.Instrument.Script) {
        throw "Invalid Instrument $Instrument (must be a script method)"
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

    if (-not $instrumentParameterNames.Count) {
        throw "No Instrument Parameters for $instrument"
    }

    # Collect our instrument parameters
    $instrumentParameters = [Ordered]@{}
    
    # As we map our instrument parameters, let us also construct a cache key.
    # If the same instrument and parameters are requested,
    # we can reliably avoid making the same note twice.
    
    # We might as well keep this key in a html friendly format.
    # (we might want this information later)
    $cacheKey = @(
        "data-audio-format='$($this.AudioFormat)'"
        "data-channel-count='$($this.ChannelCount)'"
        "data-sample-rate='$($this.SampleRate)'"
        "data-bits-per-sample='$($this.BitsPerSample)'"
        "data-instrument='$($Instrument -replace "'", "''")'"
        foreach ($key in $note.Keys) {
            "data-$key='$($note[$key] -replace "'","''")'"
            # that is a parameter for that instrument
            if ($instrumentParameterNames -contains $key) {
                # becomes an instrument parameter.
                $instrumentParameters[$key] = $note[$key]
            }
        }
    ) -join ' '
        
    # Generate an event representing a note.
    # Even if we have already cached the note, 
    # we still want to log that we want to play it.
    $null = $events.GenerateEvent(
        'Note', $this, @($friendly), (
            [Ordered]@{} + $note + @{
                # played with the current instrument
                Instrument = $Instrument
                Id = $cacheKey 
            }
        )
    )
    
    if (-not $WaveCache[$cacheKey]) {
        # And call our instrument script.  This should output a stream of bytes.
        $WaveCache[$cacheKey] = [byte[]](. $this.$instrument.Script @instrumentParameters)
    }

    $WaveCache[$cacheKey]    
    # . $this.$instrument.Script @instrumentParameters
}    

# Last but not least, complete our progress bars.
$progress.Remove('PercentComplete')
$progress.Completed = $true
Write-Progress @progress