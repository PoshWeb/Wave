<#
.SYNOPSIS
    Wave logo
.DESCRIPTION
    The Logo for Wave.
.NOTES
    Perhaps unsurprisingly, the logo for Wave is a wave.
.EXAMPLE
    .\Wave.svg.ps1 -Variant Animated > .\WaveAnimated.svg
.EXAMPLE
    .\Wave.svg.ps1 > .\Wave.svg
#>
param(
# The variant of the design.
$Variant = '',

# The frequency used for the wave.
[double]
$Frequency = 20,

# The rate at which the wave is animated.
[double]
$BPM = 8
)

$poshWeb = $(.\PoshWeb.svg.ps1 -Variant $Variant) -as [xml]
$poshWebSymbol = "<symbol id='PoshWeb' viewBox='$($poshWeb.svg.viewBox)'>$(
    $poshWeb.svg.InnerXml
)</symbol>"

$wavePath = "c 1 -2 1 2 2 0"
$antiWavePath = ' c 1 2 1 -2 2 0'

$h = 50
@"
<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 $($frequency * 2) 2'>
$(
    if ($variant -match 'animated') {
        $poshWebSymbol
    } else {
        $poshWebSymbol
    }
)
<path 
    stroke='#4488ff' 
    fill ='transparent' 
    class='foreground-fill foreground-stroke'
    transform-origin='50% 50%'
    stroke-width='0.1%'
    d='m 0 1 $($wavePath * $frequency)'>
$(
    if ($variant -match 'animated') {
        $steps = @(
            "m 0 1 $($wavePath * $frequency)"
            "m 0 1 $($antiWavePath * $frequency)"
            "m 0 1 $($wavePath * $frequency)"
        )
        "<animate attributeName='d' values='$(
            $steps -join ';'
        )' repeatCount='indefinite' dur='$(60/$bpm)s' attributeType='XML' />"
    }
)
</path>
$(    
    "<use href='#PoshWeb' y='$(50.0 - $h/2)%' height='$h%' fill='#224488' class='foreground-fill' />"    
)
</svg>
"@
