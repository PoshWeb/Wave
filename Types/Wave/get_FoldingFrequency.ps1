<#
.SYNOPSIS
    Gets a Wave's Folding Frequency
.DESCRIPTION
    Gets the maximum frequency that waveform can encode without distortion.

    This is half of the sampling rate.
    
    It is commonly called the "folding frequency", 
    and technically known as the Nyquist Frequency.
.NOTES
    Imagine one second of audio drawn on a piece of graphing paper,
    with zero at the middle.

    If we folded it in half, we would have the complete 
    up cycle and down cycle of the wave.
.LINK
    https://en.wikipedia.org/wiki/Nyquist_frequency
#>
param()

$this.SampleRate/2
