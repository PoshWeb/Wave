<#
.SYNOPSIS
    Imperial March
.DESCRIPTION
    Star Wars Imperial March by John Williams, in DECPS format
#>
$escape = [char]27
$march = @(
    "$escape[3;20;7;7;7,~",
    "$escape[3;15;3,~",
    "$escape[3;5;10,~",        
    "$escape[3;20;7,~",
    "$escape[3;15;3,~",
    "$escape[3;5;10,~",
    "$escape[3;40;7,~",
    "$escape[3;20;14;14;14,~",
    "$escape[3;15;15,~",
    "$escape[3;5;10,~",
    "$escape[3;20;6,~",
    "$escape[3;15;3,~",
    "$escape[3;5;10,~",
    "$escape[3;40;7,~",
    "$escape[3;20;19;7;19,~",
    "$escape[3;10;18;17,~",
    "$escape[3;5;16;15,~",
    "$escape[3;10;16;0;8,~",
    "$escape[3;20;13,~",
    "$escape[3;10;12;11,~",
    "$escape[3;5;10;9,~",
    "$escape[3;10;10;0;3,~",
    "$escape[3;20;6,~",
    "$escape[3;15;3,~",
    "$escape[3;5;10,~",
    "$escape[3;20;7,~",
    "$escape[3;15;3,~",
    "$escape[3;5;10,~",
    "$escape[3;40;7,~"
) -join [Environment]::Newline

$wav = wave note $march
$wav.play()