describe Wave {
    it 'Can make a note or two' {
        $wave = wave note cafe        
        [Math]::Round(
            $wave.Duration/([TimeSpan]::FromSeconds(60/128))
        ) | Should -be 4
    }
    it 'Can play 88 midi keys at 512 bpm' {
        $midiWave = wave bpm 512 note "$(
            foreach ($key in 1..88) {
                "midi$(20 + $key)"
            }
        )"

        [Math]::Round(
            $midiWave.Duration/([TimeSpan]::FromSeconds(60/512))
        ) | Should -be 88
    }
}
