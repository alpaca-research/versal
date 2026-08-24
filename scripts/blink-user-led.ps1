[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $Port,

    [ValidateSet('D10', 'D8')]
    [string] $Led = 'D10',

    [ValidateRange(1, 1000)]
    [int] $Cycles = 10,

    [ValidateRange(50, 10000)]
    [int] $HalfPeriodMilliseconds = 500
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$gpio = if ($Led -eq 'D10') { 544 } else { 545 }
$halfPeriod = ($HalfPeriodMilliseconds / 1000.0).ToString(
    '0.###',
    [Globalization.CultureInfo]::InvariantCulture
)
$readyMarker = '__ALPACA_UART_READY__'
$doneMarker = '__ALPACA_BLINK_DONE__'

$serial = [IO.Ports.SerialPort]::new(
    $Port,
    115200,
    [IO.Ports.Parity]::None,
    8,
    [IO.Ports.StopBits]::One
)
$serial.Handshake = [IO.Ports.Handshake]::None
$serial.ReadTimeout = 1000
$serial.WriteTimeout = 1000
$serial.NewLine = "`r"

try {
    $serial.Open()
    Start-Sleep -Milliseconds 200
    $null = $serial.ReadExisting()
    $serial.Write("`r")
    $serial.Write("echo $readyMarker`r")
    Start-Sleep -Milliseconds 600
    $probe = $serial.ReadExisting()
    if ($probe -notmatch [regex]::Escape($readyMarker)) {
        throw "No Linux shell responded on $Port. Open it at 115200 8N1 and log in first."
    }

    $command = "if [ ! -d /sys/class/gpio/gpio$gpio ]; then " +
        "echo $gpio > /sys/class/gpio/export; fi; " +
        "echo out > /sys/class/gpio/gpio$gpio/direction; " +
        "i=0; while [ `$i -lt $Cycles ]; do " +
        "echo 0 > /sys/class/gpio/gpio$gpio/value; sleep $halfPeriod; " +
        "echo 1 > /sys/class/gpio/gpio$gpio/value; sleep $halfPeriod; " +
        "i=`$((i+1)); done; echo $doneMarker"

    Write-Host "Blinking $Led (Linux GPIO $gpio) $Cycles times on $Port..."
    $serial.Write("$command`r")
    $waitMilliseconds = ($Cycles * 2 * $HalfPeriodMilliseconds) + 2000
    Start-Sleep -Milliseconds $waitMilliseconds
    $response = $serial.ReadExisting()
    if ($response -notmatch [regex]::Escape($doneMarker)) {
        throw 'The UART command did not report completion.'
    }

    Write-Host "$Led blink completed; the active-low LED was left off."
} finally {
    if ($serial.IsOpen) {
        $serial.Close()
    }
    $serial.Dispose()
}
