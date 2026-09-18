<#
.SYNOPSIS
    Gets Notemoji
.DESCRIPTION
    Gets Notemoji.

    This maps a beat time signature to emoji.

    |Note Length|Name|Emoji|Hex|
    |-|-|-|-|
    |1|Whole Note|𝅝|0x1d15d|
    |1/2|Half Note|𝅗𝅥|0x1d15e|
    |1/4|Quarter Note|𝅘𝅥|0x1d15f|
    |1/8|Eighth Note|𝅘𝅥𝅮|0x1d160|
    |1/16|Sixteenth Note|𝅘𝅥𝅯|0x1d161|
    |1/32|Thirty-Second Note|𝅘𝅥𝅰|0x1d162|
    |1/64|Sixty-fourth Note|𝅘𝅥𝅱|0x1d163|
    |1/128|One hundred Twenty-Eighth Note|𝅘𝅥𝅲|0x1d164|
.NOTES
    The Unicode standard contains symbols for note lengths in the range `0x1d15d..0x1d164`.

    This property provides an easy-to-read mapping of time signature to note.

    Because the note range is sequential, we can calculate the time signature by index:

    ~~~PowerShell
    $notemoji = "𝅝","𝅗𝅥","𝅘𝅥","𝅘𝅥𝅮","𝅘𝅥𝅯","𝅘𝅥𝅰","𝅘𝅥𝅲","𝅘𝅥𝅲"
    $noteTime = '𝅗𝅥'
    $noteRatio = $notemoji.IndexOf($noteTime) + 1 
    ~~~
#>
return "𝅝","𝅗𝅥","𝅘𝅥","𝅘𝅥𝅮","𝅘𝅥𝅯","𝅘𝅥𝅰","𝅘𝅥𝅲","𝅘𝅥𝅲"