<#
.SYNOPSIS
    Note Generator
.DESCRIPTION
    Generates a sequence of notes by interpreting any arguments.

    This will ignore any input it cannot parse as notes
.NOTES
    This is the interpreter for a musical mini-language included in `Wave`

    This language is described in `.NoteGrammar`, 
    and can be matched using `.NotePattern`

    This language is still in development, 
    and is an attempt to hybridize existing musical notations.
    
    See https://xkcd.com/927/
.LINK
    https://xkcd.com/927/
#>
param()

$tune = @(
    foreach ($arg in $args) {
        $arg
    }
) -join ' '

# The current wave is `$this`
$currentWave = $this
# unless there is no current wave, 
# in which case it is an empty wave.
if (-not $currentWave) { $currentWave = wave }

# Collect our list of letter note frequencies  
$noteFrequency = $currentWave.NoteFrequency

# And get our grammar for parsing notes
$Grammar = $currentWave.NoteGrammar

# This method is effectively an interpreter of a small musical language.
# In order to maintain our sanity, 
# we want to use some formal language concepts.

# But let us start by finding all matches for our note pattern
$matchEnumerator = $currentWave.NotePattern.Matches($tune)

# From here on our we are making a finite state machine.
# This sounds more complicated than it might need to be.
# Each match we have found is effectively the state at that moment.

# Since we've gone to the trouble of making a grammar,
# there are only a finite number of states each token could possibly be in.
# When we interpret things, we only need to change the state 
# or add additional information to it so that we might have appropriate instructions.

# But before all that, we need to take each of our matches and populate the state.

# We want to keep track of the index, so initialize our match number
$matchNumber = 0 
# We will also want to track depth, so initiaalize that as well.
$depth = 0

# We will want to know when depth has changed,
# so keep track of opens and closes
$openDepth = @()
$closeDepth = @()


# Go over our matches and populate the state
$allMatches = @(foreach ($match in $matchEnumerator) {
    
    # Our state is just a dictionary of information
    $state = [Ordered]@{}
    
    # The first item in this dictionary is the name of the state
    # so we need to loop over all match groups
    $state.Name = foreach ($group in $match.Groups) {
        # and ignore groups that did not match.
        if (-not $group.Success) { continue }
        # If the group name is in the list of grammar keys
        if ($group.Name -in $grammar.Keys) {
            $group.Name # that is our state name
            break # and we can take a break and move onto the next part.
        }
    }

    # We want each state to know where it was in the sequence
    # so this is the second piece of information in the finite state.
    $state.MatchNumber = $matchNumber
    # We also want each state to know it's match context.
    # this is the third piece of information each state contains.
    $state.Match = $match

    # Every other piece of stateful information comes from the match groups
    foreach ($group in $match.Groups) {
        # If the group was a numbered group, we can ignore it
        if ($group.Name -as [int] -ge 0) { continue }
        # We can ignore any failed match groups
        if (-not $group.Success) { continue }
        # If the state was an `Open`
        if ($state.Name -match '^Open') {
            $depth++ # increase the depth
            $openDepth += $matchNumber # and track the open
        }
        # If the state was a `Close`
        elseif ($state.Name -match '^Close') {        
            $depth-- # decrement the depth
            $closeDepth += $matchNumber # and track our close.         
        }
        
        # Any named state will become all of the matching capture groups.
        $state[$group.Name] =
            foreach ($capture in $group.Captures) {
                $capture.Value
            }
    }

    $matchNumber++
            
    $match |
        Add-Member 'State' $state -Force -PassThru |
        Add-Member 'StateName' $stateName -Force -PassThru |
        Add-Member 'OpenDepth' $openDepth -Force -PassThru |
        Add-Member 'CloseDepth' $closeDepth -Force -PassThru |
        Add-Member 'Depth' $Depth -Force -PassThru
})


# Prepare our interpreter

# We want to start off with whole beats
$divisor = 1

# And we need to determine a base tempo to do so.
# If we have a BPM timespan
if ($this.BPM -is [TimeSpan]) {
    $BaseTempo = $this.BPM # this is our base temp
} else {
    # Otherwise, default to 128 bpm.    
    $BaseTempo = [TimeSpan]::FromSeconds(60/128)
}

# We will want to be able to scan back and forth through our tokens,
# and we want to avoid a recursive parser if we can.

# The simple magic of this approach is that 
# each item is processed before the next is enumerated

# So if we want to stop looking ahead, 
# we simply break out of a parent loop.

# Lookahead looks ahead

filter lookAhead {
    $index = $_
    # and outputs all of the states ahead of any provided point
    for ($lookahead = $index + 1; $lookahead -lt $allMatches.Count;$lookahead++) {
        $allMatches[$lookahead].State
    }
}

# Lookbehind looks back
filter lookBehind {
    $index = $_
    # and outputs all of the states behind any provided input
    for ($lookBehind = $index - 1; $lookBehind -ge 0;$lookBehind--) {
        $allMatches[$lookBehind].State
    }
}

# Almost any way we can write a note can have a timescale attached.
# so we define one more filter to apply timescaling

filter timescale {
    $matchNumber = $_
    # If the current state has no duration, there is nothing to scale
    if (-not $state.Duration -and -not $state.States) { return }
    
    foreach ($ahead in $matchNumber | lookAhead) {
        # We can `Multiply`, `Divide`, or use `AtTime` format to scale time
        # If the lookahead is not one of these,
        if ($ahead.Name -notin 'Multiply', 'Divide', 'AtTime') {
            break # break
        }
        # Each timescale operation has a `.Scale`
        $scale = $ahead.Scale -as [double] # which we can cast to a double
        switch ($ahead.Name) {
            AtTime {
                if ($state.Duration) {
                    # If the format was `@` time, 
                    # we multiply
                    $state.Duration *= $scale
                }
                else {
                    foreach ($nested in $state.States) {
                        if ($nested.Duration) {
                            $nested.Duration = $BaseTempo * $scale
                        }
                    }
                }
            }
            Multiply {
                if ($state.Duration) {
                    # If the format was `*` time
                    # multiply the duration by that scale
                    $state.Duration *= $scale
                }
                else {
                    foreach ($nested in $state.States) {
                        if ($nested.Duration) {
                            $nested.Duration *= $scale
                        }
                    }
                }

            }
            Divide {
                if ($state.Duration) {
                    # If the format was `/` time
                    # divide the duration by the scale.
                    $state.Duration /= $scale
                }
                else {
                    foreach ($nested in $state.States) {
                        if ($nested.Duration) {
                            $nested.Duration /= $scale
                        }
                    }
                }
            }
        }
    }
}

#region Interpreter

# Now that we've set everything up, we just need to interpret each instruction
for ($matchIndex = 0; $matchIndex -lt $allMatches.Count; $matchIndex++) {
    # get our match
    $match = $allMatches[$matchIndex]    
    # and it's state
    $state = $match.State
    # and the name of the state.
    $stateName = $state.Name

    # Determine our tempo at the moment.
    # If the divisor was positive
    if ($divisor -gt 1) {
        # our tempo at the moment is the base time divided by our divisor
        $Tempo = [TimeSpan]::FromSeconds($BaseTempo.TotalSeconds / $divisor)
    } 
    # If the divisor was negative
    elseif ($divisor -le -2) {
        # multiply our base tempo by our absolute divisor
        $tempo = [TimeSpan]::FromSeconds($BaseTempo.TotalSeconds * ([Math]::Abs($divisor)))
    }
    else {
        # otherwise it is the base time.
        $Tempo = [TimeSpan]::FromSeconds($BaseTempo.TotalSeconds)
    }

    # We can use a `switch` to handle most states
    switch -regex ($stateName) {
        # `Beep` state has a frequency and time
        Beep {
            # We will cast the frequency to a `[double]`
            $state.Frequency = $state.Frequency -as [double]
            # and make the duration a `[TimeSpan]`
            $state.Duration = [TimeSpan]::FromMilliseconds(
                $state.Duration
            )
            # and add our base tempo            
            $state.BaseTempo = $BaseTempo
        }
        Sleep {
            # Sleeps have a frequency of zero
            $state.Frequency = 0
            # and a duration of a `[TimeSpan]`
            $state.Duration = [TimeSpan]::FromMilliseconds(
                $state.Duration
            )
            # and include the base tempo for good measure
            $state.BaseTempo = $BaseTempo
        }
        DECPS {
            # DECPS has a method that can process it
            $decSequence = "$($state.Match.Value)"
            # so simply set our states to the output of that method            
            $state.States = $currentWave.DECPS($decSequence)
        }
        # Notemoji time signatures are captured into a state named Time1_N
        '^Time1_\d+$' {
            # so we merely need to change our divisor to this signature.
            $Divisor = $stateName -replace 'Time1_' -as [int]
        }
        # A simple rest will rest for the current tempo 
        '^Rest$' {
            # If we were provided a rest, our note is no note.
            $state.Name = "Rest"
            $state.Frequency = 0
            $state.Duration = $tempo
            $state.BaseTemp = $BaseTempo            
        }
        # Notemoji rests take a similar format to notemoji time.
        '^Rest1_\d+$' {
            $restTime = $stateName -replace 'Rest1_' -as [int]            
            $state.Name = "Rest"
            $state.Frequency = 0
            $state.Duration = $BaseTempo / $restTime
            $state.BaseTempo = $BaseTempo                        
        }
        MidiNote {
            # Midi notes have a midi number, which should be a double
            $midiNote = $state.midiNumber -as [double]
            $state.Name = "Midi$($midiNote)"

            # We can convert midi notes to frequencies with this formula:
            $state.Frequency = 440.0 * [Math]::Pow(
                2,
                (($MidiNote - 69)/12)
            )
            # we will play that note at the current tempo
            $state.Duration = $tempo
            $state.BaseTempo = $BaseTempo
            # and apply any nearby timescale
            $matchIndex | . timescale
        }
        LetterNote {
            <#
            
            Letter notes can be a bit annoying to process.

            We want to have as fluid syntax as possible,
            and we want to ignore anything that is not relevant to our syntax.

            Problem is: musical letters show up in words, a lot.

            The pattern for letter note avoids words that are not entirely letter notes.

            Code exists here to "check it twice", 
            because otherwise notes can be played in parts of normal words.
            #>
            
            $before = $match.Result('$`')
            
            <#
            
            If we have a letter that is not a-g,
            followed by any number of a-gs, we will not consider it a note.

            This way the word `thread` would 
            not play the notes `e`, `a`, and `d`.
            #>            

            if ($before -match '[\p{L}-[abcdefg]][abcdefg]{0,}$') {
                continue
            }            
            # We also want to check for the same thing afterwards,
            # which we can get with dollar + tic
            $after = $match.Result('$''')
            <#
            
            This way `Console`

            will not play a C note.

            #>
            if ($after -match '^[\p{L}-[abcdefg]][abcdefg]{0,}') {
                continue
            }

            # Note that this only goes so far.
            # If you passed in "tell me about a4" to note,
            # we will still play the note a4.
            
            # Get our friendly note
            $friendly = "$(
                $state.letter # The state will always have a letter
            )$(
                # If may have be sharp
                if ($state.Sharp) {
                    '♯' # in which case we should use the `♯` symbol.
                } 
                # it may be flat
                elseif ($state.Flat) {
                    '♭' # in which case we should use the `♭` symbol.
                }
            )$(
                # If we have an octave
                if (
                    $null -ne $state.octave -as [int]
                ) { 
                    # use it.
                    $state.octave 
                } else {
                    # If we do not, 
                    # this is one of those rare scenarios where case may matter

                    # ABC notation uses uppercase letters to represent an octave up.

                    # So if the letter is uppercase, play in 4 
                    if ($state.Letter -cmatch '\p{Lu}') {                        
                        4
                    } else {
                        # otherwise, play in 3 
                        3
                    }                    
                }
            )"

            # Our actual frequency is just a quick trip to a lookup table.
            $state.Frequency = $noteFrequency[$friendly]
            # and our duration is the current tempo.
            $state.Duration = $tempo
            $state.BaseTempo = $BaseTempo
            # apply any timescaling.
            $matchIndex | . timescale
        }
        UpTempo {
            # If we are going uptempo, increase the divisor
            $divisor++
            # If the divisor was negative one
            if ($divisor -eq -1) {
                $divisor = 1 # it becomes one.
            }
            # This lets us skip the awkward case where the divisor would be 0 or -1            
        }
        DownTempo {
            # If we are going downtempo, decrease the divisor
            $divisor--
            # If the divisor became zero
            if ($divisor -eq 0) {
                $divisor = -2 # make it negative two
            }

            # This lets us transition from normal time `1`
            # to half time `-2`
        }

        # When we open a divide, we increase our divisor
        # This will make the notes within the divide twice as fast
        OpenDivide {
            # However, we only do this if the existing depth is greater than one.
            if ($match.Depth -gt 1) {
                $divisor++
            }            
        }
        CloseDivide {
            # When we close a divide, we look ahead for modifiers
            foreach ($ahead in $matchIndex | lookAhead) {
                if ($ahead.StateName -notin 'Multiply', 'Divide', 'AtTime') {
                    break
                }
                # as we find each divisor, look back                
                foreach ($behind in $matchIndex | lookBehind) {
                    # and stop looking back whenever we encounter an open divide
                    if ($behind.Name -eq 'OpenDivide') {
                        break
                    }
                    # skip any items that do not have a duration
                    if ($behind.Duration -isnot [TimeSpan]) {
                        continue
                    }
                    
                    # Scale the duration
                    $scale = $ahead.Scale -as [double]
                    switch ($ahead.StateName) {
                        AtTime {
                            $behind.Duration *= $scale
                        }
                        Multiply {
                            $behind.Duration /= $scale
                        }
                        Divide {
                            $behind.Duration *= $scale
                        }
                    }
                }
            }            
            if ($match.Depth -gt 1) {
                $divisor--
            }            
        }
    }    
}
#endregion Interpreter

#region Output

# Now that we have all of our states, 
# all that is left to do is output the results of our interpreter
for ($matchIndex = 0; $matchIndex -lt $allMatches.Length; $matchIndex++) {
    $match = $allMatches[$matchIndex]
    # If the state had a frequency or duration
    if ($match.State.Frequency -or $match.State.Duration) {
        # it's part of our melody
        $match.State # and we should output it.
    }
    # Otherwise, if the match had nested states
    elseif ($match.State.States) 
    {
        # apply the same logic
        foreach ($nested in $match.State.States) {
            # and output any nested state with a frequency or duration.
            if ($nested.Frequency -or $nested.Duration) {
                $nested
            }
        }
    }
}
#endregion Output

return