<#
.SYNOPSIS
    Gets Waves from a Pool
.DESCRIPTION
    Gets one or more Wave files from a wave pool
#>
param(
[string]
$Name
)

if (-not $this) { return }

$base = $this._base
$pattern  = [Regex]::Escape($name)
$wavePool = Get-TypeData -TypeName WavePool -ErrorAction Ignore

# If the cache is uninitialized
if (-not $wavePool.Members.WaveCache) {
    # Create it
    Update-TypeData -TypeName WavePool -MemberName "WaveCache" -MemberType NoteProperty -Value (
        [Ordered]@{}
    ) -Force
}

# and get the session cache.
$waveCache = $this.WaveCache

if ($waveCache[$Name]) {
    return $waveCache[$name]
}

if ($this.$Name) {
    $cacheKey = "$Base" + "#$name"
    if (-not $waveCache[$cacheKey]) {
        $waveCache[$cacheKey] = wave -Url @(
            foreach ($value in $this.$Name) {        
                "$base" + $value
            }
        )
    }
    $waveCache[$cacheKey]
} elseif ($this._base) {
    foreach ($prop in $this.psobject.properties) {
        if ($prop -isnot [Management.Automation.PSNoteProperty]) {            
            continue
        }
        foreach ($value in $prop.Value) {
            if (($value -is [string]) -and ($value -match $pattern)) {
                $cacheKey = "$base" + $value
                if (-not $waveCache[$cacheKey]) {
                    $waveCache[$cacheKey] = wave -Url ("$base" + $value)
                }

                $waveCache[$cacheKey]
            }
        }
    }
}