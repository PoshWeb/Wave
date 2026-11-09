<#
.SYNOPSIS
    Wave Linq Type Definition
.DESCRIPTION
    Gets the Type Definition for Wave.WaveLinq.
.NOTES
    This uses a number of script methods to generate a C# class.

    This uses the "type coalescing" technique, 
    where a complete type is built by joining the output of 
    several dynamic script methods.

    This avoids repeating code and condenses the implementation.
.EXAMPLE
    Add-Type -TypeDefinition (
        [PSCustomObject]@{PSTypename='WaveLinq'}
    ).TypeDefinition -PassThru
#>

$ClassDefinition = @(        
    $methods = 'Arithmetic',
        'Calculus', 
        'Geometry',
        'Trigonometry',
        'Encode', 
        'Decode', 
        'Envelope', 
        'Vector', 
        'Frequency', 
        'WaveForm',
        'WaveOps' -replace '$','.cs'
        
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
    using System.Numerics;
    using System.IO;
    using System.Text;

    public static class WaveLinq$(
        if ($DebugPreference -notin 'ignore', 'silentlyContinue') {
            Get-Random
        }
    ) {
$ClassDefinition
    }
}
"@

