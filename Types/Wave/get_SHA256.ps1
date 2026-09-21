[BitConverter]::ToString(
    [Security.Cryptography.SHA256]::Create().ComputeHash($this)
) -replace '-'
$rev.Position = 0