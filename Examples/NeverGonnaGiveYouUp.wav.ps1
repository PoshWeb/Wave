<#
.SYNOPSIS
    Never Gonna Give You Up    
.DESCRIPTION
    Never Gonna Let You Down

    Never Gonna Turn Around or Desert You
.NOTES
    Never Gonna Give You Up by Rick Astley

    Adapted from arduino-songs repository

    Intended for educational purposes and humorous critical commentary.
    
    Demonstrates how to port arduino songs to wave, 
    and how to enrich sounds with weights and chords
.LINK
    https://github.com/robsoncouto/arduino-songs/blob/master/nevergonnagiveyouup/nevergonnagiveyouup.ino
#>
param()

# The arduino-songs repository puts in songs as defined notes and fractional time
# negative numbers represented a dotted note, for example (-4 is (1/4 + 1/8))
$oldForm = @'
NOTE_D5,-4, NOTE_E5,-4, NOTE_A4,4, //1
NOTE_E5,-4, NOTE_FS5,-4, NOTE_A5,16, NOTE_G5,16, NOTE_FS5,8,
NOTE_D5,-4, NOTE_E5,-4, NOTE_A4,2,
NOTE_A4,16, NOTE_A4,16, NOTE_B4,16, NOTE_D5,8, NOTE_D5,16,
NOTE_D5,-4, NOTE_E5,-4, NOTE_A4,4, //repeat from 1
NOTE_E5,-4, NOTE_FS5,-4, NOTE_A5,16, NOTE_G5,16, NOTE_FS5,8,
NOTE_D5,-4, NOTE_E5,-4, NOTE_A4,2,
NOTE_A4,16, NOTE_A4,16, NOTE_B4,16, NOTE_D5,8, NOTE_D5,16,
REST,4, NOTE_B4,8, NOTE_CS5,8, NOTE_D5,8, NOTE_D5,8, NOTE_E5,8, NOTE_CS5,-8,
NOTE_B4,16, NOTE_A4,2, REST,4, 

REST,8, NOTE_B4,8, NOTE_B4,8, NOTE_CS5,8, NOTE_D5,8, NOTE_B4,4, NOTE_A4,8, //7
NOTE_A5,8, REST,8, NOTE_A5,8, NOTE_E5,-4, REST,4, 
NOTE_B4,8, NOTE_B4,8, NOTE_CS5,8, NOTE_D5,8, NOTE_B4,8, NOTE_D5,8, NOTE_E5,8, REST,8,
REST,8, NOTE_CS5,8, NOTE_B4,8, NOTE_A4,-4, REST,4,
REST,8, NOTE_B4,8, NOTE_B4,8, NOTE_CS5,8, NOTE_D5,8, NOTE_B4,8, NOTE_A4,4,
NOTE_E5,8, NOTE_E5,8, NOTE_E5,8, NOTE_FS5,8, NOTE_E5,4, REST,4,

NOTE_D5,2, NOTE_E5,8, NOTE_FS5,8, NOTE_D5,8, //13
NOTE_E5,8, NOTE_E5,8, NOTE_E5,8, NOTE_FS5,8, NOTE_E5,4, NOTE_A4,4,
REST,2, NOTE_B4,8, NOTE_CS5,8, NOTE_D5,8, NOTE_B4,8,
REST,8, NOTE_E5,8, NOTE_FS5,8, NOTE_E5,-4, NOTE_A4,16, NOTE_B4,16, NOTE_D5,16, NOTE_B4,16,
NOTE_FS5,-8, NOTE_FS5,-8, NOTE_E5,-4, NOTE_A4,16, NOTE_B4,16, NOTE_D5,16, NOTE_B4,16,

NOTE_E5,-8, NOTE_E5,-8, NOTE_D5,-8, NOTE_CS5,16, NOTE_B4,-8, NOTE_A4,16, NOTE_B4,16, NOTE_D5,16, NOTE_B4,16, //18
NOTE_D5,4, NOTE_E5,8, NOTE_CS5,-8, NOTE_B4,16, NOTE_A4,8, NOTE_A4,8, NOTE_A4,8, 
NOTE_E5,4, NOTE_D5,2, NOTE_A4,16, NOTE_B4,16, NOTE_D5,16, NOTE_B4,16,
NOTE_FS5,-8, NOTE_FS5,-8, NOTE_E5,-4, NOTE_A4,16, NOTE_B4,16, NOTE_D5,16, NOTE_B4,16,
NOTE_A5,4, NOTE_CS5,8, NOTE_D5,-8, NOTE_CS5,16, NOTE_B4,8, NOTE_A4,16, NOTE_B4,16, NOTE_D5,16, NOTE_B4,16,

NOTE_D5,4, NOTE_E5,8, NOTE_CS5,-8, NOTE_B4,16, NOTE_A4,4, NOTE_A4,8,  //23
NOTE_E5,4, NOTE_D5,2, REST,4,
REST,8, NOTE_B4,8, NOTE_D5,8, NOTE_B4,8, NOTE_D5,8, NOTE_E5,4, REST,8,
REST,8, NOTE_CS5,8, NOTE_B4,8, NOTE_A4,-4, REST,4,
REST,8, NOTE_B4,8, NOTE_B4,8, NOTE_CS5,8, NOTE_D5,8, NOTE_B4,8, NOTE_A4,4,
REST,8, NOTE_A5,8, NOTE_A5,8, NOTE_E5,8, NOTE_FS5,8, NOTE_E5,8, NOTE_D5,8,

REST,8, NOTE_A4,8, NOTE_B4,8, NOTE_CS5,8, NOTE_D5,8, NOTE_B4,8, //29
REST,8, NOTE_CS5,8, NOTE_B4,8, NOTE_A4,-4, REST,4,
NOTE_B4,8, NOTE_B4,8, NOTE_CS5,8, NOTE_D5,8, NOTE_B4,8, NOTE_A4,4, REST,8,
REST,8, NOTE_E5,8, NOTE_E5,8, NOTE_FS5,4, NOTE_E5,-4, 
NOTE_D5,2, NOTE_D5,8, NOTE_E5,8, NOTE_FS5,8, NOTE_E5,4, 
NOTE_E5,8, NOTE_E5,8, NOTE_FS5,8, NOTE_E5,8, NOTE_A4,8, NOTE_A4,4,

REST,-4, NOTE_A4,8, NOTE_B4,8, NOTE_CS5,8, NOTE_D5,8, NOTE_B4,8, //35
REST,8, NOTE_E5,8, NOTE_FS5,8, NOTE_E5,-4, NOTE_A4,16, NOTE_B4,16, NOTE_D5,16, NOTE_B4,16,
NOTE_FS5,-8, NOTE_FS5,-8, NOTE_E5,-4, NOTE_A4,16, NOTE_B4,16, NOTE_D5,16, NOTE_B4,16,
NOTE_E5,-8, NOTE_E5,-8, NOTE_D5,-8, NOTE_CS5,16, NOTE_B4,8, NOTE_A4,16, NOTE_B4,16, NOTE_D5,16, NOTE_B4,16,
NOTE_D5,4, NOTE_E5,8, NOTE_CS5,-8, NOTE_B4,16, NOTE_A4,4, NOTE_A4,8, 

NOTE_E5,4, NOTE_D5,2, NOTE_A4,16, NOTE_B4,16, NOTE_D5,16, NOTE_B4,16, //40
NOTE_FS5,-8, NOTE_FS5,-8, NOTE_E5,-4, NOTE_A4,16, NOTE_B4,16, NOTE_D5,16, NOTE_B4,16,
NOTE_A5,4, NOTE_CS5,8, NOTE_D5,-8, NOTE_CS5,16, NOTE_B4,8, NOTE_A4,16, NOTE_B4,16, NOTE_D5,16, NOTE_B4,16,
NOTE_D5,4, NOTE_E5,8, NOTE_CS5,-8, NOTE_B4,16, NOTE_A4,4, NOTE_A4,8,  
NOTE_E5,4, NOTE_D5,2, NOTE_A4,16, NOTE_B4,16, NOTE_D5,16, NOTE_B4,16,

NOTE_FS5,-8, NOTE_FS5,-8, NOTE_E5,-4, NOTE_A4,16, NOTE_B4,16, NOTE_D5,16, NOTE_B4,16, //45
NOTE_A5,4, NOTE_CS5,8, NOTE_D5,-8, NOTE_CS5,16, NOTE_B4,8, NOTE_A4,16, NOTE_B4,16, NOTE_D5,16, NOTE_B4,16,
NOTE_D5,4, NOTE_E5,8, NOTE_CS5,-8, NOTE_B4,16, NOTE_A4,4, NOTE_A4,8,  
NOTE_E5,4, NOTE_D5,2, NOTE_A4,16, NOTE_B4,16, NOTE_D5,16, NOTE_B4,16,
NOTE_FS5,-8, NOTE_FS5,-8, NOTE_E5,-4, NOTE_A4,16, NOTE_B4,16, NOTE_D5,16, NOTE_B4,16, //45

NOTE_A5,4, NOTE_CS5,8, NOTE_D5,-8, NOTE_CS5,16, NOTE_B4,8, NOTE_A4,16, NOTE_B4,16, NOTE_D5,16, NOTE_B4,16,
NOTE_D5,4, NOTE_E5,8, NOTE_CS5,-8, NOTE_B4,16, NOTE_A4,4, NOTE_A4,8, 

NOTE_E5,4, NOTE_D5,2, REST,4
'@ -split # to make this objects, split by newlines
    '(?>\r\n|\n)' -replace  # then replace
    '//.+?$' -join # any single-line comments
    [Environment]::NewLine # and join by newlines.


# To handle the notted note format, we'll replace numbers after commas 
$newForm = [Regex]::Replace($oldForm, ',-?\d+',{
    param($match)
    # The denominator is the number portion
    $denominator = $match -replace '\D' -as [int]
    # If it is not negative
    if ($match -notmatch '-') {        
        "@$(1/$denominator)" # put it in @ format.
    } else {
        # If it is negative, 
        "@$(
            # it's @ (1/$n + 1/$2n)
            (1/$denominator) + (1/($denominator*2))
        )"
    }
    
}) -replace # After we've replaced our time
    'NOTE_' -replace # we just have to drop the NOTE_
    'REST', '~' -replace # and replace their RESTs with our own
    ',', ' ' # and put spaces in between, because commas would try to combine.

# In this demo
$song = wave instrument @(
    # we'll use a triangle wave    
    'triangle'
) chords @(
    # and we will play at one octave lower
    0.5
    # and _almost_ the original frequency, 
    # which will give us a slight chorus.
    1.001
) weights @(
    # We'll play our original sound at 75%
    0.75
    # We'll play the lower octave at 25%    
    0.25
    # And we'll take it up to 11 by adding our chorus
    0.1
) volume 0.42 bpm (
    128/4
) note $newForm

# $song | wave play
$song | wave save ./never.wav
