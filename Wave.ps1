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
#>
[Alias('wav', '.wav','〜')]
[CmdletBinding(PositionalBinding=$false)]
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
[Alias('BPB', 'PB')]
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

# The sample data.
[Alias('PulseControlModulation')]
[byte[]]
$PCM,

# If set, will run as a background job.
[switch]
$AsJob
)

$allInput = @($input)

if (-not $allInput) {
    $allInput = $InputObject
}

if ($AsJob) {
    $IO = [Ordered]@{} + $PSBoundParameters
    $IO.Remove('AsJob')
    $IO.ModulePath = $MyInvocation.MyCommand.Module.Path -replace '\.psm1$', '.psd1'
    $IO.InputObject = $allInput
    $JobDefinition = {
        param([Collections.IDictionary]$Parameter)

        if ($Parameter.ModulePath) {
            Import-Module $parameter.ModulePath
            $Parameter.Remove('ModulePath')
        }

        Wave @Parameter
    }
    if ($ExecutionContext.SessionState.InvokeCommand.GetCommand('Start-ThreadJob', 'Cmdlet')) {
        Start-ThreadJob -ScriptBlock $JobDefinition -ArgumentList $IO
    } else {
        Start-Job -ScriptBlock $JobDefinition -ArgumentList $IO
    }
    $waveJob = Start-ThreadJob 
        
    return $waveJob
}

if ($allInput.Length) {
    # This will attempt to be a bit clever, 
    # but hopefully not too much.

    foreach ($in in $allInput) {
        if ($in.pstypenames -contains 'audio/wav') {
            $in.Go($ArgumentList)
            continue
        }
        
        if ($in -is [IO.FileInfo] -and 
            $in.Extension -eq '.wav'
        ) {
            $in
        }
    }

    return
}

filter toWave {
    $WaveStream = $_
    $WaveStream.pstypenames.insert(0,'audio/wav')
    $WaveStream.pstypenames.insert(0,'Wave')    

    if ($ArgumentList) {
        try {
            $WaveStream.Go($ArgumentList)
        } catch {
            $PSCmdlet.WriteError($_)
        }        
    } else {
        $WaveStream
    }    
}

if ($Stream) {
    $stream | toWave    
}
elseif ($Path) {
    foreach ($unresolvedPath in 
        $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($path)
    ) {
        if ([IO.File]::Exists($unresolvedPath)) {
            $memoryStream = [IO.MemoryStream]::new(
                [IO.File]::ReadAllBytes($unresolvedPath)
            )
            $memoryStream | toWave                        
        }
    }  
}
elseif (-not $Stream) {    
    
    if ($AudioFormat -eq 3 -and $BitsPerSample -lt 32) {
        $BitsPerSample = 32
    }

    if ($samples -and -not $PCM) {
        $GetBytes = [BitConverter]::GetBytes
        $PCM = @(foreach ($sample in $samples) {
            #region Encode Sample

            # We _could_ encapsulate the encoding off into it's own procedure.

            # However, callstacks have overhead.

            # Inline code will be quicker.
            # (hence duplicating it across multiple files)

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
                # round each sample into bytes, with 128 as the zero point.
                [byte][Math]::Round(
                    128 + $sample * 127
                )
            }

            # If there are 16 bits per sample
            elseif ($BitsPerSample -eq 16) {
                # we just need to scale an `[int16]`
                # Hardcode `[int16]::MaxValue` for speed
                $GetBytes.Invoke([int16]($sample * 32767))
            }

            # If there are 32 bits per sample
            elseif ($BitsPerSample -eq 32) {
                # we can just scale to an `[int32]`.
                # Hardcode `[int32]::MaxValue` for speed
                $GetBytes.Invoke([int32]($sample * 2147483647))
            }
            #endregion Encode Sample
        })
        $memoryStream | 
            Add-Member NoteProperty '#Samples' $Samples -Force
    }
    
    $stream =     
        $memoryStream =
            [IO.MemoryStream]::new()

    $ascii        = [Text.Encoding]::ASCII

    $binaryWriter = [IO.BinaryWriter]::new($memoryStream)

    # `.wav` Files must start with RIFF
    $binaryWriter.Write($ascii.GetBytes("RIFF"))
    # Then they are the total header size minus 8 bytes (44 - 8)
    $binaryWriter.Write(36 + $PCM.Length)

    # WAVE is the primary RIFF type for this file
    $binaryWriter.Write($ascii.GetBytes("WAVE"))

    # The first RIFF block must be a format block
    # This is "fmt " in ASCCI (the space is important)    
    $binaryWriter.Write($ascii.GetBytes("fmt "))

    # Chunk size minus 8 bytes, which is 16 bytes here 
    $binaryWriter.Write(16)

    # Audio format (1: PCM integer, 3: IEEE 754 float)
    $binaryWriter.Write($AudioFormat)

    # Number of channels (only mono for now)
    $binaryWriter.Write($ChannelCount)

    # Sample rate (in hertz)
    $binaryWriter.Write($SampleRate)

    if (-not $BytesPerBlock) {
        $BytesPerBlock = $ChannelCount * $BitsPerSample/8
    }
    
    # Number of bytes to read per channel per second (Frequency * BytePerBloc).
    $BytesPerSecond = $SampleRate * $BytesPerBlock

    $binaryWriter.Write($BytesPerSecond)
        
    # Bytes Per Block (ChannelCount * BitsPerSample / 8)
    $binaryWriter.Write($BytesPerBlock)
    # Number of bits per sample
    $binaryWriter.Write($BitsPerSample)
    # The data block
    $binaryWriter.Write($ascii.GetBytes("data"))
    # The length of the byte array
    $binaryWriter.Write($PCM.Length)

    if ($PCM.Length) {
        # and the data chunk.
        $binaryWriter.Write($PCM)
    }
    
    $Time = [TimeSpan]::FromSeconds($pcm.Length / $BytesPerSecond)

    # Seek the stream back to 0.
    $memoryStream.Position = 0

    return $memoryStream | toWave
}

if (-not $memoryStream) { return }