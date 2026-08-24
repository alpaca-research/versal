# Board examples

These examples exercise the interfaces enabled by iWave's V25.2 PetaLinux and
FPGA reference platform. They are written for the exact board identified in
the repository root README.

## Safe standalone suite

Copy `examples/linux` to the board and run as root:

```sh
cd examples/linux
./run-safe-suite.sh
```

The suite reports platform, storage, PCIe, video, network, and DIP-switch
status, then alternates D10 and D8. It does not write OSPI, eMMC, NVMe, or
eFUSE. Both LEDs are left off when it finishes.

The individual examples are:

| Script | Purpose | External hardware needed |
| --- | --- | --- |
| `platform-info.sh` | CPU, memory, RTC, OSPI map, block devices, I2C buses, USB, and network inventory | None |
| `gpio-led-demo.sh` | Alternate active-low user LEDs D10 and D8 | None |
| `dip-switches.sh` | Read both SW6 inputs | None |
| `pcie-status.sh` | Report the PS PCIe root port, endpoint, link, and NVMe status | None |
| `video-status.sh` | Report DRM connectors and the Xilinx media pipeline | None |
| `pcie-nvme-smoke.sh` | Write/read/delete a temporary file on mounted NVMe storage | NVMe SSD |

## PCIe example

iWave's V25.2 reference platform configures the PS PCIe controller as a Gen5
x1 root port. Install the PCIe/NVMe device while power is off, then boot the
board and run:

```sh
./pcie-status.sh
```

A detected NVMe endpoint should add a line resembling:

```text
01:00.0 Non-Volatile memory controller: ... NVMe SSD Controller
```

The first Alpaca bring-up showed only the Xilinx root bridge at `00:00.0`,
meaning that the controller initialized but no downstream PCIe endpoint was
enumerated.

If an NVMe partition is mounted at `/run/media/nvme0n1p1`, run the opt-in
10 MiB filesystem test:

```sh
./pcie-nvme-smoke.sh /run/media/nvme0n1p1 10
```

The script refuses non-NVMe mounts. It creates a uniquely named temporary file
inside the mount, reads it back, checks its size, and removes it even if the
test is interrupted. It never writes directly to `/dev/nvme*`.

## Examples requiring additional hardware

- HDMI output requires an attached display.
- HDMI capture/pass-through requires both a source and display.
- Ethernet tests require a connected network cable and configured peer.
- USB HID and storage tests require an attached device.
- IBERT requires the appropriate FMC+/QSFP loopback modules. Use iWave's
  matched IBERT boot and PLD images; do not substitute them into the normal
  Linux/platform flow.
