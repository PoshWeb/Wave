<#
.SYNOPSIS
    Wave logo
.DESCRIPTION
    The Logo for Wave is a wave.
.NOTES
    Perhaps unsurprisingly, the logo for Wave is a wave.

    A sine wave can be represented by a cubic bezier curve.

    In it's most primal form, this is `c 1 -2 1 2 2 0`

    Translated into English:
    
    * This will move forward two, using relative positions
    * The first control point will be at `1 -2`, tugging us to the top of the curve.
    * The second control point will be at `1 2`, tugging us to the bottom of the curve.
    * The line will move forward by two.

    We can generalize this wave by thinking of the wavelength as 2 and the amplitude as 2.

    In general form, this is:

    ~~~PowerShell
    $sineWavePath =
        "c $($WaveLength/2) -$amplitude $($WaveLength/2) $amplitude $($WaveLength) 0"
    ~~~

    We can repeat the wave by multiplying it by a frequency:

    ~~~PowerShell
    $sineWavePath * $frequency
    ~~~    
.EXAMPLE
    .\Wave.svg.ps1 -Variant Animated > .\WaveAnimated.svg
.EXAMPLE
    .\Wave.svg.ps1 > .\Wave.svg
#>
param(
# The variant of the design.
$Variant = '',

# The frequency used for the wave.  
# This is number of times this wave will be multiplied in the image
# It defaults to 20, which is the low range of human hearing
[double]
$Frequency = 20,

# The length of the wave.
# This is the length of each sine wave.
[double]
$WaveLength = 4,

# The ampltude of the wave.
# This is the amount the wave deviates 
# from the center of the Y-axis
[double]
$Amplitude = 2,

# The rate at which the wave is animated, 
# in beats per minute.
# While most music is much faster than this,
# we do not want the logo to be _too_ distracting.
[double]
$BPM = 16,

# The width used in the stroke.
# By default 0.1%
[double]
$StrokeWidth = 0.1
)

$poshWeb = $(.\PoshWeb.svg.ps1 -Variant $Variant) -as [xml]
$poshWebSymbol = "<symbol id='PoshWeb' viewBox='$($poshWeb.svg.viewBox)'>$(
    $poshWeb.svg.InnerXml
)</symbol>"

# Declare our sine wave and cosine wave
$sineWave = 
    "c $($WaveLength/2) -$amplitude $($WaveLength/2) $amplitude $($WaveLength) 0"
$CosineWave =
    " c $($WaveLength/2) $amplitude $($WaveLength/2) -$amplitude $($WaveLength) 0"

$h = 50
@"
<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 $($frequency * $WaveLength) $($Amplitude)'>
$(
    if ($variant -notmatch 'nologo') { $poshWebSymbol }     
)
<path 
    stroke='#4488ff' 
    fill ='$(if ($variant -match 'fill') { '#4488ff'} else { 'transparent'})' 
    class='foreground-fill foreground-stroke'
    transform-origin='50% 50%'
    stroke-width='$StrokeWidth%'
    d='m 0 $($Amplitude/2) $(
        if ($variant -match 'cos(?:ine)?') {
            $($CosineWave * $frequency)
        } else {
            $($sineWave * $frequency)
        }
    )'>
$(
    if ($variant -match 'animated') {
        $steps =
            if ($variant -match 'cos(?:ine)?') {
                @(
                    "m 0 $($Amplitude/2) $($sineWave * $frequency)"
                    "m 0 $($Amplitude/2) $($CosineWave * $frequency)"
                    "m 0 $($Amplitude/2) $($sineWave * $frequency)"
                )
            } else {
                @(
                    "m 0 $($Amplitude/2) $($CosineWave * $frequency)"
                    "m 0 $($Amplitude/2) $($sineWave * $frequency)"
                    "m 0 $($Amplitude/2) $($CosineWave * $frequency)"
                )
            }
        
        "<animate attributeName='d' values='$(
            $steps -join ';'
        )' repeatCount='indefinite' dur='$(60/$bpm)s' attributeType='XML' />"
    }
)
</path>
$(
    if ($variant -notmatch 'nologo') {
        "<use href='#PoshWeb' y='$(50.0 - $h/2)%' height='$h%' fill='#224488' class='foreground-fill' />"    
    }
)
</svg>
"@
