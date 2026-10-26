<#
.SYNOPSIS
    Wave Linq Type Definition
.DESCRIPTION
    Gets the Type Definition for Wave.WaveLinq.
.NOTES
    This uses a number of script methods to generate a C# class.
#>

$ClassDefinition = @(    
    $methods = 'Arithmetic', 'Trigonometry', 'Encode', 'Decode', 'Envelope', 'WaveForm' -replace '$','.cs'
    foreach ($method in $methods) {
        if (-not $this.$method) { continue }
        "#region $($method -replace '\.cs$')"
        $this.$method.Invoke()        
        "#endregion $($method -replace '\.cs$')"
    }    
) -join ([Environment]::NewLine)

@"
namespace Wave {

    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.Management.Automation;

    public static class WaveLinq$(
        if ($DebugPreference -notin 'ignore', 'silentlyContinue') {
            Get-Random
        }
    ) {
$ClassDefinition
    }
}
"@

