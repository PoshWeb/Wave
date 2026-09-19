$sampleRate = $this.SampleRate

if (-not $sampleRate) { return [TimeSpan]::FromSeconds(0) }

if ($sampleRate) {
    [TimeSpan]::FromSeconds(
        (1 / $this.SampleRate)
    )
}