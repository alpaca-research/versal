# Integrating Alpaca RTL

The starter heartbeat is intentionally a leaf module, not a replacement board
design. The iG77D platform requires a correctly configured CIPS, NoC, memory,
clock, reset, and segmented-PDI flow.

## Recommended starting point

1. Build or open the matching iWave V25.2 base design for the industrial
   `xc2ve3858-ssva2112-2MP-i-S` part.
2. Add `rtl/alpaca_led_blink.sv` to the project.
3. Add `constraints/ig77d_user_led.xdc` to the constraints set.
4. Connect `clk` to the base design's documented PL clock. The delivered XSA
   reports `PL_CLK0` enabled.
5. Connect `resetn` to a reset synchronized to that clock.
6. Connect `User_LED_tri_o[1:0]` directly to the external two-bit user LED
   port. Remove or disconnect any competing AXI GPIO driver for that port.
7. Set `CLOCK_HZ` to the actual clock frequency, not an assumed value.
8. Validate the block design, synthesize, implement, and review timing and DRC
   results before generating the device image.

The module blinks D10 and holds D8 off. Both outputs are active-low.

## Why there is no guessed clock pin

The reference design gets PL clocks from the Versal processing/platform
design. Assigning an arbitrary external package pin as a clock would not be a
safe reusable foundation. This repository therefore constrains only the two
documented LED outputs and requires the integrator to use a known base-design
clock.

## Simulate the leaf module

Vivado 2025.2 can run the small self-checking testbench without the vendor
project:

```powershell
.\scripts\test-rtl.ps1
```

The simulation checks reset behavior, active-low LED polarity, and one full
on/off cycle.

## Generating and loading a custom image

Versal AI Edge Gen 2 uses segmented output. Preserve the matching boot/PLD
relationship when rebuilding. After Vivado generates the custom PL PDI, load
it explicitly:

```powershell
.\scripts\program-pl.ps1 -PdiPath C:\path\to\custom_system_pld.pdi
```

A custom PL image may also require a matching device-tree overlay or Linux
driver changes. A successful JTAG transaction proves configuration completed;
it does not prove that software-visible addresses or drivers still match.
