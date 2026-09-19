<#
.SYNOPSIS
    Sets Wave Data
.DESCRIPTION
    Sets the PCM data in a wave.
.LINK
    https://en.wikipedia.org/wiki/Pulse-code_modulation
#>
param(
# The Pulse Code Modulation wave data.
[byte[]]$data
)

if (-not ($this.CanSeek -and $this.CanWrite)) {
    throw "Must be able to seek and write a stream to change the wave"
}

# If we have no data start
if (-not $this.'#data.start') {
    # read chunks
    $null = $this.Chunk
    # If we still have no data start, return.
    if (-not $this.'#data.start') {
        return
    }
}

# Seek to our data start plus 4
$this.Position = $this.'#data.start' + 4
# and prepare a writer
$writer = [IO.BinaryWriter]::new($this)
# Write our new data length
$writer.Write([uint32]$data.Length)
# then write our data
$this.Write($data, 0, $data.Length)
# $writer.Write($data)

# Then update our data chunk.
$this.'#data' = $data

# and seek to near the start of the file.
$this.Position = 4
# Then write our stream length, minus 8 bytes
$writer.Write([uint32]($this.Length - 8))

# and set our position back to the start.
$this.Position = 0

$this | Add-Member NoteProperty '#Samples' $null -Force