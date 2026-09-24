<#
.SYNOPSIS
    Makes `.wav`es
.DESCRIPTION
    Makes a Wave stream.

    This lets us make music with PowerShell.
.NOTES
    ### What This Script Does

    This script return a Wave in a `[IO.Stream]`.

    If a `-Path` is provided, 
    it will read the file into a `[IO.MemoryStream]`, 
    and we will call it a `audio/wav`.
    
    If a `-Stream` is provided, we will call it an `audio/wav`.

    If neither is provided, will create a new waveform. 
.LINK
    https://en.wikipedia.org/wiki/WAV#WAV_file_header
.EXAMPLE
    # Creates an empty wave
    wave 
.EXAMPLE
    # Creates a wave tone at 440hz (A4)
    wave tone 440
.EXAMPLE
    # Creates a tone at 440 hz (A4),
    # then another tone at 220hz (A3)
    wave tone 440 tone 220
.EXAMPLE
    # Play a series of notes
#>
[Alias('wav', '.wav','〜','🌊')]
[CmdletBinding(PositionalBinding=$false)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidAssignmentToAutomaticVariable', '', Justification='$this does not always get properly assigned'
)]
param(

# The arguments to pass to Wave.
# This is a flexible syntax that lets you make music from the command line.

[ArgumentCompleter({
    param ($commandName, $parameterName, 
        $wordToComplete, $commandAst, $fakeBoundParameters )
    
    if (-not $script:WaveTypeData) {
        $script:WaveTypeData = Get-TypeData -TypeName audio/wav
    } 
    $memberNames = @($script:WaveTypeData.Members.Keys)
            
    if ($wordToComplete) {
        return $memberNames -like "$wordToComplete*"
    } else {
        return $memberNames
    }
})]
[Parameter(ValueFromRemainingArguments)]
[Alias('Arguments','Argument','Args','ArgV')]
[PSObject[]]
$ArgumentList,

# Any input object to process.
# If this is already a wave object, the arguments will be applied to this object.
# If the input object is not a wave object, it will be ignored and a new wave object will be created.
[Parameter(ValueFromPipeline)]
[Alias('Input')]
[PSObject]
$InputObject,

# The number of channels
[Alias('Channels','CC')]
[uint16]
$ChannelCount = 1,

# The bits per sample
[Alias('BPS')]
[uint16]
$BitsPerSample = 8,

# The sample rate, in hertz
[uint32]
[Alias('Rate','SR')]
$SampleRate = 44100,

# Audio format (2 bytes) (1: PCM integer, 3: IEEE 754 float)
[ValidateScript({
    if ($_ -notin 1,3) {
        throw "Audio Format must be 1 (PCM integer) or 3 (IEEE float)"
    }
    return $true
})]
[Alias('AF')]
[uint16]
$AudioFormat = 1,

# The number of bytes per block
[Alias('BPB')]
[uint16]
$BytesPerBlock,

# The bytes per second
[uint32]
$BytesPerSecond,

# The path to a wave file.
# If this is provided, 
# all bytes will be read into a memory stream (which will be treated as a wave).
[string]
$Path,

# An existing stream.
# If this is provided, it will try to treat it as a wave.
# (this will be harmless, but may result in very odd looking metadata)
[IO.Stream]
$Stream,

# A series of samples.
# These will be converted to PCM data
[Alias('Sample')]
[double[]]
$Samples,

# The sample data as a byte array.
[Alias('PulseControlModulation','Data')]
[byte[]]
$PCM,

# If set, will run as a background job.
# This will run using `Start-ThreadJob` if available,
# and `Start-Job` if not.
[switch]
$AsJob
)

# Collect any piped input
$allInput = @($input)

# If there was no piped input
if (-not $allInput.Length) {
    # collect any input provided directly to the parameter
    $allInput = $InputObject
}

# If we are running in a background job
if ($AsJob) {
    # create a copy of our parameters
    $IO = [Ordered]@{} + $PSBoundParameters
    # Remove our `AsJob` parameter so we do not infinitely recurse.
    $IO.Remove('AsJob')
    # Set our module path so we can load all of the surrounding conext.
    $IO.ModulePath = $MyInvocation.MyCommand.Module.Path -replace '\.psm1$', '.psd1'
    # And bind any input
    $IO.InputObject = $allInput
    # The Job definition is always the same:
    $JobDefinition = {
        # Accept a dictionary of parameters
        param([Collections.IDictionary]$Parameter)

        # If the parameter contains a module path
        if ($Parameter.Contains('ModulePath')) {
            if ($Parameter.ModulePath) {
                Import-Module $parameter.ModulePath
            }            
            $Parameter.Remove('ModulePath')
        }

        Wave @Parameter
    }
    if ($ExecutionContext.SessionState.InvokeCommand.GetCommand('Start-ThreadJob', 'Cmdlet')) {
        $waveJob = Start-ThreadJob -ScriptBlock $JobDefinition -ArgumentList $IO
    } else {
        $waveJob = Start-Job -ScriptBlock $JobDefinition -ArgumentList $IO
    }
            
    $waveJob.pstypenames.insert(0, 'Wave.Job')
    return $waveJob
}

# If we have any input,
if ($allInput.Length) {
    # This will attempt to be a bit clever, 
    # but hopefully not too much.

    # Walk over each input
    foreach ($in in $allInput) {
        # if it is a wave
        if ($in.pstypenames -contains 'audio/wav') {
            # Set `$this` to be the wave.
            $this = $in
            # Then call `Go` with splatting
            # (so arguments bind properly and do not get unrolled).            
            . $in.Go.Script @ArgumentList
            continue
        }        
        
        if ($in -is [IO.FileInfo] -and 
            $in.Extension -eq '.wav'
        ) {
            # Create a new memory stream,
            $memoryStream = [IO.MemoryStream]::new()
            # read our file bytes,
            $fileBytes = [IO.File]::ReadAllBytes($in.FullName)
            # write our file bytes to our stream,
            $memoryStream.Write($fileBytes, 0,$fileBytes.Length)
            # and make waves.
            $memoryStream | makeWave
            continue
        }

        # Pass thru unknown input
        $in
    }

    # If we had any piped input, return now
    return
}

# Define a filter to decorate our wave and execute arguments
filter makeWave {
    # Take the input object.
    $WaveStream = $_
    # If it is not yet a `Wave`
    if ($WaveStream.pstypenames -notcontains 'Wave') { 
        # make it a `Wave`.
        $WaveStream.pstypenames.insert(0,'Wave')
    }
    # If it is not yet an `audio/wav`
    if ($WaveStream.pstypenames -notcontains 'audio/wav') {
        # make it an `audio/wav`
        $WaveStream.pstypenames.insert(0,'audio/wav')
    }       

    # If we have no arguments
    if (-not $ArgumentList.Length) {
        $WaveStream # simply output the wave.
    } else {
        # If we have any arguments    
        # try to execute them.
        try {
            # Set `$this` first.
            $this = $WaveStream
            # Then call `Go` with splatting
            # (so arguments bind properly and do not get unrolled).
            . $WaveStream.Go.Script @ArgumentList
        } catch {
            # If this failed, write an error
            $PSCmdlet.WriteError($_)
        }
    }
}

# If a stream is provided
if ($Stream) {
    # make it a wave and return
    return $stream | makeWave    
}

# If a path was provided
if ($Path) {
    # Get all items at that path
    foreach ($unresolvedPath in 
        $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($path)
    ) {
        # If the item is not a file, continue.
        if (-not [IO.File]::Exists($unresolvedPath)) { continue }

        # If we create the stream directly from the file bytes,
        # then we cannot change it's length in the future.

        # Since we want waves to be editable,
        # let's do things a little differently.

        # Create a new memory stream,
        $memoryStream = [IO.MemoryStream]::new()
        # read our file bytes,
        $fileBytes = [IO.File]::ReadAllBytes($unresolvedPath)
        # write our file bytes to our stream,
        $memoryStream.Write($fileBytes, 0,$fileBytes.Length)
        # and make waves.
        $memoryStream | makeWave
    }
    # Return after all paths have been become waves.
    return
}

# If we have gotten this far, 
# we are going to create a wave from scratch.

# Create a new memory stream.
$memoryStream = [IO.MemoryStream]::new()

# If the audio format is `3` (IEEE float), 
# and the bits per sample is less than 32
if ($AudioFormat -eq 3 -and $BitsPerSample -lt 32) {
    $BitsPerSample = 32 # force it to be the right size for IEEE float.
}

# If we have no computed the bytes per block
if (-not $BytesPerBlock) {
    # It should be the channel count times the number of bytes in each sample.
    $BytesPerBlock = $ChannelCount * $BitsPerSample/8
}

if (-not $BytesPerSecond) {
    # Number of bytes to read per second (Frequency * BytePerBloc).
    $BytesPerSecond = $SampleRate * $BytesPerBlock
}

# If we have been provided samples, but not PCM data
if ($samples -and -not $PCM) {
    # now would be the time to encode it.
    $sampleNumber = 0

    # Since this may take a bit, let's write progress as we go.
    $progress = [Ordered]@{
        Id = Get-Random
        Status = " "
        Activity = "Encoding"    
    }

    # We will reassign our PCM data to the encoded samples
    $PCM = @(foreach ($sample in $samples) {
        #region Encode Sample

        # We _could_ encapsulate the encoding off into it's own procedure.

        # However, callstacks have overhead.

        # Wave samples should only be encoded two places:
        # here, and in Wave.Type.set_Samples.

        #region Encoding Progress
        # Progress bars also have overhead, 
        # and we _really_ don't want to generate a progress bar per sample.
        # (that would generate more overhead from progress than encoding)

        # So we will only write progress once every 64kb samples
        # (or about every 1.5 seconds worth of CD quality audio in mono)
        if (-not ($sampleNumber % 64kb)) {
            # Our status is simply the ratio of progress.
            $progress.Status = "$sampleNumber / $($Samples.Length)"
            # Our percentage complete is that ratio times 100.
            $progress.PercentComplete = ($sampleNumber * 100 / $samples.Length)
            # Our seconds remaining is the number of remaining seconds to process
            $progress.SecondsRemaining = (
                # We can determine this based off of the number of samples left                
                ($Samples.Length - $sampleNumber) * 
                    # multiplied by the 1/SampleRate*ChannelCount.
                    (1 / ($SampleRate * $ChannelCount))
            )
            Write-Progress @progress
        }

        # Increment our sample number.
        $sampleNumber++
        #endregion Encoding Progress

        # If we are using 32-bit floating point audio
        if ($BitsPerSample -eq 32 -and $audioFormat -eq 3) {
            # we are basically done.
            # No clamping required. # Just cast to float, 
            $GetBytes.Invoke([float]$sample) # get the bytes,
            continue # and continue 
        }

        # If we are dealing with whole number audio formats,
        # We've got to clamp it down to an amplitude between -1 and 1.

        # Unfortunately, `Clamp` is not part of older .NET framework versions
        # So we will clamp the old-fashioned way, with an `if`
        if ($sample -gt 1) { $sample = 1 }
        elseif ($sample -lt -1) { $sample = -1 }

        # If there are 8 bits per sample
        if ($BitsPerSample -eq 8) {
            # round each sample into bytes, with 127 as the zero point.
            [byte][Math]::Round(
                127.5 + $sample * 127.5
            )
        }

        # If there are 16 bits per sample
        elseif ($BitsPerSample -eq 16) {
            # we just need to scale an `[int16]`
            # Hardcode `[int16]::MaxValue` for speed
            [BitConverter]::GetBytes([int16]($sample * 32767))
        }

        # If there are 32 bits per sample
        elseif ($BitsPerSample -eq 32) {
            # we can just scale to an `[int32]`.
            # Hardcode `[int32]::MaxValue` for speed
            [BitConverter]::GetBytes([int32]($sample * 2147483647))
        }
        #endregion Encode Sample
    })
    $memoryStream | 
        Add-Member NoteProperty '#Samples' $Samples -Force

    $progress.Remove('PercentComplete')
    $progress.Completed = $true
    Write-Progress @progress
}

#region Make Wave

# Create a binary writer for our stream
$binaryWriter = [IO.BinaryWriter]::new($memoryStream)

# Wave Files are `RIFF` files,

# thus all `.wav` Files must start with `RIFF`
# > Bytes: 0..3
$binaryWriter.Write(
    [Text.Encoding]::ASCII.GetBytes("RIFF")
)

# Then they have the the total file size minus the wave header (8 bytes)
# This is the size of the remaining headers: 36 bytes.
# > Bytes: 4..7
$binaryWriter.Write(36 + $PCM.Length)

# `WAVE` is the primary `RIFF` type for this file
# > Bytes: 8..11
$binaryWriter.Write(
    [Text.Encoding]::ASCII.GetBytes("WAVE")
)

# Everything else in a WAVE file is a chunk.
# Chunks take the following format:
# 
# * 4 byte ASCII name
# * 4 byte uint32 length
# * A [byte[]] containing data.

# The first RIFF chunk must be a format block.
# This is "fmt " in ASCCI (the space is important)
# > Bytes: 12..15
$binaryWriter.Write(
    [Text.Encoding]::ASCII.GetBytes("fmt ")
)

# The format chunk is exactly 16 bytes.
# > Bytes: 16..19
$binaryWriter.Write([uint32]16)

# While Audio Format can be custom, 
# we only care about two audio formats:
# 
# * 1: PCM integer
# * 3: IEEE 754 float
# > Bytes 20..21
$binaryWriter.Write($AudioFormat)

# The next two bytes are the number of channels
# > Bytes 22..23
$binaryWriter.Write($ChannelCount)

# The next four bytes are the sample rate.
# > Bytes 24..27
$binaryWriter.Write($SampleRate)

# Bytes Per Second (ChannelCount * SampleRate * BitsPerSample / 8)
# > Bytes 28..31
$binaryWriter.Write($BytesPerSecond)
    
# Bytes Per Block (ChannelCount * BitsPerSample / 8)
# > Bytes 32..33
$binaryWriter.Write($BytesPerBlock)
# Number of bits per sample
# > Bytes 34..35
$binaryWriter.Write($BitsPerSample)
# The data chunk starts with a `data` header
# > Bytes 36..39
$binaryWriter.Write(
    [Text.Encoding]::ASCII.GetBytes("data")
)
# Followed by the length of the byte array:
# > Bytes 40..43
$binaryWriter.Write($PCM.Length)

# Everything beyond this point is data
# (if we have it)
if ($PCM.Length) {    
    $binaryWriter.Write($PCM)
}

# Seek the stream back to 0.
$memoryStream.Position = 0

# and make it a wave.
return $memoryStream | makeWave