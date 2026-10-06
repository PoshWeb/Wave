<#
.SYNOPSIS
    Taps
.DESCRIPTION
    `Taps`, in Beep command format, with added Strings
#>

$taps = @'
beep \
-l 384 -f 392.00 -D 64 \
-n -l 128  -f 392.00 -D 64 \
-n -l 1536 -f 523.25 -D 128 \
-n -l 384  -f 392.00 -D 64 \
-n -l 128  -f 523.25 -D 64 \
-n -l 1536 -f 659.26 -D 128 \
-n -l 384  -f 392.00 -D 64 \
-n -l 128  -f 523.25 -D 64 \
-n -l 512  -f 659.26 -D 64 \
-n -l 384  -f 392.00 -D 64 \
-n -l 128  -f 523.25 -D 64 \
-n -l 512  -f 659.26 -D 64 \
-n -l 384  -f 392.00 -D 64 \
-n -l 128  -f 523.25 -D 64 \
-n -l 1536 -f 659.26 -D 128 \
-n -l 256  -f 523.25 -D 64 \
-n -l 256  -f 659.26 -D 64 \
-n -l 1024 -f 783.99 -D 64 \
-n -l 512  -f 659.26 -D 64 \
-n -l 512  -f 523.25 -D 64 \
-n -l 1536 -f 392.00 -D 128 \
-n -l 384  -f 392.00 -D 64 \
-n -l 128  -f 392.00 -D 64 \
-n -l 2048 -f 523.25 -D 0
'@ -replace '\\' -replace "[\r\n]"

wave strings 0.25,0.5,1,2 note $taps save ./Taps.wav play