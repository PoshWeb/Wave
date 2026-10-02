<#
.SYNOPSIS
    Sets Wave HTML
.DESCRIPTION
    Sets a custom HTML representation of a wave.

    By default, a wave in is just an `<audio>` element,
    with the source being the wave's `.DataUrl`.

    This allows us to show a Wave in HTML any way we wish.
.NOTES
    By default, a wave in is just an `<audio>` element,
    with the source being the wave's `.DataUrl`.

    While this works, 
    it does not provide any surrounding context or allow for customization.

    By allowing a custom value, we can add simple surrounding context
    (like the name of the note or tune).

    We can also change how the audio is displayed or used.
#>
param()

$this | Add-Member NoteProperty '#HTML' $args -Force