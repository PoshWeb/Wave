<#
.SYNOPSIS
    Wave logo
.DESCRIPTION
    The Logo for Wave.
.NOTES
    Perhaps unsurprisingly, the logo for Wave is a wave.
.EXAMPLE
    .\Wave.svg.ps1 > .\Wave-Animated.svg
.EXAMPLE
    .\Wave.svg.ps1 -Variant '' > .\Wave.svg
#>
param(
$Variant = 'animated',

[double]
$BPM = 8
)

$psChevron = '<symbol id="psChevron" viewBox="0 0 100 100">
    <polygon points="40,20 45,20 60,50 35,80 32.5,80 55,50"/>
</symbol>'


$h = 4.2
@"
<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 200 200'>
$psChevron
<use href='#psChevron' y='$(50.0 - $h/2)%' height='$h%' fill='#4488ff' class='foreground-fill' />
<path 
    stroke='#224488' 
    fill ='#4488ff' 
    class='foreground-fill background-stroke'
    transform-origin='50% 50%'
    d='m 0 0 m 0 100 c 0 -100 200 100 200 0'>
$(
    if ($variant -match 'animated') {
        $steps = @(
            "m 0 0 m 0 100 c 0 -100 200 100 200 0"
            "m 0 0 m 0 100 c 0 100 200 -100 200 0"
            "m 0 0   m 0 100 c 0 -100 200 100 200 0"
        )
        "<animate attributeName='d' values='$(
            $steps -join ';'
        )' repeatCount='indefinite' dur='$(60/$bpm)s' attributeType='XML' />"
    }
)
</path>
</svg>
"@
