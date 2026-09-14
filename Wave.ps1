<#
.SYNOPSIS
    `.wav` stream
.DESCRIPTION
    Creates a `.wav` stream.
.LINK
    https://en.wikipedia.org/wiki/WAV#WAV_file_header
#>
[Alias('wav', '.wav','〜')]
[CmdletBinding(PositionalBinding=$false)]
param(
# The arguments to pass to turtle.
[ArgumentCompleter({
    param ( $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters )
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
[ushort]
$ChannelCount = 1,

# The bits per sample
[ushort]
$BitsPerSample = 8,

# The sample rate, in hertz
[int]
$Rate = 44100,

# Audio format (2 bytes) (1: PCM integer, 3: IEEE 754 float)
[ushort]
$AudioFormat = 1,

# The number of bytes per block
[ushort]
$BytesPerBlock,

# The bytes per second
[uint32]
$BytesPerSecond,

[string]
$Path,

[IO.Stream]
$Stream,

# The sample data.
[byte[]]
$PCM
)

filter toWave {
    $WaveStream = $_
    $WaveStream.pstypenames.insert(0,'audio/wav')
    $WaveStream.pstypenames.insert(0,'Wave')    

    if ($ArgumentList) {
        $WaveStream.Go($ArgumentList)
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

if (-not $Stream) {    
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
    $binaryWriter.Write($Rate)

    if (-not $BytesPerBlock) {
        $BytesPerBlock = $ChannelCount * $BitsPerSample/8
    }
    
    # Number of bytes to read per channel per second (Frequency * BytePerBloc).
    $BytesPerSecond = $Rate * $BytesPerBlock

    $binaryWriter.Write($BytesPerSecond)
        
    # Block Alignment. (not number of bytes per block) (NbrChannels * BitsPerSample / 8)
    # Block Alignment
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

    # Decorate the memory stream with two typenames:
    # * `audio/wav` (its content type)
    # * `Wave` (its pseudotype)
    $memoryStream.pstypenames.insert(0,'audio/wav')
    $memoryStream.pstypenames.insert(0,'Wave')

    # Return the memory stream
    $memoryStream | toWave
}

if (-not $memoryStream) { return }