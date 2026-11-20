<#
.SYNOPSIS
    Wave.net Includes
.DESCRIPTION
    Parts of Wave are dynamically compiled.
    
    Each distinct class is written in a PowerShell script that outputs C#.

    This property indicates which scripts to include.
#>

@(
    'Frequency'
    'Math'
) -replace '$', '.cs'