<#
.SYNOPSIS
    Sets the chords in a Wave.
.DESCRIPTION
    Sets any custom chords applied to a wave.    

    A frequency can be played on any number of "chords"

    We can think of each vibration within a sound as a literal string, 
    vibrating at a frequency.

    Each chord is a ratio to the original frequency.
.NOTES
    Chords are an incredibly flexible way to change the sounds we generate.

    Most instruments play more than one frequency at a time,
    and all stringed instruments are effectively a collection of 
    [Monochords](https://en.wikipedia.org/wiki/Monochord).

    Chords allow us to digitally simulate this effect.

    Each Chord is a multiple of the original frequency.

    Each Chord can also have a weight attached.
.EXAMPLE
    # Play every note with one lower octave
    wave setchords 0.5 note cafe play
.EXAMPLE
    # Play every note with one highter octave
    wave setchords 2 note cafe play
.EXAMPLE
    # Play every note with one highter and lower octave
    wave setchords 2,0.5 note cafe play
.EXAMPLE
    # Play every note with two highter and two lower octaves
    wave setchords 4,2,0.5,0.25 note cafe play
.EXAMPLE
    # Play every note with two lower octaves and two higher octaves
    wave setchords 0.25,0.5,2,4 note cafe play
.EXAMPLE
    # Play every note with a minor deviation, creating an ethereal echo.
    wave setchords 0.99,1.01 note cafe play
.LINK
    https://en.wikipedia.org/wiki/Monochord
#>
param([double[]]$chords)

$this.Chords = $chords
return $this




