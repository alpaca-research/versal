# First programming on Windows

This procedure is for a recoverable first test. It loads programmable logic
through JTAG and does not change the boot flash.

## Before applying power

- Confirm the development kit is
  `iG77D-3858E2-4E008G-E032G-IEA` on the PRHSD R2.0 carrier.
- Use the carrier's specified 12 V / 5 A barrel supply.
- Connect the Debug USB-C port to the Windows PC. The same connection exposes
  Digilent JTAG and several FTDI serial channels.
- Use the normal V25.2 `Binaries/FPGA` artifacts, not `Binaries/IBERT`.
- Leave persistent OSPI/eMMC programming for a separate, reviewed procedure.

Power the board on and wait for Linux to reach its login or root prompt. A
power/status LED should be present, but D10 and D8 are user-controlled LEDs;
they do not prove that PL configuration succeeded and need not blink at boot.

## Confirm Windows sees the interfaces

List serial ports from PowerShell:

```powershell
Get-CimInstance Win32_SerialPort |
  Select-Object DeviceID, Name, PNPDeviceID
```

The exact COM numbers are assigned by Windows. On the first tested board,
`COM3` was the Linux debug UART. Open the candidate port at `115200 8N1` with
no flow control. The expected prompt is similar to:

```text
root@versal-ig77m:~#
```

## Check the vendor files

Either copy the three artifacts into the ignored directory described in
`vendor/iwave/README.md`, or give the release directory explicitly:

```powershell
.\scripts\verify-release.ps1 `
  -ReleaseRoot C:\path\to\Binaries\FPGA
```

The known REL1.0 hashes are recorded so a team member can distinguish the
tested files from a silent replacement or the IBERT image.

## Detect JTAG

Close any other Vivado Hardware Manager that owns the cable, then run:

```powershell
.\scripts\detect-hardware.ps1
```

The tested chain included:

```text
arm_dap_0
xc2ve3858_1
```

The helper requires exactly one device matching `xc2ve3858*`. If multiple
boards are connected, pass a narrower device pattern or disconnect the extra
target rather than programming an arbitrary device.

## Load the PL image from PowerShell

With the default vendor layout:

```powershell
.\scripts\program-pl.ps1
```

Or select a PDI explicitly:

```powershell
.\scripts\program-pl.ps1 `
  -PdiPath C:\path\to\Binaries\FPGA\system_pld.pdi
```

Success ends with `ALPACA: PL programming and verification completed`.

This is volatile JTAG configuration. It does not use Vivado's **Add
Configuration Memory Device** flow and it does not write OSPI, eMMC, or eFUSE.

## Equivalent Vivado GUI path

1. Start Vivado 2025.2.
2. Select **Open Hardware Manager**.
3. Select **Open target > Auto Connect**.
4. In the Hardware window, select the `xc2ve3858` device.
5. Select **Program Device**.
6. Choose the normal `Binaries/FPGA/system_pld.pdi` file.
7. Program the device and confirm that Vivado reports success.

Do not select `system_boot.pdi` for this already-booted Linux/PL smoke test.
That file is the processing-system portion of the segmented image. Do not use
the same-named files under `Binaries/IBERT` unless the explicit goal is a
high-speed transceiver IBERT test with the required loopback hardware.

## Prove the board is responsive

Blink D10 from the already-running Linux system through the Windows serial
port:

```powershell
.\scripts\blink-user-led.ps1 -Port COM3 -Led D10
```

Try D8 if its physical location is easier to see:

```powershell
.\scripts\blink-user-led.ps1 -Port COM3 -Led D8 -Cycles 20
```

In the tested V25.2 Linux image, D10 is GPIO 544 and D8 is GPIO 545. Both are
active-low: writing `0` turns the LED on and writing `1` turns it off. These
numbers are software-design dependent, so re-check them after changing the
XSA or device tree.

## Troubleshooting

### No JTAG target

- Confirm both the 12 V supply and Debug USB-C cable are connected.
- Confirm the carrier power switch is on.
- Check Device Manager for the Digilent/FTDI interfaces.
- Close other Vivado or Vitis instances that may own the cable.
- Reconnect the USB cable and rerun `detect-hardware.ps1`.

### PL PDI compatibility failure

Versal Gen 2 validates the segmented PL image against the resident platform.
Use `system_boot.pdi`, `system_pld.pdi`, and `system.xsa` from the same build.
If the board booted a different release, boot the matching release before
loading its PL PDI.

### UART helper cannot find a Linux root shell

- Check the COM number in Device Manager.
- Use `115200 8N1`, no flow control.
- Close PuTTY, Tera Term, or another process already using the port.
- Press Enter in a serial terminal and log in before rerunning the helper.

### The PL programmed but no LED blinked automatically

That is expected for iWave's normal V25.2 image. Its user LEDs are exposed via
GPIO and the shipped image does not implement a free-running LED flasher.
Run the UART LED helper or integrate the starter RTL.
