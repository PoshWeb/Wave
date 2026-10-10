<#
.SYNOPSIS
    Korobeiniki
.DESCRIPTION
    Korobeiniki is an interesting little ditty that 
    many people know as the theme to Tetris.

    It alternates time between notes quite a lot.

    There are many ways we can write this.
#>

# We can use notemoji to represent it as a series of whole and half notes.
$KorobeinikiNotemoji = '
    𝅝 e5 𝅗𝅥 b4 c5 𝅝 d5 𝅗𝅥 c5 b4
    𝅝 a4 𝅗𝅥 a4 c5 𝅝 e5 𝅗𝅥 d5 c5
    𝅝 b4 𝅗𝅥 ~  c5 𝅝 d5 e5 c5 a4 a4 ~
    𝅗𝅥 ~ d5 ~ f5 𝅝 a5 𝅗𝅥 g5 f5 
    𝅝 e5 𝅗𝅥 ~ c5 𝅝 e5 𝅗𝅥 d5 c5 
    𝅝 b4 𝅗𝅥 b4 c5 𝅝 d5 e5 c5 a4 a4 ~
'

# We can use ++ and -- to go uptempo and downtempo.
$KorobeinikiUpTempo = '
    e5 ++ b4 c5 -- d5 ++ c5 b4 --
    a4 ++ a4 c5 -- e5 ++ d5 c5 --
    b4 ++ ~ c5 -- d5 e5 c5 a4 a4 ~
    ++ ~ d5 ~ f5 -- a5 ++ g5 f5 -- 
    e5 ++ ~ c5 -- e5 ++ d5 c5 -- 
    b4 ++ b4 c5 -- d5 e5 c5 a4 a4 ~
'

$KorobeinikiRatio = '
    e5 b4:2 c5:2 d5 c5:2 b4:2
    a4 a4:2 c5:2 e5 d5:2 c5:2
    b4 ~:2 c5:2 d5 e5 c5 a4 a4 ~
    ~:2 d5:2 ~:2 f5:2 a5 g5:2 f5:2
    e5 ~:2 c5:2 e5 d5:2 c5:2
    b4 b4:2 c5:2 d5 e5 c5 a4 a4 ~
'

$KorobeinikiDivide = '
    e5 b4/2 c5/2 d5 c5/2 b4/2
    a4 a4/2 c5/2 e5 d5/2 c5/2
    b4 ~/2 c5/2 d5 e5 c5 a4 a4 ~
    ~/2 d5/2 ~/2 f5/2 a5 g5/2 f5/2
    e5 ~/2 c5/2 e5 d5/2 c5/2
    b4 b4/2 c5/2 d5 e5 c5 a4 a4 ~
'

$KorobeinikiAtTime = '
    e5 b4@0.5 c5@0.5 d5 c5@0.5 b4@0.5
    a4 a4@0.5 c5@0.5 e5 d5@0.5 c5@0.5
    b4 ~@0.5 c5@0.5 d5 e5 c5 a4 a4 ~
    ~@0.5 d5@0.5 ~@0.5 f5@0.5 a5 g5@0.5 f5@0.5
    e5 ~@0.5 c5@0.5 e5 d5@0.5 c5@0.5
    b4 b4@0.5 c5@0.5 d5 e5 c5 a4 a4 ~
'

$KorobeinikiMultiply = '
    e5 b4*0.5 c5*0.5 d5 c5*0.5 b4*0.5
    a4 a4*0.5 c5*0.5 e5 d5*0.5 c5*0.5
    b4 ~*0.5 c5*0.5 d5 e5 c5 a4 a4 ~
    ~*0.5 d5*0.5 ~*0.5 f5*0.5 a5 g5*0.5 f5*0.5
    e5 ~*0.5 c5*0.5 e5 d5*0.5 c5*0.5
    b4 b4*0.5 c5*0.5 d5 e5 c5 a4 a4 ~
'

# Pick a random way to play the tune
$KorobeinikiRandom = 
    $KorobeinikiRatio,  $KorobeinikiNotemoji, $KorobeinikiUpTempo,
    $KorobeinikiAtTime, $KorobeinikiMultiply, $KorobeinikiDivide | 
        Get-Random

wav volume 0.50 note $KorobeinikiRandom play save ./Korobeiniki.wav
