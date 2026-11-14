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


#region Verbs
$VerbsFolder = Get-ChildItem -Directory -Path $PSScriptRoot
if ($VerbsFolder) {
    foreach ($verbFile in $VerbsFolder.GetFiles()) {
        if ($verbFile.Name -notmatch "^$StartsWithVerb\.ps1$") { continue }
        $VerbScript = $ExecutionContext.SessionState.InvokeCommand.GetCommand(
            $verbFile.FullName,'ExternalScript'
        )

        $verb = $VerbFile.Name -replace '\.ps1$'
        $verb = $verb.Substring(0,1).ToUpper() + $verb.Substring(1)
        $verbFunctionName = "$verb-$ModuleName"
        $ExecutionContext.SessionState.PSVariable.Set(
            "function:$verbFunctionName",
            $VerbScript.ScriptBlock
        )

        $exports += $verbFunctionName
    }
}
#endregion Verbs


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

$waveLinq = [PSCustomObject]@{PSTypeName='WaveLinq'}
try {
    $addTypeSplat = [Ordered]@{
        TypeDefinition = $waveLinq.TypeDefinition        
    }
    if ($PSVersionTable.PSVersion -lt 6.0) {
        $addTypeSplat.ReferencedAssemblies = $waveLinq.Reference
    }
    Add-Type @addTypeSplat -ErrorAction SilentlyContinue -ErrorVariable compilationErrors
} catch {
    Write-Warning "$($_)"
    foreach ($err in $compilationErrors) {
        if ($err.Exception -and $err.Exception.GetType().FullName -ne
            'System.Management.Automation.CmdletInvocationExcepton'
        ) {
            Write-Warning "$err"
        }        
    }
}
#endregion Additional Exports

#region Startup
$waveFolder = [Environment]::GetfolderPath('LocalApplicationData') | Get-ChildItem -Filter Wave
if ($waveFolder) {
    $waveFiles = $waveFolder.GetFiles()
    [long]$totalSize = 0
    foreach ($waveFile in $waveFiles) {
        $totalSize += $waveFile.Length
    }
    if ($totalSize -gt 128mb) {
        $gigs = [Math]::Round($totalSize/1gb, 4)
        $nudge = @(
            'Needs Clean','Clear it out',
            'Time to clean up', 'Do you really need these?'
            'Wave files are big', ':-('
            'Disk space is finite'
        ) | Get-Random
        $fix = [Environment]::NewLine + "Get-ChildItem -Path '$($waveFolder.FullName -replace "'","''")' | Remove-Item"
        Write-Warning "$($gigs)gb waves in $($waveFolder.FullName) $nudge $fix"
    }

    $callstack = @(Get-PSCallstack)

    $myPrivateData = $MyInvocation.MyCommand.ScriptBlock.Module.PrivateData

    if (
        ($callstack.Length -le 2) -and 
        $host.UI.RawUI.BufferSize.Width -and
        ($PSVersionTable.PSVersion.Major -ge 6) -and
        ($myPrivateData.Tips -or $myPrivateData.Tricks) 
    ) {
        # Banner

        [Console]::WriteLine(
@(
foreach ($row in 1,0,-1) {        
    @(foreach ($column in 0..($host.UI.RawUI.BufferSize.Width - 3)) {
        if ([Math]::Round(
            [Math]::Sin($column * [Math]::PI/2)
        ) -eq $row) {
            '*'
        } else {
            ' '
        }
    }) -join ''
}
) -join [Environment]::NewLine            
        )

        $tipsAndTricks = @(
            $myPrivateData.Tips
            $myPrivateData.Tricks 
        )
        
        if ($tipsAndTricks) {
            $tipsAndTricks | 
                Get-Random | 
                ConvertFrom-Markdown -AsVT100EncodedString |
                Select-OBject -ExpandProperty  VT100EncodedString | 
                Out-host
        }
        
    }
}
#endregion Startup

# All that's left to do is explicitly export just these functions.
Export-ModuleMember -Function $exports -Alias $aliasExports -Variable (@($moduleName) + $midi88Variables)
#endregion Eponym