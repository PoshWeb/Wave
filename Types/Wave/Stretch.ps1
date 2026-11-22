<#
.SYNOPSIS
    Wave Stretch
.DESCRIPTION
    Stretches a Wave to fit a duration.
#>
param(
# Our stretch point
# This can be:
# * Any object with a `[TimeSpan] .Duration`
# * A TimeSpan
# * A double of total seconds
$To
)

# Initialize time to zer0
[TimeSpan]$time = [TimeSpan]::FromSeconds(0)

# If the `To` has a `[TimeSpan]` `.Duration`
if ($to.Duration -is [TimeSpan]) {
    # use that
    $time = $to.Duration
}
elseif (
    # If `To` was a `[TimeSpan]`
    $to -is [TimeSpan]
) {
    # use that
    $time = $to
} elseif (
    # If `to` can be a double
    $null -ne ($to -as [double])
) {
    # use that as total seconds.
    $time = [TimeSpan]::FromSeconds($to)
}

# This is the new wave
$newWave = $this
if (-not $newWave) { $newWave = wave }

# If there is no time in or no duration
if (-not ($Time.TotalSeconds) -or -not ($newWave.Duration.TotalSeconds)) {
    # return the wave.
    return $newWave
}

# Adjust our speed by the ratio between times.
return $newWave.Speed(
    $NewWave.Duration.TotalSeconds/$time.TotalSeconds
)