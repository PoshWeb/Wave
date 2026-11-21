param(
[string]
$Phrase = 'Hello World',

[Collections.IDictionary]
[Alias('Options')]
$Option = [Ordered]@{},

[string]
$Voice,

[double]
$Volume = 0.42,

[ValidateRange(-1.0,1.0)]
[double]
$Pitch = 0.0
)

$phraseHash = ([BitConverter]::ToString(
    [Security.Cryptography.SHA256]::Create().ComputeHash($outputEncoding.GetBytes($phrase))
) -replace '-').ToLower()

$waveFolder = [Environment]::GetFolderPath("LocalApplicationData"), 'Wave' -join 
        [IO.Path]::DirectorySeparatorChar

$waveFolder = if (-not [IO.Directory]::Exists($waveFolder)) {
    [IO.Directory]::CreateDirectory($waveFolder)
} else {
    [IO.DirectoryInfo]$waveFolder
}

$phraseFile = if ($voice) {
    [IO.Path]::Combine($waveFolder.FullName, "$($phraseHash)_$($Voice).wav")
} else {
    [IO.Path]::Combine($waveFolder.FullName, "$($phraseHash).wav")
}

if ($isLinux) {
    # If we are on linux, we will use `espeak` to speak the phrase
    $espeakParameters = @(
        '-v', $Voice,
        '-p', [int](($Pitch + 1) * 50),
        '-a', [int]($Volume * 200),
        '-w', $phraseFile,
        $phrase
    )
}
elseif ($isMacOS) {
    # If we are on macOS, we will use `say` to speak the phrase
    $sayParameters = @(
        '-v', $Voice
        '-r', [int](($Pitch + 1) * 200)
        '-o', $phraseFile
        "[[volm $Volume]]$phrase"
    )
}
else {
    # If we are on Windows,
    # we will use the Speech Api COM object to speak the phrase
    $sapi = New-Object -ComObject Sapi.SpVoice
    $realRate = $Pitch * 10
    $sapi.Rate = [int]$realRate 
    $sapiVoice = 
        $sapi.GetVoices() | 
            Where-Object { 
                ([Globalization.CultureInfo][int]"0x$($_.Getattribute("Language"))").DisplayName -like "$language*"
            }  | 
            Select-Object -First 1

    $sapi.Volume = [int]($Volume * 100)
    $sapi.Voice  = $SapiVoice
    
    $voiceName = $sapi.Voice.id -replace '.+\\TTS_MS_\p{L}{2}-\p{L}{2}_' -replace '_\d+\.\d+'
    
    $phraseFile = [IO.Path]::Combine($waveFolder.FullName, "$($phraseHash)_$(
        $voiceName.Substring(0,1).ToUpper(),
            $voiceName.Substring(1).ToLower() -join ''
    ).wav") 

    
    $sapiFileStream  = New-Object -ComObject Sapi.SpFileStream
    $sapiFileStream.Format.Type = 19
    $sapiFileStream.Open($phraseFile, 3, $false)
    $sapi.AudioOutputStream = $sapiFileStream
    $worked = $sapi.Speak($phrase)
    $sapiFileStream.Close()
}


if (Test-Path $phraseFile) {
    return wave -Path $phraseFile
}
