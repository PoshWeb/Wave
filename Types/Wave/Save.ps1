<#
.SYNOPSIS
    Saves waves
.DESCRIPTION
    Saves a Wave File to disk.

    If no path is provided, will save to the temporary path.
#>
param([string]$Path)

# If no path is provided
if (-not $path) {
    # default to a subpath of local application data
    $path = [Environment]::GetFolderPath("LocalApplicationData"),
        'Wave',
            # and name the file using it's sha256 hash.
            "$($this.SHA256).wav" -join '/'    
}

# Get ready to get paths
$getUnresolvedPath =
    # (this line is a mouthful, and so we will separate it)
    $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath

# Loop over all unresolved paths
foreach ($unresolvedPath in $getUnresolvedPath.Invoke($path)) {
    # and create a file if they do not already exist
    $file = if (-not [IO.File]::Exists($unresolvedPath)) {
        New-Item -ItemType File -Path $unresolvedPath -Force
    } else {
        [IO.FileInfo]$unresolvedPath
    }
    # If that failed, continue
    if (-not $file) { continue }
    # Write the file bytes
    [IO.File]::WriteAllBytes($File.FullName, $this.ToArray())
    # and output the saved file.
    [IO.FileInfo]$file.FullName
}