[CmdletBinding()]
param(
    [string] $VivadoPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-VivadoPath {
    param([string] $RequestedPath)

    if ($RequestedPath) {
        if (-not (Test-Path -LiteralPath $RequestedPath -PathType Leaf)) {
            throw "Vivado launcher not found: $RequestedPath"
        }
        return (Resolve-Path -LiteralPath $RequestedPath).Path
    }

    $command = Get-Command vivado.bat -ErrorAction SilentlyContinue
    if (-not $command) {
        $command = Get-Command vivado.exe -ErrorAction SilentlyContinue
    }
    if ($command) {
        return $command.Source
    }

    $candidates = @(
        'V:\2025.2\Vivado\bin\vivado.bat',
        'C:\Xilinx\Vivado\2025.2\bin\vivado.bat',
        'C:\AMDDesignTools\Vivado\2025.2\bin\vivado.bat'
    )
    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    throw 'Vivado 2025.2 was not found. Pass -VivadoPath explicitly.'
}

$vivado = Resolve-VivadoPath -RequestedPath $VivadoPath
$tcl = Join-Path $PSScriptRoot 'simulate.tcl'
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$simulationDirectory = Join-Path ([IO.Path]::GetTempPath()) `
    ('alpaca-fpga-sim-' + [guid]::NewGuid().ToString('N'))
$null = New-Item -ItemType Directory -Path $simulationDirectory

Write-Host "Using Vivado: $vivado"
try {
    & $vivado -mode batch -nolog -nojournal -notrace -source $tcl `
        -tclargs $repositoryRoot $simulationDirectory

    if ($LASTEXITCODE -ne 0) {
        throw "Vivado simulation failed with exit code $LASTEXITCODE."
    }
} finally {
    $resolvedSimulationDirectory = [IO.Path]::GetFullPath($simulationDirectory)
    $resolvedTempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
    if (-not $resolvedSimulationDirectory.StartsWith(
        $resolvedTempRoot,
        [StringComparison]::OrdinalIgnoreCase
    ) -or (Split-Path $resolvedSimulationDirectory -Leaf) -notmatch
        '^alpaca-fpga-sim-[0-9a-f]{32}$') {
        throw "Refusing to remove unexpected path: $resolvedSimulationDirectory"
    }
    if (Test-Path -LiteralPath $resolvedSimulationDirectory) {
        Remove-Item -LiteralPath $resolvedSimulationDirectory -Recurse -Force
    }
}
