# Alpaca FPGA

Reproducible bring-up and starter logic for Alpaca's iWave
iG-RainboW-G77D development platform, built around the AMD Versal AI Edge
Gen 2 `2VE3858`.

This repository starts with the path that has been tested on the physical
Alpaca board:

- Windows 11 host
- Vivado 2025.2
- iWave V25.2 release
- Digilent JTAG over the carrier's Debug USB-C connector
- Linux debug console over the same USB connection
- volatile PL programming with `system_pld.pdi`

It deliberately does **not** contain iWave release archives, PDI files, XSA
files, or generated Vivado output. Obtain those files from iWave under the
terms supplied with the hardware.

## Exact hardware in scope

| Item | Value |
| --- | --- |
| Development-kit part number | `iG77D-3858E2-4E008G-E032G-IEA` |
| SOM family | iG-RainboW-G77M |
| Device | `xc2ve3858-ssva2112-2MP-i-S` |
| Carrier | PRHSD R2.0 |
| Vendor release | V25.2 / REL1.0 / SD2.0 |
| Vivado | 2025.2 |
| Debug UART | 115200 baud, 8 data bits, no parity, 1 stop bit |

Do not assume these scripts or constraints apply to another G77M ordering
code, package, speed grade, carrier revision, or iWave software release.

## Five-minute smoke test

1. Install Vivado 2025.2 on Windows.
2. Connect the 12 V / 5 A supply and switch the carrier on.
3. Connect the carrier's Debug USB-C port to the PC.
4. Copy iWave's normal FPGA artifacts into this ignored local directory:

   ```text
   vendor/iwave/v25.2/FPGA/system_boot.pdi
   vendor/iwave/v25.2/FPGA/system_pld.pdi
   vendor/iwave/v25.2/FPGA/system.xsa
   ```

5. In PowerShell, run:

   ```powershell
   .\scripts\verify-release.ps1
   .\scripts\detect-hardware.ps1
   .\scripts\program-pl.ps1
   .\scripts\blink-user-led.ps1 -Port COM3 -Led D10
   ```

`program-pl.ps1` loads only the PL PDI through JTAG. It is volatile: it does
not erase or program OSPI, eMMC, or eFUSE, and a power cycle restores the
normal boot state. The UART command blinks D10 ten times and leaves it off.
COM numbers are assigned by Windows, so yours may not be `COM3`.

For the manual Vivado GUI route and troubleshooting, see
[First programming](docs/first-program.md).

## What the two PDI files mean

Versal AI Edge Gen 2 uses segmented configuration:

- `system_boot.pdi` initializes the processing system and boot-time platform.
- `system_pld.pdi` configures the programmable logic after the matching boot
  image is resident.

On a board that has already booted the matching iWave Linux image, the first
non-persistent FPGA smoke test uses `system_pld.pdi`. A PL PDI from a different
build may be rejected by the platform loader's compatibility checks.

The included scripts stop if they find no matching `xc2ve3858` target or find
more than one matching target. They never select an arbitrary device.

## Starter RTL

[`rtl/alpaca_led_blink.sv`](rtl/alpaca_led_blink.sv) is a small,
synthesizable active-low heartbeat block. The two verified user LED pins are
in [`constraints/ig77d_user_led.xdc`](constraints/ig77d_user_led.xdc).

This block is intended to be integrated into the iWave V25.2 base design and
clocked from a documented PL clock such as the CIPS `pl_clk0` output. It is not
a replacement for the board-specific CIPS, NoC, LPDDR5, and clock setup. See
[RTL integration](docs/rtl-integration.md).

## Repository map

```text
constraints/              Board-specific D10/D8 pin constraints
docs/                     Bring-up and RTL integration notes
rtl/                      Alpaca-owned synthesizable logic
scripts/                  Windows JTAG and UART helpers
vendor/iwave/README.md     Expected vendor artifact layout
```

## Reference documents

This starter was checked against these files from iWave's V25.2 deliverable:

- `iG-RainboW-G77M-Versal-AI-Edge-Gen2-SOM-SD2.0-Vivado25.2-FPGAUserGuide-R1.0-REL1.0.pdf`
- `iG-RainboW-G77M-Versal-AI-Edge-Gen2-SOM-SD2.0-Yocto-Scarthgap-V25.2-SoftwareUserGuide-R1.0-REL1.0.pdf`
- `iG-RainboW-G77M-Versal-AI-Edge-Gen2-SOM-SD2.0-Yocto-Scarthgap-V25.2-ReleaseNote-R1.0-REL1.0.pdf`

Useful public references:

- [AMD Vivado 2025.2 Programming and Debugging (UG908)](https://docs.amd.com/r/2025.2-English/ug908-vivado-programming-debugging/Advanced-Programming-Features)
- [AMD Versal segmented configuration](https://docs.amd.com/r/en-US/ug1273-versal-acap-design/Segmented-Configuration)
- [AMD Versal AI Edge Series Gen 2](https://www.amd.com/en/products/adaptive-socs-and-fpgas/versal/gen2/ai-edge-series.html)
- [iWave Versal portfolio](https://iwave-global.com/wp-content/uploads/2026/01/Versal-eBook-January-2026-iWave.pdf)

## License and vendor material

Alpaca-owned code and documentation in this repository are MIT licensed.
iWave and AMD material retain their respective licenses and trademarks. No
rights to redistribute vendor artifacts are granted by this repository.
