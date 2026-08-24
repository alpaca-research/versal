# Verified hardware facts

These values are specific to the tested Alpaca development kit and iWave's
V25.2 reference design.

## Identity

| Field | Value |
| --- | --- |
| Kit ordering code | `iG77D-3858E2-4E008G-E032G-IEA` |
| SOM | iG-RainboW-G77M Versal AI Edge Gen 2 |
| Silicon | AMD `2VE3858` |
| Vivado part | `xc2ve3858-ssva2112-2MP-i-S` |
| Carrier | PRHSD R2.0 |
| Host tooling | Vivado/Vitis 2025.2 |

The `I` design variant in the iWave deliverable matches the industrial device
suffix in the XSA. The normal Linux platform files are under
`Binaries/FPGA`; the separate `Binaries/IBERT` files are test images for GTYP
transceiver validation.

## User LEDs

| LED | PL signal | Package pin | I/O standard | Linux GPIO in V25.2 | Polarity |
| --- | --- | --- | --- | --- | --- |
| D10 | `User_LED_tri_o[0]` | `AP44` | `LVCMOS12` | 544 | Active-low |
| D8 | `User_LED_tri_o[1]` | `AP45` | `LVCMOS12` | 545 | Active-low |

The package pins come from Table 6 of iWave's Vivado 25.2 FPGA User Guide.
The GPIO numbers and polarity come from section 6.9 of iWave's V25.2 Software
User Guide. Linux GPIO numbering can change when the hardware design or device
tree changes.

## Debug interfaces

The Debug USB-C connection exposes Digilent JTAG plus FTDI serial channels.
Windows chooses the COM numbers dynamically. The Linux debug UART settings are
`115200 8N1`, no flow control.

The JTAG chain observed on the first Alpaca board was:

```text
Digilent cable
  arm_dap_0
  xc2ve3858_1
```

The unique cable serial is intentionally not recorded. Automation selects the
exact device pattern and fails on ambiguity.

## Segmented programming artifacts

| Artifact | Purpose |
| --- | --- |
| `system_boot.pdi` | Processing-system/platform boot PDI |
| `system_pld.pdi` | Programmable-logic PDI loaded after the matching boot PDI |
| `system.xsa` | Hardware handoff for software/platform tooling |

The tested XSA identifies Vivado 2025.2 and
`xc2ve3858-ssva2112-2MP-i-S`. Its design exposes
`User_LED_tri_o[1:0]` through AXI GPIO.

## Known release limitation

iWave's V25.2 release note reports that initial boot characters can be missed
because of the carrier's UART-to-USB converter. This does not necessarily mean
the board failed to boot; wait for output and press Enter.
