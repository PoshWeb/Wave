<#
.SYNOPSIS
    Gets System Sounds
.DESCRIPTION
    Gets System Sounds.
    
    Returns files on MacOS and Linux, and Registry Keys on Windows.
.NOTES
    |Operating System|Sound Location|
    |-|-|
    |Linux|`/usr/share/sounds`|
    |MacOS|`/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/`|
    |Windows|`HKCU:\AppEvents\Schemes\Apps`|
#>
if ($IsMacOS) {
    Get-ChildItem "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/" -Recurse -File
}
elseif ($IsLinux) {
    Get-ChildItem "/usr/share/sounds" -Recurse -File
}
else {
    Get-ChildItem -Path HKCU:\AppEvents\Schemes\Apps -Recurse   
}