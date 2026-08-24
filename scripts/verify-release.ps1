[CmdletBinding()]
param(
    [string] $ReleaseRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $ReleaseRoot) {
    $ReleaseRoot = Join-Path $PSScriptRoot '..\vendor\iwave\v25.2\FPGA'
}
$ReleaseRoot = [IO.Path]::GetFullPath($ReleaseRoot)

$expected = [ordered]@{
    'system_boot.pdi' = 'F0A8C4C5D6337F9398EF2704A82B565E2AB84F8A55C61DB38C9255283E1FCF80'
    'system_pld.pdi'  = '26B1EEF4E599C0C266628780D6149587A6F3E8E8B9DC51EE4777A6F41EC1C617'
    'system.xsa'      = '02A8B45B42BAB4998E95A4237F69E8BCDDC825573CD71C1145B1E8737026A77F'
}

$results = foreach ($entry in $expected.GetEnumerator()) {
    $path = Join-Path $ReleaseRoot $entry.Key
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        [pscustomobject]@{
            File = $entry.Key
            Status = 'MISSING'
            SHA256 = $null
        }
        continue
    }

    $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash
    [pscustomobject]@{
        File = $entry.Key
        Status = if ($hash -eq $entry.Value) { 'MATCH' } else { 'DIFFERENT' }
        SHA256 = $hash
    }
}

$results | Format-Table -AutoSize
if ($results.Status -contains 'MISSING' -or
    $results.Status -contains 'DIFFERENT') {
    throw "Release verification failed for $ReleaseRoot"
}

Write-Host 'All artifacts match the tested iWave V25.2 REL1.0 release.'
