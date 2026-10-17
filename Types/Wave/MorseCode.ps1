<#
.SYNOPSIS
    Morse Code Generator
.DESCRIPTION
    Generates Morse code at a given frequency
#>
param(
# The ,message we are generating.
# By default, a SOS
[string]
$Message = 'SOS',

# One or more frequencies to play
$Frequency = 440,

# The base duration.  This is the duration for a "dot"
[TimeSpan]$Duration = $(
    if ($this.BPM -is [timespan]) {
        $this.BPM
    } else {
        [TimeSpan]::FromSeconds(60/128/4)
    }
),

# The volume
[double]
$Volume = $(
    if ($this.Volume) { $this.Volume }
    else { 1 / ([Math]::pi * 2)}
),


# Dots are technically called "dits"
# And dashes are technically called "dahs"
# By olden standard, the ratio defaults to 3
[double]$DahRatio = 3.0
)


$ditTiming = $Duration
$dahTiming = $ditTiming * $DahRatio
$dot = @{
    Frequency = $Frequency
    Duration = $ditTiming
}
$dash = @{
    Frequency = $Frequency
    Duration = $dahTiming
}

foreach ($letter in $Message.ToCharArray()) {    
    switch ($letter) {
        '.' { $dot }
        '-' { $dash }
        'A' {
            $dot
            $dash
        }
        'B' {
            $dash, $dot, $dot, $dot
        }
        'C' {
            $dash, $dot, $dash, $dot
        }
        'D' {
            $dash, $dot, $dot
        }
        'E' {
            $Dash, $dot
        }
        'F' {
            $dot, $dot, $dash, $dot
        }
        'G' {
            $dash, $dash, $dot
        }
        'H' {
            @($dot) * 4
        }
        'I' {
            @($dot) * 2
        }
        'J' {
            $dot + @($dash) * 3
        }
        'K' {
            $dash, $dot, $dash
        }
        'L' {
            $dot, $dash, $dot, $dot
        }
        'M' {
            $dash, $dash
        }
        'N' {
            $dash, $dot
        }
        'O' {
            $dash, $dash, $dash
        }
        'P' {
            $dot, $dash, $dash, $dot
        }
        'Q' {
            $dash, $dash, $dot, $dash
        }
        'R' {
            $dot, $dash, $dot
        }
        'S' {
            $dot;$dot;$dot
        }
        'T' {
            $dash
        }
        'U' {
            $dot, $dot, $dash
        }
        'V' {
            $dot, $dot, $dot, $dash
        }
        'W' {
            $dot, $dash, $dash
        }
        'X' {
            $dash, $dot, $dot, $dash
        }
        'Y' {
            $dash, $dot, $dash, $dash
        }
        'Z' {
            $dash, $dash, $dot, $dot
        }
        '0' {
            $dash * 5
        }
        '1' {
            $dot
            @($dash) * 4
        }
        '2' {
            @($dot) * 2
            @($dash) * 2
        }
        '3' {
            @($dot) * 3 
            @($dash) * 2
        }
        '4' {
            @($dot) * 4
            @($dash) * 1
        }
        '5' {
            @($dot) * 5
        }
        '6' {
            @($dash) * 1
            @($dot) * 4
        }
        '7' {
            @($dash) * 1
            @($dot) * 3
        }
        '8' {
            @($dash) * 3
            @($dot) * 2
        }
        '9' {
            @($dash) * 4
            @($dot) * 1
        }
    }
    @{
        Frequency = 0
        Name = 'Rest'
        Duration = $ditTiming
    }
}
