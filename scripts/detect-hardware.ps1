[CmdletBinding()]
param(
    [string] $VivadoPath,
    [string] $HwServerUrl = 'localhost:3121',
    [string] $DevicePattern = 'xc2ve3858*'
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
$tcl = Join-Path $PSScriptRoot 'detect-hardware.tcl'

Write-Host "Using Vivado: $vivado"
Write-Host "Hardware server: $HwServerUrl"
& $vivado -mode batch -nolog -nojournal -notrace -source $tcl `
    -tclargs $HwServerUrl $DevicePattern

if ($LASTEXITCODE -ne 0) {
    throw "Vivado hardware detection failed with exit code $LASTEXITCODE."
}
