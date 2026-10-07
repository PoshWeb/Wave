<#
.SYNOPSIS
    Happy Birthday!
.DESCRIPTION
    Happy Birthday to You, in DECPS format, converted into a wave/
#>

$escape = [char]27
$happyBirthday = @(
    "$escape[3;10;8,~"
    "$escape[3;5;8,~"
    "$escape[3;15;10;8;13,~"
    "$escape[3;30;12,~"
    "$escape[3;10;8,~"
    "$escape[3;5;8,~"
    "$escape[3;15;10;8;15,~"
    "$escape[3;30;13,~"
    "$escape[3;10;8,~"
    "$escape[3;5;8,~"
    "$escape[3;15;20;17;13;12,~"
    "$escape[3;30;10,~"
    "$escape[3;10;18,~"
    "$escape[3;5;18,~"
    "$escape[3;15;17;13;15,~"
    "$escape[3;30;13,~"
)
wave DECPS $happyBirthday save ./HappyBirthday.wav