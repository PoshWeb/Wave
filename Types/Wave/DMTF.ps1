<#
.SYNOPSIS
    DMTF TouchTone generator
.DESCRIPTION
    Dual-tone multi-frequency (DMTF) is the "Touch Tone" telephone standard.

    This allows you to make touch tones into waves.
.NOTES    
    |<u>High Tone</u><br/>Low Tone|1209|1336|1477|1633|
    |:-:|:-:|:-:|:-:|:-:|
    |697|1|2|3|A|
    |770|4|5|6|B|
    |852|7|8|9|C|
    |941|*|0|#|D|
.LINK
    https://en.wikipedia.org/wiki/DTMF_signaling
.LINK
    https://en.wikipedia.org/wiki/Precise_tone_plan
#>
param(
# The DMTF sequence.
[string]$Sequence,

# The duration.
# If a BPM is provided, will play at that rate
# If no BPM has been provided, tones will last 0.4 seconds.
[TimeSpan]$Duration = $(
    if ($this.BPM) {
        $this.BPM
    } else {    
        [TimeSpan]::FromSeconds(0.4)
    }
),

# The volume
# If a volume has been provided, will play at that volume
# If no volume has been provided, will play at 1/4 volume.
[double]$Volume = $(
    if ($this.Volume) {
        $this.Volume
    } else {
        1/4
    }
)
)


# DMTF tones are a superimposition (addition of two waves)

$lowtones  = 697, 770, 852, 941
$highTones = 1209, 1336, 1477, 1633

$validDmtf = [Regex]::new('[0-9a-d\*\#\-\._!]')
foreach ($match in $validDmtf.Matches(($Sequence -join ' '))) {
    $dmft = "$match"
    [Ordered]@{
        Name = "DMTF $dmtf"
        Frequency = @(
            switch ($dmft) {
                _ { 350, 440 } # Dial tone
                - { 0 } # rest
                . { 0 } # rest
                ! { 480, 620 } # Busy signal (Precise Tone Plan)
                1 { $lowtones[0], $highTones[0] }
                2 { $lowtones[0], $highTones[1] }
                3 { $lowtones[0], $highTones[2] }
                A { $lowtones[0], $highTones[3] }
                4 { $lowtones[1], $highTones[0] }
                5 { $lowtones[1], $highTones[1] }
                6 { $lowtones[1], $highTones[2] }
                B { $lowtones[1], $highTones[3] }
                7 { $lowtones[2], $highTones[0] }
                8 { $lowtones[2], $highTones[1] }
                9 { $lowtones[2], $highTones[2] }
                C { $lowtones[2], $highTones[3] }
                '*' { $lowtones[3], $highTones[0] }
                0 { $lowtones[3], $highTones[1] }
                '#' { $lowtones[3], $highTones[2]}        
                D { $lowtones[3], $highTones[3]}
            }
        )
        Duration = $Duration
        Volume = $volume
    }    
}

