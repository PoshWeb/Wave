<#
.SYNOPSIS
    Gets a Wave's Hash
.DESCRIPTION
    Gets the SHA256 hash of a wave.
#>
[BitConverter]::ToString(
    [Security.Cryptography.SHA256]::Create().ComputeHash($this)
) -replace '-'
$null = $this.Seek('0', 'Begin')