<#
.SYNOPSIS
    Wave Say 
.DESCRIPTION
    Wave Text to Speech.

    Uses the operating system's text-to-speech functionality to say a phrase.
.NOTES
    This will always generate a new wave.

    Additionally, most programs encode speech at a 22050 sample rate.

    To mix it with audio without distortions, you may need to resample.
.EXAMPLE
    wave say "whatever"
#>
param(
# The phrase to say.  By default `hello world`
[string]
$Phrase = 'Hello World',

# The voice to speak in.  
# If none is provided, the default voice will be used.
[string]
$Voice,

# A pitch adjustment, between -1 (half pitch) and 1 (double pitch)
[ValidateRange(-1.0,1.0)]
[double]
$Pitch = 0.0,

# The volume used to speak.
[double]
$Volume = 0.42
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
    $espeak = $ExecutionContext.SessionState.InvokeCommand.GetCommand('espeak','Application')
    if (-not $espeak) {
        Write-Warning "espeak required for text to speech on Linux"
        return
    }
    # If we are on linux, we will use `espeak` to speak the phrase
    $espeakParameters = @(
        '-v', $Voice,
        '-p', [int](($Pitch + 1) * 50),
        '-a', [int]($Volume * 200),
        '-w', $phraseFile,
        $phrase
    )

    $espoke = & $espeak @espeakParameters

    if (-not $?) {
        return 
    }    
}
elseif ($isMacOS) {
    # If we are on macOS, we will use `say` to speak the phrase
    $iSay = @(
        '-v', $Voice
        '-r', [int](($Pitch + 1) * 200)
        '-o', $phraseFile
        "[[volm $Volume]]$phrase"
    )

    $say = $ExecutionContext.SessionState.InvokeCommand.GetCommand('say','Application')
    if (-not $say) {
        Write-Warning "say required for text to speech on Linux"
        return
    }

    $iSaid = & $say @iSay

    if (-not $?) {
        return 
    }

}
else {
    # If we are on Windows,
    # we will use the Speech Api COM object to speak the phrase
    $sapi = New-Object -ComObject Sapi.SpVoice
    $realRate = $Pitch * 10
    $sapi.Rate = [int]$realRate 
    $sapiVoice = 
        @(foreach ($sapiVoiceInfo in $sapi.GetVoices()) {
            $sapiVoiceLanguage =
                [Globalization.CultureInfo][int]"0x$(
                    $sapiVoiceInfo.Getattribute("Language")
                )"
            
            if ($sapiVoiceLanguage -like "$([CultureInfo]::CurrentUICulture)") {
                $sapiVoiceInfo
            }
        })[0]

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
    if (-not $worked) { return }
}


if (Test-Path $phraseFile) {
    $waveSay = wave -Path $phraseFile
    if (-not $waveSay.Title) {
        $waveSay.Title = $Phrase
    }

    if ($voice -and -not $waveSay.Artist) {
        $waveSay.Artist = $voice
    }

    $waveSaved = $waveSay.Save($phraseFile)        

    return wave -Path $waveSaved
}
