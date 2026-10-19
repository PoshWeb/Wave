<#
.SYNOPSIS
    Mission Impossible
.DESCRIPTION
    The Mission Impossible Theme
.NOTES
    Adapted from https://github.com/vukasinterzic/AdminToys/blob/master/Misc/Get-ConsoleMusic.ps1
.LINK
    https://github.com/vukasinterzic/AdminToys/blob/master/Misc/Get-ConsoleMusic.ps1
#>

$mission = '
    [console]::beep(784,150) 
    [Threading.Thread]::Sleep(300) 
    [console]::beep(784,150) 
    [Threading.Thread]::Sleep(300) 
    [console]::beep(932,150) 
    [Threading.Thread]::Sleep(150) 
    [console]::beep(1047,150) 
    [Threading.Thread]::Sleep(150) 
    [console]::beep(784,150) 
    [Threading.Thread]::Sleep(300) 
    [console]::beep(784,150) 
    [Threading.Thread]::Sleep(300) 
    [console]::beep(699,150) 
    [Threading.Thread]::Sleep(150) 
    [console]::beep(740,150) 
    [Threading.Thread]::Sleep(150) 
    [console]::beep(784,150) 
    [Threading.Thread]::Sleep(300) 
    [console]::beep(784,150) 
    [Threading.Thread]::Sleep(300) 
    [console]::beep(932,150) 
    [Threading.Thread]::Sleep(150) 
    [console]::beep(1047,150) 
    [Threading.Thread]::Sleep(150) 
    [console]::beep(784,150) 
    [Threading.Thread]::Sleep(300) 
    [console]::beep(784,150) 
    [Threading.Thread]::Sleep(300) 
    [console]::beep(699,150) 
    [Threading.Thread]::Sleep(150) 
    [console]::beep(740,150) 
    [Threading.Thread]::Sleep(150) 
    [console]::beep(932,150) 
    [console]::beep(784,150) 
    [console]::beep(587,1200) 
    [Threading.Thread]::Sleep(75) 
    [console]::beep(932,150) 
    [console]::beep(784,150) 
    [console]::beep(554,1200) 
    [Threading.Thread]::Sleep(75) 
    [console]::beep(932,150) 
    [console]::beep(784,150) 
    [console]::beep(523,1200) 
    [Threading.Thread]::Sleep(150) 
    [console]::beep(466,150) 
    [console]::beep(523,150)
'

wave note $mission play