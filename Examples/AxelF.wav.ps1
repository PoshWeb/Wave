<#
.SYNOPSIS
    Alex F
.DESCRIPTION
    The core riff from `Axel F` by `Harold Faltermeyer` in beep command format.
.NOTES
    This is often known as the Beverly Hills Cop theme.

    Adapted from:
    
    https://github.com/ShaneMcC/beeps/blob/master/beveryhillscop.sh
.LINK
    https://github.com/ShaneMcC/beeps/blob/master/beveryhillscop.sh
#>

$tune = @'
beep -f 659 -l 460 -n -f 784 -l 340 -n -f 659 -l 230 -n -f 659 -l 110 -n -f 880 -l 230 -n -f 659 -l 230 -n -f 587 -l 230 -n -f 659 -l 460 -n -f 988 -l 340 -n -f 659 -l 230 -n -f 659 -l 110 -n -f 1047 -l 230 -n -f 988 -l 230 -n -f 784 -l 230 -n -f 659 -l 230 -n -f 988 -l 230 -n -f 1318 -l 230 -n -f 659 -l 110 -n -f 587 -l 230 -n -f 587 -l 110 -n -f 494 -l 230 -n -f 740 -l 230 -n -f 659 -l 460
'@

wave note $tune play
