<#
.SYNOPSIS
    Moves the wave 
.DESCRIPTION
    Moves the wave with any number of instrucitons.
.EXAMPLE
    $wave = wave 
    $wave.Go("square", 440)
    $wave.Go("play")
#>
param()

$currentWave = if ($this) { $this } else { wave }
# Unroll our arguments so we handle lists of lists
$ArgumentList = @($args | . {process { $_ }})

if (-not $ArgumentList) { return $currentWave }

$waveType = $(Get-TypeData -TypeName audio/wav)

filter waveUnit {
    $arg = $_
    if ($arg -isnot [string]) {
        return $arg
    }
    switch -regex ($arg) {        
        'hz$' {
            # Treat hertz as a float
            ($_ -replace 'hz$' -as [single])
            continue
        }
        'bpm$' {
            $bpm = $_ -replace 'bpm$' -as [single]
            if ($bpm) {
                [TimeSpan]::FromSeconds(60 / $bpm)
            } else {
                $_
            }            
        }
        default {
            if ($currentWave.NoteFrequency["$_"]) {
                $currentWave.NoteFrequency["$_"]
            } else {
                $_
            }            
        }
    }
}

if ($VerbosePreference -notin 'ignore','silentlyContinue') {
    Write-Verbose "wave Go`n`t$(
        @(foreach ($arg in $ArgumentList) {
            $arg
        }) -join "`n`t"
    )"
}

$helpfulKeywords = @(
    '?'
    '--help'
    'help'
    '/help'
    '/?'
)

filter getScriptHelp {
    $scriptBlock = $_
    $Name = $args -join ''
    $ExecutionContext.SessionState.PSVariable.Set("function:$Name",$scriptBlock)            
    if ($switches -is [Collections.IDictionary]) {
        if ($switches.Syntax) {
            Get-Command $Name -Syntax
        } else {
            Get-Help $Name @switches
        }                
    } else {
        Get-Help $Name
    }
    $ExecutionContext.SessionState.PSVariable.Remove("function:$Name")
}


# First we want to split each argument into words.
# This way, it is roughly the same if you say:
# * `wave 'forward 10'`
# * `wave forward 10`
# * `wave 'forward', 10`
$wordsAndArguments = @(foreach ($arg in $ArgumentList) {
    # If the argument is a string, and it starts with whitespace            
    if ($arg -is [string]) {
        #if ($arg -match '^[\r\n\s]+') {
            # $arg -split '\s{1,}'
        # } else {
            $arg
        #}
    } else {
        # otherwise, leave the argument alone.
        $arg
    }
})

# If any brackets are used, we want to balance them all now, and error if they appear unbalanced.        
# Since we want to know the exact index, we walk thru matches
$depth = 0
# and keep track of when it became unbalanced.
$unbalancedAt = $null
foreach ($match in [Regex]::Matches(
        (@(
            foreach ($arg in $wordsAndArguments) {
                if ($arg -is [string]) {
                    $arg
                }
            }
        ) -join ' '), '[\[\]]'
    )
) {
    # To do this, we increment or decrement depth for brackets `[]`
    if ($match.Value -eq '[') { $depth++ }
    if ($match.Value -eq ']') { $depth-- }
    # and, if the depth is ever negative, we are unbalanced.
    if ($depth -lt 0) {
        $unbalancedAt = $match; break
    }
}

# If the depth is still positive when we are done,
# we are also unbalanced
if ($depth -gt 0) {
    # and we can consider our last bracket the point that needs to be balanced
    $unbalancedAt = $match
}

# If we are unbalanced,
if ($unbalancedAt) {
    # write an error
    Write-Error -Message "Unbalanced at index $($match.Index)
$(
# (try to make it a nice error by pointing out the match)    
$str = $match.Result('$_')
if ($match.Index -ge 1) {
$str.Substring(0, $match.Index - 1)
if ($match.Index -lt ($str.Length - 1)) {
    '-->'
}        
}
$match.Value
'<--'
if ($match.Index -lt ($str.Length - 1)) {
$str.Substring($match.Index + 1)
}           
) - $depth brackets off" # and by letting people know the depth difference.
    return
}        

# Now that we have a series of balanced words, we can process them.
# We want to keep track of the current member, 
# and continue to the next word until we find a member name.        
$currentMember = $null
# We want to output the wave by default, in case we were called with no parameters.
$outputWave = $true

$progress = @{id=Get-Random;activity='wave 〜'; status=' '}

# To do this in one pass, we will iterate through the words and arguments.
# We use an indexed loop so we can skip past claimed arguments.
for ($argIndex =0; $argIndex -lt $wordsAndArguments.Length; $argIndex++) {
    
    $progress.PercentComplete = $argIndex * 100 / $wordsAndArguments.Length
    $arg = $wordsAndArguments[$argIndex]
    if ($arg.pstypenames -contains 'audio/wav') {
        $currentWave.Data += $arg.Data
        continue 
    }
    # If the argument is not in the member names list, we can complain about it.
    if ($arg -is [string]) {
        $progress.status = "$($arg -replace '~','rest') "
        Write-Progress @progress
        if ($arg -notin $waveType.Members.Keys) {    
            if ($arg -match 'bpm$') {
                $currentWave.BPM = $arg -replace 'bpm$'
                continue
            }
            elseif ($arg -eq '~') {
                $currentWave.Data += $currentWave.Silence()
                continue
            } elseif ($currentWave.NoteFrequency[$arg]) {
                $currentWave.Data += $currentWave.Tone($currentWave.NoteFrequency[$arg])
                continue
            }
            elseif ($currentWave.NoteFrequency["${arg}4"]) {
                $currentWave.Data += $currentWave.Tone($currentWave.NoteFrequency["${arg}4"])
                continue
            }            
            elseif (
                # (we might not want to, if it starts with a bracket)
                -not $currentMember -and $arg -is [string] -and
                "$arg".Trim() -and $arg -notmatch '^\['                 
            ) {            
                Write-Warning "Unknown command '$arg'."                    
                continue
            }
        }        
    }
    
    
    # If we have a current member, we can invoke it or get it.
    $currentMember = $arg
    $memberInfo = $waveType.Members[$currentMember]

    if (-not $memberInfo) {
        $memberInfo = foreach ($typeInfo in $waveTypes) {
            if ($typeInfo.Members -is [Collections.IDictionary] -and $typeInfo.Members[$currentMember]) {
                $typeInfo; break
            }
            if ($typeInfo::$currentMember) {
                $typeInfo::$currentMember
                break
            }
        }
    }

    # If it's an alias
    if ($memberInfo.ReferencedMemberName) {
        # try to resolve it.
        $currentMember = $memberInfo.ReferencedMemberName
        $memberInfo = $waveType.Members[$currentMember]
    }
    
    # We can also begin looking for arguments, as long as they are not bracketed.
    $bracketDepth = 0             
    for (
        # Let's start at the next index.
        $methodArgIndex = $argIndex + 1; 
        # and continue until we reach the end of the words and arguments,
        $methodArgIndex -lt $wordsAndArguments.Length;
        $methodArgIndex++
    ) {
        # Count our brackets
        if ($wordsAndArguments[$methodArgIndex] -is [string]) {
            $brackets = $wordsAndArguments[$methodArgIndex] -replace '[^\[\]]'
            foreach ($bracket in $brackets.ToCharArray()) {
                if ("$bracket" -eq '[') { $bracketDepth++ }
                if ("$bracket" -eq ']') { $bracketDepth-- } 
            }            
            # If the next word is a method name, and our brackets are balanced
            if ($wordsAndArguments[$methodArgIndex] -in 
                $waveType.Members.Keys -and -not $bracketDepth) {
                # break out of the loop.
                break
            }
        }
    }
    # Now we know how far we had to look to get to the next member name.

    # And we can determine if we have any parameters.
    # (it is important that we always force any parameters into an array)
    $HelpWanted = $false
    $switches = [Ordered]@{}

    $argList = 
        @(if ($methodArgIndex -ne ($argIndex + 1)) {
            # We only want to remove one pair of brackets
            $bracketCount = 0
            foreach ($word in $wordsAndArguments[($argIndex + 1)..($methodArgIndex - 1)]) {
                if ($word -in $helpfulKeywords) {
                    $HelpWanted = $true
                    continue
                }
                if ($HelpWanted -and 
                    $word -is [string] -and 
                    $word -in 'example', 'examples', 'parameter','parameters','online'
                ) {
                    if ($word -in 'example','examples') {
                        $switches['Examples'] = $true
                    }
                    if ($word -in 'parameter','parameters') {
                        $switches['Parameter'] = '*'
                    }
                    if ($word -eq 'online') {
                        $switches['Online'] = $true
                    }
                    continue
                }
                if ($word -is [string] -and $word -match '^[-/]+?[\D-[\.]]') {
                    $switchInfo = $word -replace '^[-/]+'
                    $switchName, $switchValue = $switchInfo -split ':', 2
                    if ($null -eq ($switchName -as [double])) {
                        $switches[$switchName] =
                            if ($switchValue) {
                                $switchValue
                            } else {
                                $true
                            }
                        continue
                    }                            
                }
                
                # If the word started with a bracket, and it's our first bracket
                if ($word -is [string] -and $word.StartsWith('[') -and -not $bracketCount) {
                    $word = $word -replace '^\[' # remove it
                    $bracketCount++ # and increment our bracket counter.
                    if (-not $word) {
                        continue
                    }
                }
                # If the word ended with a bracket, and we have only one bracket
                if ($word -is [string] -and $word.EndsWith(']') -and $bracketCount -eq 1) {
                    # remove the closing bracket
                    $word = $word -replace '\]$'
                    # and increment our removal counter
                    $bracketCount++
                    if (-not $word) {
                        continue
                    }
                }
                $word # output the word into the array.
            }
            $argIndex = $methodArgIndex - 1
        })
                                        
    # Now we want to get the output from the step.
    $stepOutput =
        if (
            # If the member is a method, let's invoke it.
            $memberInfo -is [Management.Automation.Runspaces.ScriptMethodData] -or 
            $memberInfo -is [Management.Automation.PSMethod]
        ) {                    
            # If we have arguments,
            if ($argList) {                
                # and a script method
                if ($memberInfo -is [Management.Automation.Runspaces.ScriptMethodData]) {
                    # Check to see if we want help.
                    if ($HelpWanted) {
                        # If we do, get some help.
                        $memberInfo.Script | getScriptHelp $memberInfo.Name
                    } else {
                        # Otherwise, set `$this` to the current wave
                        $this = $currentWave                        
                        $argList = @($argList | waveUnit)
                        # and call the script, splatting positional parameters
                        # (this allows more complex binding, like ValueFromRemainingArguments).
                        . $currentWave.$currentMember.Script @argList
                    }                            
                } 
                elseif ($currentWave.$currentMember.Invoke) {
                    $currentWave.$currentMember.Invoke($argList)
                } elseif ($memberInfo.Invoke) {
                    $memberInfo.Invoke($argList)
                } elseif ($memberInfo -is [ValueType]) {
                    $memberInfo
                }
            }
            # If we don't have any arguments, but are still dealing with a method
            else {
                # If we want help,
                if ($HelpWanted -and $memberInfo.Script) {
                    # get some help.
                    $memberInfo.Script | getScriptHelp $memberInfo.Name                            
                } else {
                    # otherwise, invoke the method with no parameters.
                    $currentWave.$currentMember.Invoke()
                }
            }                    
        } else {
            # If the member is a property, we can get it or set it.

            # If we have any arguments,
            if ($argList.Length) {
                # and we want help
                if ($HelpWanted -and $memberInfo.SetScriptBlock) {                            
                    # get help about the set.
                    $memberInfo.SetScriptBlock | getScriptHelp $memberInfo.Name                            
                } else {
                    # Otherwise, check to see if the arguments are strongly typed.
                    if ($memberInfo -is [Management.Automation.Runspaces.ScriptPropertyData]) {
                        $desiredType = $memberInfo.SetScriptBlock.Ast.ParamBlock.Parameters.StaticType
                        if ($desiredType -is [Type] -and
                            $argList.Length -eq 1 -and
                            $null -ne ($argList[0] -as $desiredType)) {
                            $argList = $argList[0] -as $desiredType
                        }                            
                    }
                    
                    # And try to set the property.
                    try {
                        $currentWave.$currentMember = $argList
                    } catch {
                        # If that fails,
                        $ex  = $_                        
                        # If we are running with a cmdlet,
                        if ($PSCmdlet) {                            
                            # use .WriteError for a cleaner error.                            
                            $PSCmdlet.WriteError($ex)
                        } else {
                            # otherwise, use Write-Error.
                            Write-Error -ErrorRecord $ex
                        }                        
                    }
                }
                
            } else {
                # otherwise, lets get the property
                # If we are getting a script and we want help
                if ($memberInfo.GetScriptBlock -and $HelpWanted) {
                    # momentarily turn that script into a function
                    $memberInfo.GetScriptBlock | getScriptHelp $memberInfo.Name                            
                }
                elseif ($null -ne $currentWave.$currentMember) {
                    $currentWave.$currentMember
                } elseif ($memberInfo -is [ValueType]) {
                    $memberInfo
                }                        
            }
        }

    # If the output is not a wave object, we can output it.
    # NOTE: This may lead to multiple types of output in the pipeline.
    # Luckily, this should be one of the few cases where this does not annoy too much.
    # Properties being returned will largely be strings or numbers, and these will always output directly.
    if ($null -ne $stepOutput -and -not ($stepOutput.pstypenames -eq 'wave')) {

        if ($stepOutput -as [byte[]]) {
            $currentWave.Data += $stepOutput
            $outputWave = $true
        } else {
            # Output the step
            $stepOutput
            # and set the output wave to false.
            $outputWave = $false
        }

        
    } elseif ($null -ne $stepOutput) {
        # Set the current wave to the step output.
        $currentWave = $stepOutput
        # and output it later (presumably).
        $outputWave = $true
    }
}

$progress.Remove('PercentComplete')
$progress.Completed = $true
Write-Progress @progress

# If the last members returned a wave object, we can output it.
if ($outputWave) {
    return $currentWave
}