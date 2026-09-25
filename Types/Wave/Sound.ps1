<#
.SYNOPSIS
    Wave Sounds
.DESCRIPTION
    Plays the notes in the current Melody, using any number of Instruments.
#>
param()

# Replace angle brackets and periods,
# and split on whitespace to get a sequence of instruments
$Instruments = @(
    foreach ($arg in $args) {
        $arg -replace '[\.<>]' -split '\s+'         
    }
)

# If we could not detect instruments
if (-not $Instruments) {
    $Instruments = @(if ($this.Instrument) {
        $this.Instrument
    } else {
        'sine'
    })
}

# If we have no melody
if (-not $this.Melody) { 
    # warn and return
    Write-Warning "No Melody Defined"
    return
}

# Prepare a progress bar
$progress = @{
    id = Get-Random
    status = 'Generating'
}

# And prepare to generate events.
# (We may as well log what happens, as it gives us history and readable note sequences)
$events = [Runspace]::DefaultRunspace.Events

# Start at the first instrument.
$InstrumentIndex = 0 

$waveSplat = $this.WaveFormat

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

filter waveID {
    $note = $_
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
}

$noteSequence = @(foreach ($note in $this.Melody) {
    $noteTable = [Ordered]@{}
    if ($note -is [Collections.IDictionary]) {
        $noteTable += $note
    } else {
        foreach ($prop in $note.psobject.properties) {
            if ($prop -isnot [psnoteproperty]) { continue }
            if (-not $prop.IsInstance) { continue }
            $noteTable[$prop.Name] = $note.($prop.Name)
        }
    }
    
    $noteTable
})

# We go over each note in the sequence,
[byte[]]$wavaData = @(for ($index = 0; $index -lt $NoteSequence.Length; $index++) {
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
    if ((-not $note.Frequency) -or ($note.Name -eq 'REST')) {
        # the instrument is `Silence`.
        $Instrument = 'Silence'
    }

    # We want to be able to make multiple sounds at once.
    # Our combined wave is the sum of all of the samples.
    # Start by split our instruments by commas.
    $AllSamples = @(foreach ($instrument in $Instrument -split ',') {
        if (-not $this.$Instrument.Script) {
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

        # Get the list of frequencies played.
        $frequencyList = @(
            # This is the frequency list, split by commas
            foreach ($frequency in 
                $note.Frequency -split ',' -replace 
                    'hz', ',' -split ',' -as [double[]]
            ) {
                <#
                
                A frequency can be played on any number of "strings"

                We can think of each vibration within a sound as a literal string, 
                vibrating at a frequency.  
                
                That's what a lot of "real" music actually is.

                Each string is a harmonic vibration.

                Strings can be present on the note or on this wave.

                If strings is a positive number, each string will vibrate at half the frequency.

                If strings is a negative number, each string will vibrate at twice the frequency.

                If strings can be a list of `[double[]]`, 
                each frequency will be generated at that ratio.

                #>
                
                $strings = 
                    # strings can be defined on our notes
                    if ($note.Strings) {
                        $note.Strings
                    } 
                    # Or on this object
                    elseif($this.Strings)
                    {    
                        $this.Strings
                    }

                # If no strings are defined,
                if (-not $strings) { 
                    # we are simply playing this frequency
                    $frequency
                    continue
                }

                # If the strings is an integer, it's a multiple 
                if ($strings -is [int]) {
                    # If the number of strings is positive
                    if ($strings -ge 1) {
                        # we are generating that number of frequencies
                        foreach ($noteString in 1..$note.Strings) {
                            # Each string is half of the previous
                            # so we will divide by powers of two
                            $frequency / [Math]::Pow(2, ($noteString - 1))
                        }
                    }
                    # If the number of strings is negative 
                    elseif ($strings -le 1) {
                        # we are generating the absolute value of that number of frequencies
                        # Each frequency is double the previous                        
                        foreach ($noteString in 1..([Math]::Abs($note.Strings))) {
                            # So we will multiply by powers of two.
                            $frequency * [Math]::Pow(2, ($noteString - 1))
                        }
                    }
                    else {
                        # If the number of strings is zero,
                        # we obviously must be generating silence.
                        0
                    }
                }
                elseif (
                    # If the strings is a series of doubles
                    $strings -as [double[]]
                ) {
                    # emit the original frequency
                    $frequency                    
                    foreach ($noteString in ($strings -as [double[]])) {
                        # and the frequency at each of those ratios.
                        $frequency * $noteString
                    }
                }
            }
        )
        # We want to be able to play multiple frequencies, too.
        # So split our note frequency by commas
        foreach ($frequency in $frequencyList) {
            $note = [Ordered]@{} + $noteSequence[$index]
            $note.Frequency = $Frequency

            # If we are shifting octaves
            if ($note.ShiftOctave) {
                if ($note.ShiftOctave -gt 0) {
                    for ($shiftNumber = 1; $shiftNumber -le $note.ShiftOctave; $shiftNumber++) {
                        $note.Frequency *= 2
                    }            
                }
                elseif ($note.ShiftOctave -lt 0) {
                    for ($shiftNumber = -1; $shiftNumber -ge $note.ShiftOctave; $shiftNumber--) {
                        $note.Frequency /= 2
                    }
                }
            }

            # Collect our instrument parameters
            $instrumentParameters = [Ordered]@{}
            
            # As we map our instrument parameters, let us also construct a cache key.
            # If the same instrument and parameters are requested,
            # we can reliably avoid making the same note twice.
            
            # We might as well keep this key in a html friendly format.
            # (we might want this information later)
            $cacheKey = @($note | waveID) -join ' '

            $noteData = [Ordered]@{PSTypeName='Note'} + $noteSequence[$index] + @{
                # played with the current instrument
                Instrument = $Instrument
                Id = $cacheKey 
            }
                
            # Generate an event representing a note.
            # Even if we have already cached the note, 
            # we still want to log that we want to play it.
            $null = $events.GenerateEvent(
                'Note', $this, @($friendly), [PSCustomObject]$noteData
            )
            
            if (-not $WaveCache[$cacheKey]) {
                # Call our instrument script.  
                # This should output be a `[byte[]]` stream of PCM data
                # Or a `[double[]]` stream of samples.
                $samples = . $this.$instrument.Script @instrumentParameters
                if ($samples.Length) {
                    if ($samples[0] -is [byte]) {
                        $WaveCache[$cacheKey] = (wave @waveSplat -PCM $samples) 
                    }
                    elseif ($samples[0] -is [double]) {
                        $WaveCache[$cacheKey] = (wave @waveSplat -Samples $samples)
                    }
                }
            }

            ,$WaveCache[$cacheKey].Samples
        }
    })
    
    if (-not $AllSamples.Length) { continue }

    $note = [Ordered]@{} + $noteSequence[$index]

    $cacheKey = @($note | waveID) -join ' '

    if (-not $WaveCache[$cacheKey]) {
        [double[]]$sumSamples = (
            @(0) * $AllSamples[0].Length
        )

        foreach ($samples in $AllSamples) {
            $sampleNumber = 0
            foreach ($sample in $samples) {
                $sumSamples[$sampleNumber] += $sample
                $sampleNumber++
            }
        }        
        $WaveCache[$cacheKey] = wave @waveSplat -Samples $sumSamples
    }
    
    $WaveCache[$cacheKey].Data
})

# Last but not least: complete our progress bars
$progress.Remove('PercentComplete')
$progress.Completed = $true
Write-Progress @progress

$newWave = wave @waveSplat -PCM $wavaData
$newWave.Melody = $this.Melody
$NewWave.Instrument = $Instruments
return $newWave