#region Prepare Exports
$exports = [Ordered]@{
    Function = @()
    Variable = @($MyInvocation.MyCommand.ScriptBlock.Module.Name)
    Alias = @()
}

#endregion Prepare Exports
#region Compilation
$waveLinq = [PSCustomObject]@{PSTypeName='WaveLinq'}
$waveDotNet = [PSCustomObject]@{PSTypeName='Wave.net'}
try {
    $addTypeSplat = [Ordered]@{
        TypeDefinition = @(
            $waveLinq.TypeDefinition        
            if ($waveDotNet.'Frequency.cs'.Invoke) {
                $waveDotNet.'Frequency.cs'()
            }
        ) -join [Environment]::NewLine
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
#endregion Compilation

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
$exports.Function += $moduleName # * The Eponym 
$exports.Function += $(
    # The `Verb-Noun` form
    if ($moduleName -match $startsWithVerb) {
        "$($matches.0)-$($moduleName -replace "$startsWithVerb\p{P}?")"
    } else {
        "Get-$($ModuleName -replace '\p{P}')"
    }
)

# We can use the function provider to create functions in this scope.
foreach ($functionName in $exports.Function) {
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

        $exports.Function += $verbFunctionName
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
            if ($alias -in $exports.Alias) { continue }
            $ExecutionContext.SessionState.PSVariable.Set(
                "alias:$alias", $moduleName
            )
            $exports.Alias += $alias 
            $alias
        }
    }
)

# If we had an argument completer
if ($argumentCompleter.ScriptBlock) {
    # now is the time to register it.

    # Argument completers need to be registered for each function
    foreach ($functionExport in $exports.Function) {
        Register-ArgumentCompleter -CommandName $functionExport -ScriptBlock $argumentCompleter.ScriptBlock
    }

    # and alias
    foreach ($aliasExport in $aliasExports.Alias) {
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

$exports.Function += "Get-Frequency","Frequency"

if ('Wave.Frequency' -as [type]) {
    $A0 = [Wave.Frequency]27.5
    $exports.variable += @(
        foreach ($n in 0..87) {
            $f = $A0 -shr $n
            $ExecutionContext.SessionState.PSVariable.Set($f.Letter,$f)
            $f.Letter
        }
    )
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
        ($IsMacOS -or $IsLinux -or $env:WT_SESSION_ID) -and
        $callstack.Length -le 2 -and
        $host.UI.RawUI.BufferSize.Width
    ) {
        #region Banner
        $waveText = '◜◝◟◞'
        $Offset = Get-Random -Maximum $waveText.Length
        if ($Offset) {
            $Offset = ($Offset -as [int]) * -1
            [Console]::Write($waveText[$Offset..-1] -join '')
        }
                                            
        [Console]::Write(
            @(                    
                $waveText * (Get-Random -Minimum 4 -Maximum 32)
            ) -join ''            
        )
    
        [Console]::WriteLine()
        #endregion Banner

        #region Tips And Tricks
        if (
            ($PSVersionTable.PSVersion.Major -ge 6.0) -and
            ($myPrivateData.Tips -or $myPrivateData.Tricks) 
        ) {
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
        #endregion Tips And Tricks
    }    
}
#endregion Startup

# All that's left to do is explicitly export just these functions.
Export-ModuleMember @exports
#endregion Eponym