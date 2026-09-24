#requires -Module PSDevOps
Import-BuildStep -SourcePath (
    Join-Path $PSScriptRoot 'GitHub'
) -BuildSystem GitHubAction

$PSScriptRoot | Split-Path | Push-Location

New-GitHubAction -Name "MakeWaves" -Description 'Make Waves with PowerShell' -Action WaveAction -Icon terminal -OutputPath .\action.yml

Pop-Location