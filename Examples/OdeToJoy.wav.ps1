<#
.SYNOPSIS
    Ode to Joy
.DESCRIPTION
    Beethoven's Ode to Joy, from Symphony #9
.LINK
    https://en.wikipedia.org/wiki/Symphony_No._9_(Beethoven)
#>
$ode = @(

    "E E F G"
    "G F E D"
    "C C D E"
    "E@1.5 D:2 D:2 ~"

    "E E F G"
    "G F E D"
    "C C D E"
    "D@1.5 C:2 C:2 ~"

    "D D E C"

    "D E:2 F:2 E C"

    "D E:2 F:2 E D"

    "C D G@2"

    "E E F G"
    "G F E D"
    "C C D E"

    "D C:2 C:2"
)

wave note $ode play