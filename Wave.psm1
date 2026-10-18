#region Eponym

# Functions and scripts are interchangeable in PowerShell
# So we can make a small module using an eponym file.
# First we need to identify the module name 
$moduleName = $MyInvocation.MyCommand.Name -replace '\.psm1$'

# Once we have done this, we can look for an eponymous script: 
$eponym = 
    $ExecutionContext.SessionState.InvokeCommand.GetCommand((
        Join-Path $PSScriptRoot "$moduleName.ps1"
    ), 'ExternalScript')

# If we did not find one,
if (-not $eponym) {
    # warn and return.
    Write-Warning "Missing ./$moduleName.ps1"
    return
}

# We want to define two functions from this script

# One is the name of the script
# The other is the "verb" form of the script.

# Collect our list of verbs
$verbs = Get-Verb | 
    Sort-Object { $_.Verb.Length }, {$_.Verb } -Descending |
    Select-Object -ExpandProperty Verb
    
# and craft a regex to see if we start with the verb.
$startsWithVerb = "^(?>$(
    $verbs -join '|'
))"

# Our Exports are:
$exports = 
    $moduleName, # * The Eponym 
    $(
        # The `Verb-Noun` form
        if ($moduleName -match $startsWithVerb) {
            "$($matches.0)-$($moduleName -replace "$startsWithVerb\p{P}?")"
        } else {
            "Get-$($ModuleName -replace '\p{P}')"
        }
    )

# We can use the function provider to create functions in this scope.
foreach ($functionName in $exports) {
    # This allows us to dynamically set each export to by the eponym
    $ExecutionContext.SessionState.PSVariable.Set(
        "function:$functionName",
        $eponym.ScriptBlock
    )
}

# We also want to export any aliases
# and add support for argument completers.
$argumentCompleter = $null
$aliasExports = @(
    # walk over all of our attributes
    foreach ($attribute in $eponym.ScriptBlock.Attributes) {
        # and keep track of any argument completers we find.
        if ($attribute -is [ArgumentCompleter]) {
            $argumentCompleter = $attribute
        }
        # Then make our aliases
        foreach ($alias in $attribute.aliasNames) {
            # (unless the alias is already exported as a function)
            if ($alias -in $exports) { continue }
            $ExecutionContext.SessionState.PSVariable.Set(
                "alias:$alias", $moduleName
            )
            $alias
        }
    }
)

# If we had an argument completer
if ($argumentCompleter.ScriptBlock) {
    # now is the time to register it.

    # Argument completers need to be registered for each function
    foreach ($functionExport in $exports) {
        Register-ArgumentCompleter -CommandName $functionExport -ScriptBlock $argumentCompleter.ScriptBlock
    }

    # and alias
    foreach ($aliasExport in $aliasExports) {
        Register-ArgumentCompleter -CommandName $aliasExport -ScriptBlock $argumentCompleter.ScriptBlock
    }
}

# We will also be exporting our eponym as a variable
$ExecutionContext.SessionState.PSVariable.Set($moduleName, $eponym)

#region Additional Exports

$frequency = 
    $ExecutionContext.SessionState.InvokeCommand.GetCommand((
        Join-Path $PSScriptRoot "Frequency.ps1"
    ), 'ExternalScript')

$midinote =
    $ExecutionContext.SessionState.InvokeCommand.GetCommand((
        Join-Path $PSScriptRoot "MidiNote.ps1"
    ), 'ExternalScript')

${function:Frequency} = ${function:Get-Frequency} = $frequency.ScriptBlock
${function:MidiNote} = ${function:Get-MidiNote} = $midinote.ScriptBlock

$exports += "Get-Frequency","Frequency", "Get-MidiNote", "MidiNote"

$midi88Variables = @(
    'A0','As0','B0',
    'C1','Cs1','D1','Ds1','E1','F1','Fs1','G1','Gs1','A1','As1','B1',
    'C2','Cs2','D2','Ds2','E2','F2','Fs2','G2','Gs2','A2','As2','B2',
    'C3','Cs3','D3','Ds3','E3','F3','Fs3','G3','Gs3','A3','As3','B3',
    'C4','Cs4','D4','Ds4','E4','F4','Fs4','G4','Gs4','A4','As4','B4',
    'C5','Cs5','D5','Ds5','E5','F5','Fs5','G5','Gs5','A5','As5','B5',
    'C6','Cs6','D6','Ds6','E6','F6','Fs6','G6','Gs6','A6','As6','B6',
    'C7','Cs7','D7','Ds7','E7','F7','Fs7','G7','Gs7','A7','As7','B7',
    'C8'    
) # -replace '(?<octave>\d)Sharp', 's${octave}'

foreach ($n in 21..108) {    
    $n.pstypenames.add('MidiNote')
    $nf = $n.Frequency
    $VariableName = $midi88Variables[$n - 21]
    $ExecutionContext.SessionState.PSVariable.Set("$VariableName", $nf)    
}
#endregion Additional Exports

# All that's left to do is explicitly export just these functions.
Export-ModuleMember -Function $exports -Alias $aliasExports -Variable (@($moduleName) + $midi88Variables)
#endregion Eponym