[CmdletBinding()]
param(
    [string] $PdiPath,
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

if (-not $PdiPath) {
    $PdiPath = Join-Path $PSScriptRoot `
        '..\vendor\iwave\v25.2\FPGA\system_pld.pdi'
}
if (-not (Test-Path -LiteralPath $PdiPath -PathType Leaf)) {
    throw "PL PDI not found: $PdiPath"
}
$resolvedPdi = (Resolve-Path -LiteralPath $PdiPath).Path
if ([IO.Path]::GetExtension($resolvedPdi) -ne '.pdi') {
    throw "Expected a .pdi file: $resolvedPdi"
}

$knownHash = '26B1EEF4E599C0C266628780D6149587A6F3E8E8B9DC51EE4777A6F41EC1C617'
$actualHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $resolvedPdi).Hash
if ($actualHash -eq $knownHash) {
    Write-Host 'PDI matches the tested iWave V25.2 REL1.0 system_pld.pdi.'
} else {
    Write-Warning "PDI is not the known vendor smoke-test image. SHA256: $actualHash"
}

$vivado = Resolve-VivadoPath -RequestedPath $VivadoPath
$tcl = Join-Path $PSScriptRoot 'program-pl.tcl'

Write-Host "Using Vivado: $vivado"
Write-Host "Programming volatile PL image: $resolvedPdi"
Write-Host 'No OSPI, eMMC, configuration-memory, or eFUSE write is requested.'
& $vivado -mode batch -nolog -nojournal -notrace -source $tcl `
    -tclargs $resolvedPdi $HwServerUrl $DevicePattern

if ($LASTEXITCODE -ne 0) {
    throw "Vivado PL programming failed with exit code $LASTEXITCODE."
}
